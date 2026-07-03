package com.mbcms.ws;

import com.mbcms.dao.BookingDAO;
import com.mbcms.model.Seat;
import com.mbcms.service.SeatAvailabilityService;
import com.mbcms.service.impl.SeatAvailabilityServiceImpl;
import static com.mbcms.ws.SeatSelectionMessage.HARD_LOCK;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * SeatWebSocketServer
 *
 * Endpoint: ws://host/ws/seats/{showtimeId}
 *
 * Quản lý 2 tầng trạng thái: SOFT LOCK: ConcurrentHashMap trong memory seatId →
 * username đang chọn (chưa submit) HARD LOCK: DB (bookings PENDING/CONFIRMED) -
 * đã có sẵn
 *
 * Mỗi showtime có 1 "room" riêng (sessions theo showtimeId).
 */
@ServerEndpoint(
        value = "/ws/seats/{showtimeId}",
        configurator = HttpSessionConfigurator.class
)
public class SeatWebSocketServer {

    private SeatAvailabilityService seatAvailabilityService = new SeatAvailabilityServiceImpl();

    /**
     * sessions: showtimeId → Set<Session>
     * Tất cả user đang xem cùng 1 showtime.
     */
    private static final ConcurrentHashMap<Long, Set<Session>> sessions
            = new ConcurrentHashMap<>();

    /**
     * softLocks: showtimeId → Map<seatId, username>
     * Ghế đang được user chọn (soft lock, chưa submit).
     */
    private static final ConcurrentHashMap<Long, Map<Long, String>> softLocks
            = new ConcurrentHashMap<>();

    // ── onOpen ────────────────────────────────────────────────────────────────
    @OnOpen
    public void onOpen(Session session,
            @PathParam("showtimeId") long showtimeId) throws IOException {

        // Lưu showtimeId vào session để dùng khi onClose
        session.getUserProperties().put("showtimeId", showtimeId);

        // Lấy username từ HTTP session (được truyền qua Configurator)
        String username = (String) session.getUserProperties().getOrDefault("username", "");
        session.getUserProperties().put("username", username);

        // Đăng ký session vào room
        sessions.computeIfAbsent(showtimeId,
                k -> Collections.newSetFromMap(new ConcurrentHashMap<>()))
                .add(session);

        softLocks.computeIfAbsent(showtimeId, k -> new ConcurrentHashMap<>());

        // Gửi trạng thái hiện tại cho user vừa kết nối (HARD LOCK từ DB)
        sendInitialState(session, showtimeId, username);
    }

    // ── onMessage ─────────────────────────────────────────────────────────────
    @OnMessage
    public void onMessage(String text, Session session) {
        SeatSelectionMessage msg = SeatSelectionMessage.fromJson(text);
        long showtimeId = (long) session.getUserProperties().get("showtimeId");
        String username = (String) session.getUserProperties().get("username");

        Map<Long, String> locks = softLocks.get(showtimeId);
        if (locks == null) {
            return;
        }

        switch (msg.getAction()) {

            case SeatSelectionMessage.SELECT:
                // Chỉ cho phép soft lock nếu ghế chưa bị ai giữ
                locks.putIfAbsent(msg.getSeatId(), username);

                // Nếu putIfAbsent thành công (mình vừa lock được)
                if (username.equals(locks.get(msg.getSeatId()))) {
                    broadcast(showtimeId,
                            new SeatSelectionMessage(
                                    SeatSelectionMessage.SELECT,
                                    msg.getSeatId(), showtimeId, username
                            ).toJson(),
                            null // broadcast tất cả kể cả sender
                    );
                } else {
                    // Ghế đã bị người khác soft lock → báo lại cho sender
                    sendToSession(session,
                            new SeatSelectionMessage(
                                    SeatSelectionMessage.HARD_LOCK, // hiển thị như locked
                                    msg.getSeatId(), showtimeId,
                                    locks.get(msg.getSeatId())
                            ).toJson()
                    );
                }
                break;

            case SeatSelectionMessage.DESELECT:
                // Chỉ người đang giữ mới được release
                locks.remove(msg.getSeatId(), username);
                broadcast(showtimeId,
                        new SeatSelectionMessage(
                                SeatSelectionMessage.DESELECT,
                                msg.getSeatId(), showtimeId, username
                        ).toJson(),
                        null
                );
                break;
        }
    }

    // ── onClose ───────────────────────────────────────────────────────────────
    @OnClose
    public void onClose(Session session) {
        long showtimeId = (long) session.getUserProperties().get("showtimeId");
        String username = (String) session.getUserProperties().get("username");

        // Xóa session khỏi room
        Set<Session> room = sessions.get(showtimeId);
        if (room != null) {
            room.remove(session);
        }

        // Release tất cả soft lock của user này
        Map<Long, String> locks = softLocks.get(showtimeId);
        if (locks != null) {
            List<Long> released = new ArrayList<>();
            locks.entrySet().removeIf(e -> {
                if (username.equals(e.getValue())) {
                    released.add(e.getKey());
                    return true;
                }
                return false;
            });

            // Broadcast release cho các user khác
            released.forEach(seatId
                    -> broadcast(showtimeId,
                            new SeatSelectionMessage(
                                    SeatSelectionMessage.DESELECT,
                                    seatId, showtimeId, username
                            ).toJson(),
                            null
                    )
            );
        }
    }

    @OnError
    public void onError(Session session, Throwable t) {
        System.err.println("[WS] Error session " + session.getId() + ": " + t.getMessage());
    }

    // ── Static methods cho Servlet gọi sau khi tạo/cancel booking ────────────
    /**
     * BookingCreateServlet / BookingService gọi sau khi INSERT booking PENDING.
     * Giữ ghế chờ thanh toán (hiển thị vàng), chưa phải booked.
     */
    public static void notifyHeldLock(long showtimeId, List<Long> seatIds, String username) {
        Map<Long, String> locks = softLocks.get(showtimeId);
        if (locks != null) {
            seatIds.forEach(seatId -> locks.remove(seatId, username));
        }
        seatIds.forEach(seatId
                -> broadcast(showtimeId,
                        new SeatSelectionMessage(
                                SeatSelectionMessage.HELD_LOCK,
                                seatId, showtimeId, username
                        ).toJson(),
                        null
                )
        );
    }

    /**
     * Gọi sau khi thanh toán thành công (CONFIRMED). Chuyển held → booked.
     */
    public static void notifyHardLock(long showtimeId, List<Long> seatIds, String username) {
        Map<Long, String> locks = softLocks.get(showtimeId);
        if (locks != null) {
            seatIds.forEach(seatId -> locks.remove(seatId, username));
        }
        seatIds.forEach(seatId
                -> broadcast(showtimeId,
                        new SeatSelectionMessage(
                                SeatSelectionMessage.HARD_LOCK,
                                seatId, showtimeId, username
                        ).toJson(),
                        null
                )
        );
    }

    /**
     * BookingExpiryScheduler gọi sau khi cancel booking hết hạn. Giải phóng
     * hard lock, ghế về AVAILABLE.
     */
    public static void notifyHardRelease(long showtimeId, List<Long> seatIds) {
        seatIds.forEach(seatId
                -> broadcast(showtimeId,
                        new SeatSelectionMessage(
                                SeatSelectionMessage.HARD_RELEASE,
                                seatId, showtimeId, ""
                        ).toJson(),
                        null
                )
        );
    }

    // ── Private helpers ───────────────────────────────────────────────────────
    private void sendInitialState(Session session, long showtimeId, String username) {
        try {
            List<Seat> seats = seatAvailabilityService.getSeats(showtimeId);
            Set<Long> booked = seatAvailabilityService.getBookedSeatIds(showtimeId);
            Set<Long> held = seatAvailabilityService.getHeldSeatIds(showtimeId);
            for (Seat seat : seats) {
                long seatId = seat.getSeatId();
                if (!seat.isActive()) {
                    continue;
                }
                if (booked.contains(seatId)) {
                    sendToSession(session,
                            new SeatSelectionMessage(HARD_LOCK, seatId, showtimeId, "").toJson());
                } else if (held.contains(seatId)) {
                    sendToSession(session,
                            new SeatSelectionMessage(
                                    SeatSelectionMessage.HELD_LOCK, seatId, showtimeId, ""
                            ).toJson());
                }
            }

            // Soft locks từ memory
            Map<Long, String> locks = softLocks.get(showtimeId);
            if (locks != null) {
                locks.forEach((seatId, lockedBy)
                        -> sendToSession(session,
                                new SeatSelectionMessage(
                                        SeatSelectionMessage.SELECT,
                                        seatId, showtimeId, lockedBy
                                ).toJson()
                        )
                );
            }
        } catch (Exception e) {
            System.err.println("[WS] Lỗi sendInitialState: " + e.getMessage());
        }
    }

    private static void broadcast(long showtimeId, String message, Session exclude) {
        Set<Session> room = sessions.get(showtimeId);
        if (room == null) {
            return;
        }
        room.forEach(s -> {
            if (s.equals(exclude) || !s.isOpen()) {
                return;
            }
            sendToSession(s, message);
        });
    }

    private static void sendToSession(Session session, String message) {
        try {
            synchronized (session) {
                session.getBasicRemote().sendText(message);
            }
        } catch (IOException e) {
            System.err.println("[WS] Lỗi gửi message: " + e.getMessage());
        }
    }
}

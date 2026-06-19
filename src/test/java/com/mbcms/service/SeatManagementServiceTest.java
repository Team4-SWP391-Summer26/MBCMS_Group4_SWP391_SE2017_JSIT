package com.mbcms.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.jupiter.api.Test;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.impl.SeatManagementServiceImpl;

/**
 * Unit test cho SeatManagementService (Manage seat types - Feature 3).
 * Dung DAO gia (fake) tu viet, khong can Mockito - moi rule deu o tang service.
 */
class SeatManagementServiceTest {

    private static final long BRANCH = 1L;
    private static final long ROOM = 10L;

    @Test
    void roomOfAnotherBranchIsRejected() {
        FakeRoomDAO rooms = new FakeRoomDAO(room(ROOM, 999L, true)); // branch khac
        SeatManagementService svc = new SeatManagementServiceImpl(new FakeSeatDAO(), rooms);

        Map<Long, String> types = new HashMap<>();
        types.put(100L, Seat.TYPE_VIP);
        assertEquals(SeatManagementService.RESULT_ROOM_INVALID,
                svc.updateSeatTypes(ROOM, BRANCH, types));
    }

    @Test
    void inactiveRoomIsRejected() {
        FakeRoomDAO rooms = new FakeRoomDAO(room(ROOM, BRANCH, false)); // khong active
        SeatManagementService svc = new SeatManagementServiceImpl(new FakeSeatDAO(), rooms);

        assertEquals(SeatManagementService.RESULT_ROOM_INVALID,
                svc.updateSeatTypes(ROOM, BRANCH, new HashMap<>()));
    }

    @Test
    void invalidSeatTypeIsRejected() {
        FakeRoomDAO rooms = new FakeRoomDAO(room(ROOM, BRANCH, true));
        SeatManagementService svc = new SeatManagementServiceImpl(new FakeSeatDAO(), rooms);

        Map<Long, String> types = new HashMap<>();
        types.put(100L, "COUPLE"); // khong thuoc whitelist
        assertEquals(SeatManagementService.RESULT_INVALID_INPUT,
                svc.updateSeatTypes(ROOM, BRANCH, types));
    }

    @Test
    void onlyChangedSeatsAreUpdated() {
        FakeRoomDAO rooms = new FakeRoomDAO(room(ROOM, BRANCH, true));
        FakeSeatDAO seats = new FakeSeatDAO(
                seat(100L, Seat.TYPE_STANDARD),
                seat(101L, Seat.TYPE_STANDARD));
        SeatManagementService svc = new SeatManagementServiceImpl(seats, rooms);

        Map<Long, String> types = new HashMap<>();
        types.put(100L, Seat.TYPE_VIP);       // doi
        types.put(101L, Seat.TYPE_STANDARD);  // giu nguyen
        assertEquals(SeatManagementService.RESULT_OK,
                svc.updateSeatTypes(ROOM, BRANCH, types));

        // Chi ghe 100 (thuc su doi) duoc gui xuong DAO.
        assertEquals(1, seats.lastUpdated.size());
        assertEquals(Seat.TYPE_VIP, seats.lastUpdated.get(100L));
    }

    @Test
    void noChangeDoesNotTouchDao() {
        FakeRoomDAO rooms = new FakeRoomDAO(room(ROOM, BRANCH, true));
        FakeSeatDAO seats = new FakeSeatDAO(seat(100L, Seat.TYPE_VIP));
        SeatManagementService svc = new SeatManagementServiceImpl(seats, rooms);

        Map<Long, String> types = new HashMap<>();
        types.put(100L, Seat.TYPE_VIP); // y nguyen
        assertEquals(SeatManagementService.RESULT_OK,
                svc.updateSeatTypes(ROOM, BRANCH, types));
        assertNull(seats.lastUpdated); // DAO khong he duoc goi
    }

    @Test
    void seatNotInRoomIsIgnored() {
        FakeRoomDAO rooms = new FakeRoomDAO(room(ROOM, BRANCH, true));
        FakeSeatDAO seats = new FakeSeatDAO(seat(100L, Seat.TYPE_STANDARD));
        SeatManagementService svc = new SeatManagementServiceImpl(seats, rooms);

        Map<Long, String> types = new HashMap<>();
        types.put(100L, Seat.TYPE_VIP);  // hop le
        types.put(555L, Seat.TYPE_VIP);  // seatId khong thuoc phong -> bo qua
        assertEquals(SeatManagementService.RESULT_OK,
                svc.updateSeatTypes(ROOM, BRANCH, types));

        assertEquals(1, seats.lastUpdated.size());
        assertTrue(seats.lastUpdated.containsKey(100L));
    }

    @Test
    void getSeatsForRoomOfAnotherBranchReturnsNull() {
        FakeRoomDAO rooms = new FakeRoomDAO(room(ROOM, 999L, true));
        SeatManagementService svc = new SeatManagementServiceImpl(new FakeSeatDAO(), rooms);
        assertNull(svc.getSeatsForRoom(ROOM, BRANCH));
    }

    // ----- helpers -----

    private static Room room(long id, long branchId, boolean active) {
        Room r = new Room();
        r.setRoomId(id);
        r.setBranchId(branchId);
        r.setActive(active);
        return r;
    }

    private static Seat seat(long id, String type) {
        Seat s = new Seat();
        s.setSeatId(id);
        s.setRoomId(ROOM);
        s.setSeatType(type);
        return s;
    }

    // ----- fake DAOs -----

    private static class FakeRoomDAO implements RoomDAO {
        private final Room room;
        FakeRoomDAO(Room room) { this.room = room; }
        @Override public List<Room> findActiveByBranch(long branchId) { return new ArrayList<>(); }
        @Override public Room findById(long roomId) { return (room != null && room.getRoomId() == roomId) ? room : null; }
    }

    private static class FakeSeatDAO implements SeatDAO {
        private final List<Seat> seats = new ArrayList<>();
        Map<Long, String> lastUpdated; // null = chua bao gio goi update
        FakeSeatDAO(Seat... s) { for (Seat x : s) seats.add(x); }
        @Override public List<Seat> findByRoom(long roomId) { return seats; }
        @Override public Set<Long> findBookedSeatIds(long showtimeId) { return Set.of(); }
        @Override public int updateSeatTypes(long roomId, Map<Long, String> seatTypes) {
            this.lastUpdated = seatTypes;
            return seatTypes.size();
        }
    }
}

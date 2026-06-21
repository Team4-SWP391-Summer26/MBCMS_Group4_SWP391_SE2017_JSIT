package com.mbcms.service;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.model.Room;
import com.mbcms.model.Showtime;
import com.mbcms.service.impl.ShowtimeServiceImpl;

/**
 * Unit test cho ShowtimeService - tap trung vao guard THOI GIAN moi them:
 * khong cho huy / sua suat da bat dau (dang chieu hoac da chieu xong).
 * Dung DAO gia tu viet, khong can Mockito - moi rule deu o tang service.
 */
class ShowtimeServiceTest {

    private static final long BRANCH = 1L;
    private static final long ROOM = 10L;
    private static final long ST_ID = 100L;

    // now() luon nam giua 2 moc nay nen test on dinh, khoi can inject Clock.
    private static final LocalDateTime PAST = LocalDateTime.of(2020, 1, 1, 10, 0);
    private static final LocalDateTime FUTURE = LocalDateTime.of(2099, 1, 1, 10, 0);

    // ---------- cancelShowtime ----------

    @Test
    void cancelPastShowtimeIsBlocked() {
        ShowtimeService svc = service(showtime(PAST, Showtime.STATUS_SCHEDULED), false, true);
        assertEquals(ShowtimeService.RESULT_NOT_EDITABLE, svc.cancelShowtime(ST_ID, BRANCH));
    }

    @Test
    void cancelOngoingShowtimeIsBlocked() {
        // start = 1 phut truoc -> dang chieu -> khong huy duoc
        ShowtimeService svc = service(showtime(LocalDateTime.now().minusMinutes(1),
                Showtime.STATUS_SCHEDULED), false, true);
        assertEquals(ShowtimeService.RESULT_NOT_EDITABLE, svc.cancelShowtime(ST_ID, BRANCH));
    }

    @Test
    void cancelFutureScheduledNoBookingsIsOk() {
        ShowtimeService svc = service(showtime(FUTURE, Showtime.STATUS_SCHEDULED), false, true);
        assertEquals(ShowtimeService.RESULT_OK, svc.cancelShowtime(ST_ID, BRANCH));
    }

    @Test
    void cancelFutureWithBookingsIsBlocked() {
        ShowtimeService svc = service(showtime(FUTURE, Showtime.STATUS_SCHEDULED), true, true);
        assertEquals(ShowtimeService.RESULT_HAS_BOOKINGS, svc.cancelShowtime(ST_ID, BRANCH));
    }

    @Test
    void cancelAlreadyCancelledIsBlocked() {
        ShowtimeService svc = service(showtime(FUTURE, Showtime.STATUS_CANCELLED), false, true);
        assertEquals(ShowtimeService.RESULT_NOT_EDITABLE, svc.cancelShowtime(ST_ID, BRANCH));
    }

    @Test
    void cancelOtherBranchIsNotFound() {
        // room thuoc branch 999 -> khong thuoc branch dang dang nhap
        ShowtimeService svc = new ShowtimeServiceImpl(
                new FakeShowtimeDAO(showtime(FUTURE, Showtime.STATUS_SCHEDULED), false, true),
                new FakeRoomDAO(room(999L, true)));
        assertEquals(ShowtimeService.RESULT_NOT_FOUND, svc.cancelShowtime(ST_ID, BRANCH));
    }

    // ---------- updateShowtime ----------

    @Test
    void updatePastShowtimeIsBlocked() {
        ShowtimeService svc = service(showtime(PAST, Showtime.STATUS_SCHEDULED), false, true);
        assertEquals(ShowtimeService.RESULT_NOT_EDITABLE, svc.updateShowtime(form(), BRANCH));
    }

    @Test
    void updateFutureValidIsOk() {
        ShowtimeService svc = service(showtime(FUTURE, Showtime.STATUS_SCHEDULED), false, true);
        assertEquals(ShowtimeService.RESULT_OK, svc.updateShowtime(form(), BRANCH));
    }

    // ---------- helpers ----------

    private static ShowtimeService service(Showtime existing, boolean hasBookings, boolean daoOk) {
        return new ShowtimeServiceImpl(
                new FakeShowtimeDAO(existing, hasBookings, daoOk),
                new FakeRoomDAO(room(BRANCH, true)));
    }

    private static Showtime showtime(LocalDateTime start, String status) {
        Showtime st = new Showtime();
        st.setShowtimeId(ST_ID);
        st.setRoomId(ROOM);
        st.setStartTime(start);
        st.setStatus(status);
        return st;
    }

    /** Showtime gui tu form khi edit (chi can id + roomId cho cac check). */
    private static Showtime form() {
        Showtime st = new Showtime();
        st.setShowtimeId(ST_ID);
        st.setRoomId(ROOM);
        return st;
    }

    private static Room room(long branchId, boolean active) {
        Room r = new Room();
        r.setRoomId(ROOM);
        r.setBranchId(branchId);
        r.setActive(active);
        return r;
    }

    // ---------- fake DAOs ----------

    private static class FakeRoomDAO implements RoomDAO {
        private final Room room;
        FakeRoomDAO(Room room) { this.room = room; }
        @Override public List<Room> findActiveByBranch(long branchId) { return new ArrayList<>(); }
        @Override public Room findById(long roomId) { return (room != null && room.getRoomId() == roomId) ? room : null; }
    }

    private static class FakeShowtimeDAO implements ShowtimeDAO {
        private final Showtime existing;
        private final boolean hasBookings;
        private final boolean daoOk;
        FakeShowtimeDAO(Showtime existing, boolean hasBookings, boolean daoOk) {
            this.existing = existing; this.hasBookings = hasBookings; this.daoOk = daoOk;
        }
        @Override public Showtime findById(long showtimeId) { return (existing != null && existing.getShowtimeId() == showtimeId) ? existing : null; }
        @Override public boolean hasActiveBookings(long showtimeId) { return hasBookings; }
        @Override public boolean hasUnfinishedShowtimes(long branchId, long movieId) { return false; }
        @Override public boolean cancel(long showtimeId) { return daoOk; }
        @Override public boolean updateWithConflictCheck(Showtime showtime) { return daoOk; }
        @Override public boolean createWithConflictCheck(Showtime showtime) { return daoOk; }
        @Override public List<Showtime> findByBranch(long branchId, Long movieId, Long roomId, LocalDate date) { return new ArrayList<>(); }
        @Override public List<Showtime> findByMovieId(long movieId) { return new ArrayList<>(); }
    }
}

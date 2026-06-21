package com.mbcms.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.jupiter.api.Test;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.MovieBranchDAO;
import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.model.Branch;
import com.mbcms.model.Movie;
import com.mbcms.model.Showtime;
import com.mbcms.service.impl.MovieDistributionServiceImpl;

/**
 * Unit test cho MovieDistributionService (Admin cap phim cho chi nhanh - Phase 2).
 * Dung DAO gia tu viet, khong can Mockito - moi rule deu o tang service.
 */
class MovieDistributionServiceTest {

    private static final long BRANCH = 1L;

    /** Tao service voi DAO gia; ShowtimeDAO mac dinh: khong phim nao con suat chua chieu. */
    private static MovieDistributionService svc(FakeBranchDAO b, FakeMovieDAO m, FakeMovieBranchDAO mb) {
        return new MovieDistributionServiceImpl(b, m, mb, new FakeShowtimeDAO());
    }

    @Test
    void invalidBranchIsRejected() {
        MovieDistributionService s = svc(new FakeBranchDAO(BRANCH), new FakeMovieDAO(10L, 20L), new FakeMovieBranchDAO());
        Set<Long> ids = new HashSet<>(Arrays.asList(10L));
        assertEquals(MovieDistributionService.RESULT_BRANCH_INVALID,
                s.saveAssignments(999L, ids)); // branch khong ton tai
    }

    @Test
    void getAssignedForInvalidBranchReturnsNull() {
        MovieDistributionService s = svc(new FakeBranchDAO(BRANCH), new FakeMovieDAO(10L), new FakeMovieBranchDAO(10L));
        assertNull(s.getAssignedMovieIds(999L));
    }

    @Test
    void getAssignedReturnsDaoSet() {
        MovieDistributionService s = svc(new FakeBranchDAO(BRANCH), new FakeMovieDAO(10L, 20L), new FakeMovieBranchDAO(20L));
        Set<Long> assigned = s.getAssignedMovieIds(BRANCH);
        assertEquals(1, assigned.size());
        assertTrue(assigned.contains(20L));
    }

    @Test
    void nonActiveMovieIdsAreFilteredOut() {
        FakeMovieBranchDAO mb = new FakeMovieBranchDAO();
        // catalog active = {10, 20}; form gui them 999 (khong active / sua tay)
        MovieDistributionService s = svc(new FakeBranchDAO(BRANCH), new FakeMovieDAO(10L, 20L), mb);

        Set<Long> ids = new HashSet<>(Arrays.asList(10L, 999L));
        assertEquals(MovieDistributionService.RESULT_OK, s.saveAssignments(BRANCH, ids));

        // Chi 10 (active) duoc gui xuong DAO; 999 bi loai.
        assertEquals(1, mb.lastSaved.size());
        assertTrue(mb.lastSaved.contains(10L));
        assertFalse(mb.lastSaved.contains(999L));
    }

    @Test
    void emptySelectionClearsAllAssignments() {
        FakeMovieBranchDAO mb = new FakeMovieBranchDAO(10L, 20L);
        MovieDistributionService s = svc(new FakeBranchDAO(BRANCH), new FakeMovieDAO(10L, 20L), mb);

        assertEquals(MovieDistributionService.RESULT_OK,
                s.saveAssignments(BRANCH, new HashSet<>())); // bo tick het (khong con suat)
        assertTrue(mb.lastSaved.isEmpty());
    }

    @Test
    void inactiveButAssignedMovieIsPreserved() {
        // Branch da cap phim 99 (gio KHONG active, khong hien tren checklist).
        // Admin save voi chi 10 duoc tick -> phim 99 phai duoc GIU, khong bi go am tham.
        FakeMovieBranchDAO mb = new FakeMovieBranchDAO(10L, 99L);
        MovieDistributionService s = svc(new FakeBranchDAO(BRANCH), new FakeMovieDAO(10L), mb); // active = {10}

        assertEquals(MovieDistributionService.RESULT_OK,
                s.saveAssignments(BRANCH, new HashSet<>(Arrays.asList(10L))));

        assertEquals(2, mb.lastSaved.size());
        assertTrue(mb.lastSaved.contains(10L));
        assertTrue(mb.lastSaved.contains(99L)); // giu lai phim inactive da cap
    }

    @Test
    void cannotUnassignMovieWithUnfinishedShowtimes() {
        // Branch da cap phim 10 va dang con suat chieu chua ket thuc cho phim 10.
        FakeMovieBranchDAO mb = new FakeMovieBranchDAO(10L);
        MovieDistributionService s = new MovieDistributionServiceImpl(
                new FakeBranchDAO(BRANCH), new FakeMovieDAO(10L), mb,
                new FakeShowtimeDAO(10L)); // phim 10 con suat chua chieu xong

        // Bo tick 10 (go phan phoi) -> phai bi chan.
        assertEquals(MovieDistributionService.RESULT_HAS_SHOWTIMES,
                s.saveAssignments(BRANCH, new HashSet<>()));
        assertNull(mb.lastSaved); // KHONG goi DAO -> khong thay doi gi
    }

    // ----- fake DAOs -----

    private static class FakeBranchDAO implements BranchDAO {
        private final Set<Long> validIds = new HashSet<>();
        FakeBranchDAO(Long... ids) { validIds.addAll(Arrays.asList(ids)); }
        @Override public Branch findById(long branchId) {
            if (!validIds.contains(branchId)) return null;
            Branch b = new Branch(); b.setBranchId(branchId); return b;
        }
        @Override public List<Branch> findAll() {
            List<Branch> list = new ArrayList<>();
            for (Long id : validIds) { Branch b = new Branch(); b.setBranchId(id); list.add(b); }
            return list;
        }
        @Override public List<Branch> findAllActive() { return findAll(); }
    }

    private static class FakeMovieDAO implements MovieDAO {
        private final List<Movie> active = new ArrayList<>();
        FakeMovieDAO(long... ids) {
            for (long id : ids) { Movie m = new Movie(); m.setMovieId(id); m.setActive(true); active.add(m); }
        }
        @Override public List<Movie> findActiveMovies() { return active; }
        @Override public List<Movie> findActiveMoviesForBranch(long branchId) { return active; }
        @Override public boolean isAssignedToBranch(long movieId, long branchId) { return false; }
        @Override public Movie findById(long movieId) {
            for (Movie m : active) if (m.getMovieId() == movieId) return m;
            return null;
        }
        @Override public List<Movie> findByBranch(long branchId) { return List.of(); }
    }

    private static class FakeMovieBranchDAO implements MovieBranchDAO {
        private final Set<Long> assigned = new HashSet<>();
        Set<Long> lastSaved; // null = chua goi updateAssignments
        FakeMovieBranchDAO(Long... ids) { assigned.addAll(Arrays.asList(ids)); }
        @Override public Set<Long> findMovieIdsByBranch(long branchId) { return assigned; }
        @Override public int countAll() { return assigned.size(); }
        @Override public int updateAssignments(long branchId, Set<Long> targetMovieIds) {
            this.lastSaved = targetMovieIds;
            return targetMovieIds.size();
        }
    }

    private static class FakeShowtimeDAO implements ShowtimeDAO {
        private final Set<Long> unfinished = new HashSet<>();
        FakeShowtimeDAO(Long... movieIdsWithUnfinished) { unfinished.addAll(Arrays.asList(movieIdsWithUnfinished)); }
        @Override public boolean hasUnfinishedShowtimes(long branchId, long movieId) { return unfinished.contains(movieId); }
        // --- stub cac method khong dung trong test nay ---
        @Override public List<Showtime> findByBranch(long b, Long m, Long r, LocalDate d) { return new ArrayList<>(); }
        @Override public boolean createWithConflictCheck(Showtime s) { return true; }
        @Override public Showtime findById(long id) { return null; }
        @Override public boolean updateWithConflictCheck(Showtime s) { return true; }
        @Override public boolean hasActiveBookings(long id) { return false; }
        @Override public List<Showtime> findByMovieId(long id) { return new ArrayList<>(); }
        @Override public boolean cancel(long id) { return true; }
    }
}

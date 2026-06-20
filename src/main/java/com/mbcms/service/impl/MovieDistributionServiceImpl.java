package com.mbcms.service.impl;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.MovieBranchDAO;
import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.dao.impl.MovieBranchDAOImpl;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Movie;
import com.mbcms.service.MovieDistributionService;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Tang Service cho Admin "Assign movie to branch" (Phase 2). Owner: HungNT.
 * Chua toan bo business rule; DAO chi lo SQL.
 */
public class MovieDistributionServiceImpl implements MovieDistributionService {

    private final BranchDAO branchDAO;
    private final MovieDAO movieDAO;
    private final MovieBranchDAO movieBranchDAO;
    private final ShowtimeDAO showtimeDAO;

    /** Constructor mac dinh khi chay that. */
    public MovieDistributionServiceImpl() {
        this.branchDAO = new BranchDAOImpl();
        this.movieDAO = new MovieDAOImpl();
        this.movieBranchDAO = new MovieBranchDAOImpl();
        this.showtimeDAO = new ShowtimeDAOImpl();
    }

    /** Constructor cho unit test (inject DAO gia). */
    public MovieDistributionServiceImpl(BranchDAO branchDAO, MovieDAO movieDAO,
                                        MovieBranchDAO movieBranchDAO, ShowtimeDAO showtimeDAO) {
        this.branchDAO = branchDAO;
        this.movieDAO = movieDAO;
        this.movieBranchDAO = movieBranchDAO;
        this.showtimeDAO = showtimeDAO;
    }

    @Override
    public List<Movie> getAssignableMovies() {
        return movieDAO.findActiveMovies();
    }

    @Override
    public Set<Long> getAssignedMovieIds(long branchId) {
        if (branchDAO.findById(branchId) == null) {
            return null; // branch khong ton tai
        }
        return movieBranchDAO.findMovieIdsByBranch(branchId);
    }

    @Override
    public String saveAssignments(long branchId, Set<Long> movieIds) {
        // Buoc 1: branch phai ton tai.
        if (branchDAO.findById(branchId) == null) {
            return RESULT_BRANCH_INVALID;
        }

        // Buoc 2: whitelist - chi giu movie_id la phim ACTIVE that su. movie_id gui
        // tu form co the bi sua tay (phim khong active / khong ton tai) -> bo qua.
        Set<Long> activeIds = new HashSet<>();
        for (Movie m : movieDAO.findActiveMovies()) {
            activeIds.add(m.getMovieId());
        }
        Set<Long> safe = new HashSet<>();
        for (Long id : movieIds) {
            if (activeIds.contains(id)) {
                safe.add(id);
            }
        }

        Set<Long> current = movieBranchDAO.findMovieIdsByBranch(branchId);

        // Buoc 3: BAO TOAN cap phat cho phim KHONG active (vd phim da bi tat sau khi
        // cap). Checklist chi hien phim active nen nhung phim do khong co tren form;
        // neu khong giu lai, save bat ky se am tham go chung -> chi reconcile trong
        // tap phim active (= tap hien tren checklist).
        Set<Long> target = new HashSet<>(safe);
        for (Long assigned : current) {
            if (!activeIds.contains(assigned)) {
                target.add(assigned);
            }
        }

        // Buoc 4: KHONG cho go phim ma chi nhanh CON suat chieu chua ket thuc
        // (dang/se chieu) -> tranh mo coi suat + ve da ban. Phai huy suat truoc.
        for (Long assigned : current) {
            if (!target.contains(assigned) && showtimeDAO.hasUnfinishedShowtimes(branchId, assigned)) {
                return RESULT_HAS_SHOWTIMES;
            }
        }

        // Buoc 5: dat lai phan phoi cho branch (DAO tu tinh diff trong transaction).
        movieBranchDAO.updateAssignments(branchId, target);
        return RESULT_OK;
    }
}

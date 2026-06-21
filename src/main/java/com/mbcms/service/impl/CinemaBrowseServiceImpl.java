package com.mbcms.service.impl;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Branch;
import com.mbcms.model.Movie;
import com.mbcms.model.Showtime;
import com.mbcms.service.CinemaBrowseService;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class CinemaBrowseServiceImpl implements CinemaBrowseService {

    private final BranchDAO branchDAO;
    private final MovieDAO movieDAO;
    private final ShowtimeDAO showtimeDAO;

    public CinemaBrowseServiceImpl() {
        this.branchDAO = new BranchDAOImpl();
        this.movieDAO = new MovieDAOImpl();
        this.showtimeDAO = new ShowtimeDAOImpl();
    }

    public CinemaBrowseServiceImpl(BranchDAO branchDAO, MovieDAO movieDAO, ShowtimeDAO showtimeDAO) {
        this.branchDAO = branchDAO;
        this.movieDAO = movieDAO;
        this.showtimeDAO = showtimeDAO;
    }

    @Override
    public List<Branch> getActiveBranches() {
        return branchDAO.findAllActive();
    }

    @Override
    public Branch getActiveBranch(long branchId) {
        Branch b = branchDAO.findById(branchId);
        if (b == null || !b.isActive()) {
            return null;
        }
        return b;
    }

    @Override
    public List<Movie> getMoviesByBranch(long branchId) {
        return movieDAO.findByBranch(branchId);
    }

    @Override
    public Movie getMovie(long movieId) {
        return movieDAO.findById(movieId);
    }

    @Override
    public Map<LocalDate, List<Showtime>> getShowtimesByBranchAndMovie(long branchId, long movieId) {
        // movieId truyen vao DAO de loc luon o tang SQL; roomId/date = null (khong loc).
        List<Showtime> all = showtimeDAO.findByBranch(branchId, movieId, null, null);

        LocalDateTime now = LocalDateTime.now();
        // TreeMap: tu dong sap xep ngay tang dan; chi giu suat con SCHEDULED va o tuong lai.
        Map<LocalDate, List<Showtime>> byDate = new TreeMap<>();
        for (Showtime st : all) {
            if (!Showtime.STATUS_SCHEDULED.equals(st.getStatus())) {
                continue;
            }
            if (st.getStartTime() == null || !st.getStartTime().isAfter(now)) {
                continue;
            }
            byDate.computeIfAbsent(st.getStartTime().toLocalDate(), k -> new java.util.ArrayList<>())
                    .add(st);
        }
        // Sap gio tang dan trong tung ngay (findByBranch da ORDER BY start_time nen thuong da dung thu tu,
        // sort lai cho chac chan vi minh moi loc/group lai tu danh sach goc).
        for (List<Showtime> list : byDate.values()) {
            list.sort(Comparator.comparing(Showtime::getStartTime));
        }
        return byDate;
    }
}

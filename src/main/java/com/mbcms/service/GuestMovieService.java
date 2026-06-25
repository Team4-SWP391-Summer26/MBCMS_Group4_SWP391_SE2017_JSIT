package com.mbcms.service;

import com.mbcms.model.Branch;
import com.mbcms.model.Genre;
import com.mbcms.model.Movie;

import java.util.List;

/**
 * GuestMovieService - owner: AnhND.
 *
 * Tầng service xử lý business logic cho Guest xem phim.
 * Servlet chỉ nhận request/trả view, DAO chỉ truy vấn DB, Service nằm giữa để validate input.
 */
public interface GuestMovieService {

    List<Movie> browseMovies(String status,
                             String keyword,
                             String genre,
                             String language,
                             Long branchId,
                             String sort);

    Movie getMovieDetail(long movieId);

    List<Genre> getGenres();

    List<String> getLanguages();

    List<Branch> getBranches();
}
package com.mbcms.dao;

import com.mbcms.model.Movie;

import java.util.List;

/**
 * GuestMovieDAO - owner: AnhND.
 *
 * DAO riêng cho các chức năng Guest xem phim:
 * - Browse movies
 * - Search movies
 * - Filter movies
 * - View movie details
 *
 * Lý do tách riêng: MovieDAO hiện có đang được dùng cho Showtime Management,
 * nên tách GuestMovieDAO để code của AnhND dễ copy/paste và không ảnh hưởng
 * các phần của bạn khác.
 */
public interface GuestMovieDAO {

    /**
     * Lấy danh sách phim cho Guest, có thể lọc theo status/keyword/genre/language/branch
     * và sắp xếp theo sort.
     */
    List<Movie> findMoviesForGuest(String status,
                                   String keyword,
                                   String genre,
                                   String language,
                                   Long branchId,
                                   String sort);

    /**
     * Lấy đầy đủ thông tin chi tiết của 1 phim kèm danh sách thể loại.
     */
    Movie findMovieDetailForGuest(long movieId);

    /**
     * Lấy danh sách ngôn ngữ đang có trong bảng movies để hiển thị filter.
     */
    List<String> findAllLanguages();
}
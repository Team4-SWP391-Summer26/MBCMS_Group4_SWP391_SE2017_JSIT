package com.mbcms.dao;

import com.mbcms.model.Movie;

import java.util.List;
import java.util.Set;

/**
 * MovieAdminDAO - CRUD bang `movies` cho Admin (UC: Add/Edit/Delete movie,
 * Upload posters/trailers, Manage movie status). Tach rieng khoi MovieDAO
 * (showtime) va GuestMovieDAO (browse) de khong dung cham logic da co.
 */
public interface MovieAdminDAO {

    /** Danh sach phim cho Admin (ke ca active=0), co the loc theo keyword + status. */
    List<Movie> findAll(String keyword, String status);

    /** Lay day du thong tin 1 phim (kem ten the loai); null neu khong ton tai. */
    Movie findById(long movieId);

    /** Lay tap genre_id dang gan cho phim - dung tick san checkbox khi sua. */
    Set<Integer> findGenreIds(long movieId);

    /** Them phim moi, tra ve movie_id vua sinh. */
    long insert(Movie movie);

    /** Cap nhat toan bo thong tin phim. */
    boolean update(Movie movie);

    /** Xoa han phim (movie_genres + movie_branch tu cascade). */
    boolean delete(long movieId);

    /** So suat chieu dang tham chieu phim - dung chan xoa (FK showtimes khong cascade). */
    int countShowtimes(long movieId);

    /** Doi rieng trang thai chieu (UPCOMING / NOW_SHOWING / ENDED). */
    boolean updateStatus(long movieId, String status);

    /** Bat/tat hien thi phim (active). */
    boolean updateActive(long movieId, boolean active);

    /** Ghi lai danh sach the loai cua phim (xoa cu, them moi). */
    void replaceGenres(long movieId, Set<Integer> genreIds);

    /** Danh sach ngon ngu dang co (distinct) - do vao datalist khi nhap phim. */
    List<String> findAllLanguages();
}

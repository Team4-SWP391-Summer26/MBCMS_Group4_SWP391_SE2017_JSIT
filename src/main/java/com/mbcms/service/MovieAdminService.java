package com.mbcms.service;

import com.mbcms.model.Genre;
import com.mbcms.model.Movie;

import java.util.List;
import java.util.Set;

/**
 * MovieAdminService - nghiep vu quan ly phim cho Admin (validate + uy quyen DAO).
 */
public interface MovieAdminService {

    List<Movie> list(String keyword, String status);

    Movie get(long movieId);

    Set<Integer> getGenreIds(long movieId);

    /** Them phim moi (kem the loai). Tra ve movie_id. Nem IllegalArgumentException neu du lieu sai. */
    long create(Movie movie, Set<Integer> genreIds);

    /** Cap nhat phim (kem the loai). Nem IllegalArgumentException neu du lieu sai. */
    boolean update(Movie movie, Set<Integer> genreIds);

    /** Xoa phim. Nem IllegalArgumentException neu phim con suat chieu. */
    void delete(long movieId);

    boolean changeStatus(long movieId, String status);

    boolean setActive(long movieId, boolean active);

    /** Toan bo the loai - do vao checkbox o form them/sua phim. */
    List<Genre> allGenres();

    /** Ngon ngu da co - do vao datalist o form. */
    List<String> allLanguages();
}

package com.mbcms.dao;

import com.mbcms.model.Genre;

import java.util.List;

/**
 * GenreDAO - CRUD bang `genres` cho Admin (UC: Manage genres).
 */
public interface GenreDAO {

    /** Tat ca the loai, kem so phim dang dung (movieCount), sap theo ten. */
    List<Genre> findAllWithCount();

    /** Tim 1 the loai theo id; null neu khong ton tai. */
    Genre findById(int genreId);

    /** Ten the loai da ton tai chua (bo qua chinh no khi sua); de bao loi trung. */
    boolean existsByName(String name, Integer excludeId);

    /** Them the loai moi, tra ve genre_id vua sinh. */
    int insert(String name);

    /** Doi ten the loai. */
    boolean update(int genreId, String name);

    /** Xoa the loai (chi khi khong con phim nao dung). */
    boolean delete(int genreId);

    /** The loai con phim nao dung khong (FK movie_genres khong cascade). */
    boolean isInUse(int genreId);
}

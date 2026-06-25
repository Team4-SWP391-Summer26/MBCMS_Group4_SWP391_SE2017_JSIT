package com.mbcms.service;

import com.mbcms.model.Genre;

import java.util.List;

/**
 * GenreService - nghiep vu Manage genres cho Admin.
 */
public interface GenreService {

    List<Genre> listWithCount();

    /** Them the loai moi. Nem IllegalArgumentException neu rong/trung ten. */
    int create(String name);

    /** Doi ten the loai. Nem IllegalArgumentException neu rong/trung ten. */
    boolean rename(int genreId, String name);

    /** Xoa the loai. Nem IllegalArgumentException neu dang co phim dung. */
    void delete(int genreId);
}

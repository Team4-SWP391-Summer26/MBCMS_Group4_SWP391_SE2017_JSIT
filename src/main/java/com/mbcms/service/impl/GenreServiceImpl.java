package com.mbcms.service.impl;

import com.mbcms.dao.GenreDAO;
import com.mbcms.dao.impl.GenreDAOImpl;
import com.mbcms.model.Genre;
import com.mbcms.service.GenreService;

import java.util.List;

public class GenreServiceImpl implements GenreService {

    private final GenreDAO genreDAO = new GenreDAOImpl();

    @Override
    public List<Genre> listWithCount() {
        return genreDAO.findAllWithCount();
    }

    @Override
    public int create(String name) {
        String clean = clean(name);
        if (genreDAO.existsByName(clean, null)) {
            throw new IllegalArgumentException("Thể loại \"" + clean + "\" đã tồn tại.");
        }
        return genreDAO.insert(clean);
    }

    @Override
    public boolean rename(int genreId, String name) {
        String clean = clean(name);
        if (genreDAO.findById(genreId) == null) {
            throw new IllegalArgumentException("Thể loại không tồn tại.");
        }
        if (genreDAO.existsByName(clean, genreId)) {
            throw new IllegalArgumentException("Thể loại \"" + clean + "\" đã tồn tại.");
        }
        return genreDAO.update(genreId, clean);
    }

    @Override
    public void delete(int genreId) {
        if (genreDAO.findById(genreId) == null) {
            throw new IllegalArgumentException("Thể loại không tồn tại.");
        }
        if (genreDAO.isInUse(genreId)) {
            throw new IllegalArgumentException("Không thể xóa: thể loại đang được gán cho một số phim.");
        }
        genreDAO.delete(genreId);
    }

    private String clean(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Tên thể loại không được để trống.");
        }
        String clean = name.trim();
        if (clean.length() > 50) {
            throw new IllegalArgumentException("Tên thể loại tối đa 50 ký tự.");
        }
        return clean;
    }
}

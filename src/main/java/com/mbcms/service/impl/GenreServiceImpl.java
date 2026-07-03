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
            throw new IllegalArgumentException("Genre \"" + clean + "\" already exists.");
        }
        return genreDAO.insert(clean);
    }

    @Override
    public boolean rename(int genreId, String name) {
        String clean = clean(name);
        if (genreDAO.findById(genreId) == null) {
            throw new IllegalArgumentException("Genre does not exist.");
        }
        if (genreDAO.existsByName(clean, genreId)) {
            throw new IllegalArgumentException("Genre \"" + clean + "\" already exists.");
        }
        return genreDAO.update(genreId, clean);
    }

    @Override
    public void delete(int genreId) {
        if (genreDAO.findById(genreId) == null) {
            throw new IllegalArgumentException("Genre does not exist.");
        }
        if (genreDAO.isInUse(genreId)) {
            throw new IllegalArgumentException("Cannot delete this genre because it is assigned to one or more movies.");
        }
        genreDAO.delete(genreId);
    }

    private String clean(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Genre name is required.");
        }
        String clean = name.trim();
        if (clean.length() > 50) {
            throw new IllegalArgumentException("Genre name must be 50 characters or fewer.");
        }
        return clean;
    }
}

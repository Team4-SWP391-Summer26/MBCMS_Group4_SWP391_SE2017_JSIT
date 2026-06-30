package com.mbcms.model;

/**
 * Genre - map bang `genres`.
 */
public class Genre {

    private int genreId;
    private String name;
    private int movieCount; // chi de hien thi o trang Manage genres (so phim dang dung)

    public Genre() {
    }

    public int getGenreId() {
        return genreId;
    }

    public void setGenreId(int genreId) {
        this.genreId = genreId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getMovieCount() {
        return movieCount;
    }

    public void setMovieCount(int movieCount) {
        this.movieCount = movieCount;
    }
}

package com.mbcms.model;

/**
 * Genre - map bang `genres`.
 */
public class Genre {
    private int genreId;
    private String name;

    public Genre() {}

    public int getGenreId() { return genreId; }
    public void setGenreId(int genreId) { this.genreId = genreId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
}

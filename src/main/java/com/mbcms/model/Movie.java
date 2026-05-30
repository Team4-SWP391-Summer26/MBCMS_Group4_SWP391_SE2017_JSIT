package com.mbcms.model;

import java.time.LocalDate;
import java.util.List;

/**
 * Movie - map bang `movies`.
 * Luu y: format/subtitle thuoc `showtimes`, KHONG thuoc movie.
 *
 * rated:  P | C13 | C16 | C18  (BTTT Viet Nam)
 * status: UPCOMING | NOW_SHOWING | ENDED
 */
public class Movie {
    private long movieId;
    private String title;
    private String description;
    private int durationMin;
    private String director;
    private String castList;
    private String language;
    private String country;
    private String rated;
    private String posterUrl;
    private String trailerUrl;
    private LocalDate releaseDate;
    private String status;
    private boolean active = true;

    private List<String> genres; // load khi can (tu movie_genres)

    public Movie() {}

    public long getMovieId() { return movieId; }
    public void setMovieId(long movieId) { this.movieId = movieId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getDurationMin() { return durationMin; }
    public void setDurationMin(int durationMin) { this.durationMin = durationMin; }

    public String getDirector() { return director; }
    public void setDirector(String director) { this.director = director; }

    public String getCastList() { return castList; }
    public void setCastList(String castList) { this.castList = castList; }

    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public String getRated() { return rated; }
    public void setRated(String rated) { this.rated = rated; }

    public String getPosterUrl() { return posterUrl; }
    public void setPosterUrl(String posterUrl) { this.posterUrl = posterUrl; }

    public String getTrailerUrl() { return trailerUrl; }
    public void setTrailerUrl(String trailerUrl) { this.trailerUrl = trailerUrl; }

    public LocalDate getReleaseDate() { return releaseDate; }
    public void setReleaseDate(LocalDate releaseDate) { this.releaseDate = releaseDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public List<String> getGenres() { return genres; }
    public void setGenres(List<String> genres) { this.genres = genres; }
}

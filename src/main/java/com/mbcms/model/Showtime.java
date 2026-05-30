package com.mbcms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Showtime - map bang `showtimes` (suat chieu = movie + room + time).
 * format: 2D | 3D | IMAX ; subtitleType: SUB | DUB | ORIGINAL
 * status: SCHEDULED | CANCELLED | ENDED
 */
public class Showtime {

    public static final String STATUS_SCHEDULED = "SCHEDULED";
    public static final String STATUS_CANCELLED = "CANCELLED";
    public static final String STATUS_ENDED = "ENDED";

    private long showtimeId;
    private long roomId;
    private long movieId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private BigDecimal basePrice;
    private String format;
    private String subtitleType;
    private String status;

    public Showtime() {}

    public long getShowtimeId() { return showtimeId; }
    public void setShowtimeId(long showtimeId) { this.showtimeId = showtimeId; }

    public long getRoomId() { return roomId; }
    public void setRoomId(long roomId) { this.roomId = roomId; }

    public long getMovieId() { return movieId; }
    public void setMovieId(long movieId) { this.movieId = movieId; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }

    public String getFormat() { return format; }
    public void setFormat(String format) { this.format = format; }

    public String getSubtitleType() { return subtitleType; }
    public void setSubtitleType(String subtitleType) { this.subtitleType = subtitleType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}

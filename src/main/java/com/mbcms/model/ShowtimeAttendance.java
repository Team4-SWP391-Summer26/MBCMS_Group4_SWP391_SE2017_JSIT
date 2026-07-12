package com.mbcms.model;

import java.time.LocalDateTime;

/**
 * ShowtimeAttendance - view model (read-only) cho Attendance Tracking cua
 * Branch Staff: moi suat chieu trong ngay kem so ghe da ban va so khach
 * da check-in (dem tu booking_seats.is_checked_in).
 * KHONG map 1-1 voi bang nao — du lieu JOIN showtimes+movies+rooms+booking_seats.
 */
public class ShowtimeAttendance {

    private long showtimeId;
    private String movieTitle;
    private String roomName;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String format;        // 2D / 3D / IMAX
    private String status;        // SCHEDULED / CANCELLED / ENDED
    private int roomCapacity;
    private int bookedSeats;      // ghe thuoc booking CONFIRMED/USED
    private int checkedInSeats;   // ghe da is_checked_in = 1

    public ShowtimeAttendance() {}

    public long getShowtimeId() { return showtimeId; }
    public void setShowtimeId(long showtimeId) { this.showtimeId = showtimeId; }

    public String getMovieTitle() { return movieTitle; }
    public void setMovieTitle(String movieTitle) { this.movieTitle = movieTitle; }

    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    public String getFormat() { return format; }
    public void setFormat(String format) { this.format = format; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getRoomCapacity() { return roomCapacity; }
    public void setRoomCapacity(int roomCapacity) { this.roomCapacity = roomCapacity; }

    public int getBookedSeats() { return bookedSeats; }
    public void setBookedSeats(int bookedSeats) { this.bookedSeats = bookedSeats; }

    public int getCheckedInSeats() { return checkedInSeats; }
    public void setCheckedInSeats(int checkedInSeats) { this.checkedInSeats = checkedInSeats; }

    /** % khach da vao rap so voi so ghe da ban (0 neu chua ban ghe nao). */
    public int getAttendancePercent() {
        if (bookedSeats <= 0) {
            return 0;
        }
        return (int) Math.round(checkedInSeats * 100.0 / bookedSeats);
    }
}

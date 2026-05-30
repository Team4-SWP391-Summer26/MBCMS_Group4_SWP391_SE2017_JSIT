package com.mbcms.model;

/**
 * Seat - map bang `seats` (ghe thuoc 1 room).
 * seatType: STANDARD | VIP | COUPLE ; active=false = bao tri.
 */
public class Seat {

    public static final String TYPE_STANDARD = "STANDARD";
    public static final String TYPE_VIP = "VIP";
    public static final String TYPE_COUPLE = "COUPLE";

    private long seatId;
    private long roomId;
    private String rowLabel;
    private int colNumber;
    private String seatType;
    private boolean active = true;

    public Seat() {}

    public long getSeatId() { return seatId; }
    public void setSeatId(long seatId) { this.seatId = seatId; }

    public long getRoomId() { return roomId; }
    public void setRoomId(long roomId) { this.roomId = roomId; }

    public String getRowLabel() { return rowLabel; }
    public void setRowLabel(String rowLabel) { this.rowLabel = rowLabel; }

    public int getColNumber() { return colNumber; }
    public void setColNumber(int colNumber) { this.colNumber = colNumber; }

    public String getSeatType() { return seatType; }
    public void setSeatType(String seatType) { this.seatType = seatType; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}

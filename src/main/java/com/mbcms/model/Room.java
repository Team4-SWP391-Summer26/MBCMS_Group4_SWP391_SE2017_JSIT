package com.mbcms.model;

/**
 * Room - map bang `rooms` (phong chieu thuoc 1 branch).
 * roomType: STANDARD | VIP | IMAX
 */
public class Room {

    public static final String TYPE_STANDARD = "STANDARD";
    public static final String TYPE_VIP = "VIP";
    public static final String TYPE_IMAX = "IMAX";

    private long roomId;
    private long branchId;
    private String name;
    private int capacity;
    private String roomType;
    private boolean active = true;

    public Room() {}

    public long getRoomId() { return roomId; }
    public void setRoomId(long roomId) { this.roomId = roomId; }

    public long getBranchId() { return branchId; }
    public void setBranchId(long branchId) { this.branchId = branchId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}

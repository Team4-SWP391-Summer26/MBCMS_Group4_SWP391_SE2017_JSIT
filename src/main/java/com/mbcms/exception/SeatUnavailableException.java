package com.mbcms.exception;

import java.util.List;

/**
 * Nem khi 1+ ghe da bi lock boi booking khac tai thoi diem submit.
 */
public class SeatUnavailableException extends RuntimeException {

    private final List<Long> conflictSeatIds;

    public SeatUnavailableException(List<Long> conflictSeatIds) {
        super("Ghe da bi dat: " + conflictSeatIds);
        this.conflictSeatIds = conflictSeatIds;
    }

    public List<Long> getConflictSeatIds() {
        return conflictSeatIds;
    }
}

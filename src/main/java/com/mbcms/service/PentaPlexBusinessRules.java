package com.mbcms.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.List;
import java.math.BigDecimal;

public class PentaPlexBusinessRules {

    public enum DiscountType { PERCENT, FIXED }

    public long calculateFinalAmount(
            long orderAmount,
            DiscountType discountType,
            long discountValue,
            long minimumOrder,
            LocalDate expiryDate,
            LocalDate currentDate) {

        if (orderAmount < 0 || discountValue < 0 || minimumOrder < 0) {
            throw new IllegalArgumentException("Monetary values must not be negative.");
        }
        if (discountType == null || expiryDate == null || currentDate == null) {
            throw new IllegalArgumentException("Promotion data is required.");
        }
        if (currentDate.isAfter(expiryDate) || orderAmount < minimumOrder) {
            return orderAmount;
        }

        long discountAmount;
        if (discountType == DiscountType.PERCENT) {
            long validPercent = Math.min(discountValue, 100);
            discountAmount = orderAmount * validPercent / 100;
        } else {
            discountAmount = Math.min(discountValue, orderAmount);
        }
        return orderAmount - discountAmount;
    }

    public boolean isAgeEligible(
            LocalDate birthDate,
            LocalDate showDate,
            int requiredAge) {

        if (birthDate == null || showDate == null) {
            throw new IllegalArgumentException("Birth date and show date are required.");
        }
        if (birthDate.isAfter(showDate) || requiredAge < 0) {
            throw new IllegalArgumentException("Invalid age-verification data.");
        }
        return Period.between(birthDate, showDate).getYears() >= requiredAge;
    }

    public boolean hasShowtimeConflict(
            LocalDateTime newStart,
            int durationMinutes,
            List<ShowtimeSlot> existingShowtimes) {

        if (newStart == null || existingShowtimes == null) {
            throw new IllegalArgumentException("Showtime data must not be null.");
        }
        if (durationMinutes <= 0) {
            throw new IllegalArgumentException("Duration must be greater than zero.");
        }

        LocalDateTime newEnd = newStart.plusMinutes(durationMinutes);
        for (ShowtimeSlot slot : existingShowtimes) {
            LocalDateTime blockedStart = slot.start().minusMinutes(15);
            LocalDateTime blockedEnd = slot.end().plusMinutes(15);
            if (newStart.isBefore(blockedEnd) && newEnd.isAfter(blockedStart)) {
                return true;
            }
        }
        return false;
    }

    public boolean canCancelShowtime(int successfulBookingCount) {
        if (successfulBookingCount < 0) {
            throw new IllegalArgumentException("Booking count must not be negative.");
        }
        return successfulBookingCount == 0;
    }

    public long calculateChange(long totalAmount, long cashReceived) {
        if (totalAmount < 0 || cashReceived < 0) {
            throw new IllegalArgumentException("Amounts must not be negative.");
        }
        if (cashReceived < totalAmount) {
            throw new IllegalArgumentException("Insufficient cash received.");
        }
        return cashReceived - totalAmount;
    }

    // ── Forgot Password Rules ──────────────────────────────────────────
    
    public boolean verifyOtp(String userCode, String correctHashedToken, long expiryTimeMs, long currentTimeMs, int failedAttemptsCount) {
        if (failedAttemptsCount >= 3) {
            throw new IllegalArgumentException("This verification session has been locked due to too many failed attempts. Please start over.");
        }
        if (currentTimeMs > expiryTimeMs) {
            throw new IllegalArgumentException("Your verification code has expired (15 minutes). Please request a new one.");
        }
        if (userCode == null || userCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Verification code cannot be empty.");
        }
        return org.mindrot.jbcrypt.BCrypt.checkpw(userCode, correctHashedToken);
    }

    public boolean validatePasswordStrength(String password) {
        if (password == null || password.length() < 8) {
            throw new IllegalArgumentException("Password must be at least 8 characters long.");
        }
        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;
        boolean hasSpecial = false;
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            else if (Character.isLowerCase(c)) hasLower = true;
            else if (Character.isDigit(c)) hasDigit = true;
            else if ("!@#$%^&*()_+-=[]{}|;':\",./<>?".indexOf(c) >= 0) hasSpecial = true;
        }
        if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
            throw new IllegalArgumentException("Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character.");
        }
        return true;
    }

    // ── F&B Management Rules ───────────────────────────────────────────
    
    public boolean validateFoodItem(String name, BigDecimal price, int stock) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Ten mon khong duoc de trong.");
        }
        if (price == null || price.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Gia khong hop le.");
        }
        if (stock < 0) {
            throw new IllegalArgumentException("Ton kho khong duoc am.");
        }
        return true;
    }

    // ── Track Occupancy & Monitor Booking Status Rules ────────────────
    
    public String transitionBookingStatus(String currentStatus, String event) {
        if (currentStatus == null || event == null) {
            throw new IllegalArgumentException("Status and event must not be null.");
        }
        switch (currentStatus) {
            case "PENDING":
                if ("PAY_SUCCESS".equals(event)) return "CONFIRMED";
                if ("PAY_TIMEOUT".equals(event)) return "EXPIRED";
                if ("USER_CANCEL".equals(event)) return "CANCELLED";
                break;
            case "CONFIRMED":
                if ("PRINT_TICKET".equals(event)) return "USED";
                if ("USER_CANCEL".equals(event)) return "CANCELLED";
                break;
            case "USED":
                break;
            case "CANCELLED":
            case "EXPIRED":
                break;
        }
        throw new IllegalArgumentException("Invalid state transition from " + currentStatus + " on " + event);
    }

    public double calculateOccupancyPercentage(int bookedSeats, int totalSeats) {
        if (totalSeats <= 0) {
            throw new IllegalArgumentException("Total seats must be greater than zero.");
        }
        if (bookedSeats < 0 || bookedSeats > totalSeats) {
            throw new IllegalArgumentException("Booked seats count is invalid.");
        }
        return (double) bookedSeats * 100.0 / totalSeats;
    }

    public record ShowtimeSlot(LocalDateTime start, LocalDateTime end) {
        public ShowtimeSlot {
            if (start == null || end == null || !end.isAfter(start)) {
                throw new IllegalArgumentException("Invalid showtime slot.");
            }
        }
    }
}

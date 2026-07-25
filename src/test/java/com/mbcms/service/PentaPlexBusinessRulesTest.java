package com.mbcms.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import com.mbcms.service.PentaPlexBusinessRules.DiscountType;
import com.mbcms.service.PentaPlexBusinessRules.ShowtimeSlot;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * PentaPlexBusinessRulesTest - JUnit 5 Version
 * Matches 31 test cases from Ngo Duc Anh's Excel sheet.
 * 
 * @author Phạm Quốc Anh
 */
public class PentaPlexBusinessRulesTest {
    
    private final PentaPlexBusinessRules service = new PentaPlexBusinessRules();
    
    public PentaPlexBusinessRulesTest() {
    }

    // ==========================================
    // UT-F01: calculateFinalAmount (7 Cases)
    // ==========================================
    
    @Test
    public void testCalculateFinalAmount_UTCID01() {
        // UTCID01: order < minOrder -> no discount (199,999 < 200,000)
        assertEquals(199999, service.calculateFinalAmount(199999, DiscountType.PERCENT, 10, 200000, LocalDate.parse("2026-07-31"), LocalDate.parse("2026-07-13")));
    }

    @Test
    public void testCalculateFinalAmount_UTCID02() {
        // UTCID02: order == minOrder -> discount 10% (200,000 -> 180,000)
        assertEquals(180000, service.calculateFinalAmount(200000, DiscountType.PERCENT, 10, 200000, LocalDate.parse("2026-07-31"), LocalDate.parse("2026-07-13")));
    }

    @Test
    public void testCalculateFinalAmount_UTCID03() {
        // UTCID03: order > minOrder -> discount 10% (200,001 -> 180,001)
        assertEquals(180001, service.calculateFinalAmount(200001, DiscountType.PERCENT, 10, 200000, LocalDate.parse("2026-07-31"), LocalDate.parse("2026-07-13")));
    }

    @Test
    public void testCalculateFinalAmount_UTCID04() {
        // UTCID04: order >> minOrder -> discount 10% (500,000 -> 450,000)
        assertEquals(450000, service.calculateFinalAmount(500000, DiscountType.PERCENT, 10, 200000, LocalDate.parse("2026-07-31"), LocalDate.parse("2026-07-13")));
    }

    @Test
    public void testCalculateFinalAmount_UTCID05() {
        // UTCID05: current date after expiry date -> no discount
        assertEquals(200000, service.calculateFinalAmount(200000, DiscountType.PERCENT, 10, 200000, LocalDate.parse("2026-07-12"), LocalDate.parse("2026-07-13")));
    }

    @Test
    public void testCalculateFinalAmount_UTCID06() {
        // UTCID06: fixed amount discount (discount > order) -> final is 0
        assertEquals(0, service.calculateFinalAmount(100000, DiscountType.FIXED, 150000, 0, LocalDate.parse("2026-07-31"), LocalDate.parse("2026-07-13")));
    }

    @Test
    public void testCalculateFinalAmount_UTCID07() {
        // UTCID07: negative amount input -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.calculateFinalAmount(-1, DiscountType.PERCENT, 10, 0, LocalDate.of(2026, 7, 31), LocalDate.of(2026, 7, 13))
        );
        assertEquals("Monetary values must not be negative.", ex.getMessage());
    }

    // ==========================================
    // UT-F02: testIsAgeEligible (7 Cases)
    // ==========================================

    @Test
    public void testIsAgeEligible_UTCID01() {
        // UTCID01: 13 years old minus 1 day -> false
        assertFalse(service.isAgeEligible(LocalDate.parse("2013-07-14"), LocalDate.parse("2026-07-13"), 13));
    }

    @Test
    public void testIsAgeEligible_UTCID02() {
        // UTCID02: 13 years old exact -> true
        assertTrue(service.isAgeEligible(LocalDate.parse("2013-07-13"), LocalDate.parse("2026-07-13"), 13));
    }

    @Test
    public void testIsAgeEligible_UTCID03() {
        // UTCID03: 13 years old plus 1 day -> true
        assertTrue(service.isAgeEligible(LocalDate.parse("2013-07-12"), LocalDate.parse("2026-07-13"), 13));
    }

    @Test
    public void testIsAgeEligible_UTCID04() {
        // UTCID04: 16 years old exact -> true
        assertTrue(service.isAgeEligible(LocalDate.parse("2010-07-13"), LocalDate.parse("2026-07-13"), 16));
    }

    @Test
    public void testIsAgeEligible_UTCID05() {
        // UTCID05: 18 years old exact -> true
        assertTrue(service.isAgeEligible(LocalDate.parse("2008-07-13"), LocalDate.parse("2026-07-13"), 18));
    }

    @Test
    public void testIsAgeEligible_UTCID06() {
        // UTCID06: 18 years old minus 1 day -> false
        assertFalse(service.isAgeEligible(LocalDate.parse("2008-07-14"), LocalDate.parse("2026-07-13"), 18));
    }

    @Test
    public void testIsAgeEligible_UTCID07() {
        // UTCID07: future birth date -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.isAgeEligible(LocalDate.of(2027, 1, 1), LocalDate.of(2026, 7, 13), 13)
        );
        assertEquals("Invalid age-verification data.", ex.getMessage());
    }

    // ==========================================
    // UT-F03: testHasShowtimeConflict (7 Cases)
    // ==========================================

    private List<ShowtimeSlot> getExistingShowtime() {
        return List.of(
            new ShowtimeSlot(
                LocalDateTime.of(2026, 7, 13, 10, 0),
                LocalDateTime.of(2026, 7, 13, 12, 0)
            )
        );
    }

    @Test
    public void testHasShowtimeConflict_UTCID01() {
        // UTCID01: overlap with the 15-minute gap before/after (new start is 12:14 -> overlap)
        assertTrue(service.hasShowtimeConflict(LocalDateTime.parse("2026-07-13T12:14"), 120, getExistingShowtime()));
    }

    @Test
    public void testHasShowtimeConflict_UTCID02() {
        // UTCID02: no overlap (new start is 12:15 -> no overlap)
        assertFalse(service.hasShowtimeConflict(LocalDateTime.parse("2026-07-13T12:15"), 120, getExistingShowtime()));
    }

    @Test
    public void testHasShowtimeConflict_UTCID03() {
        // UTCID03: no overlap (new start is 12:16 -> no overlap)
        assertFalse(service.hasShowtimeConflict(LocalDateTime.parse("2026-07-13T12:16"), 120, getExistingShowtime()));
    }

    @Test
    public void testHasShowtimeConflict_UTCID04() {
        // UTCID04: overlaps existing showtime interval -> true
        assertTrue(service.hasShowtimeConflict(LocalDateTime.parse("2026-07-13T11:30"), 120, getExistingShowtime()));
    }

    @Test
    public void testHasShowtimeConflict_UTCID05() {
        // UTCID05: no overlap (new showtime ends at 09:00 -> no overlap)
        assertFalse(service.hasShowtimeConflict(LocalDateTime.parse("2026-07-13T08:00"), 60, getExistingShowtime()));
    }

    @Test
    public void testHasShowtimeConflict_UTCID06() {
        // UTCID06: new showtime starts at 12:00 exact -> overlaps the 15-minute gap -> true
        assertTrue(service.hasShowtimeConflict(LocalDateTime.parse("2026-07-13T12:00"), 120, getExistingShowtime()));
    }

    @Test
    public void testHasShowtimeConflict_UTCID07() {
        // UTCID07: zero duration -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.hasShowtimeConflict(LocalDateTime.of(2026, 7, 13, 12, 15), 0, List.of())
        );
        assertEquals("Duration must be greater than zero.", ex.getMessage());
    }

    // ==========================================
    // UT-F04: testCanCancelShowtime (4 Cases)
    // ==========================================

    @Test
    public void testCanCancelShowtime_UTCID01() {
        // UTCID01: booking count is 0 -> cancellation is allowed
        assertTrue(service.canCancelShowtime(0));
    }

    @Test
    public void testCanCancelShowtime_UTCID02() {
        // UTCID02: booking count is 1 -> cancellation not allowed
        assertFalse(service.canCancelShowtime(1));
    }

    @Test
    public void testCanCancelShowtime_UTCID03() {
        // UTCID03: booking count is 100 -> cancellation not allowed
        assertFalse(service.canCancelShowtime(100));
    }

    @Test
    public void testCanCancelShowtime_UTCID04() {
        // UTCID04: negative booking count -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.canCancelShowtime(-1)
        );
        assertEquals("Booking count must not be negative.", ex.getMessage());
    }

    // ==========================================
    // UT-F05: testCalculateChange (6 Cases)
    // ==========================================

    @Test
    public void testCalculateChange_UTCID01() {
        // UTCID01: large cash amount thối -> change is 800000
        assertEquals(800000, service.calculateChange(200000, 1000000));
    }

    @Test
    public void testCalculateChange_UTCID02() {
        // UTCID02: exact cash amount -> change is 0
        assertEquals(0, service.calculateChange(200000, 200000));
    }

    @Test
    public void testCalculateChange_UTCID03() {
        // UTCID03: cash is total + 1 -> change is 1
        assertEquals(1, service.calculateChange(200000, 200001));
    }

    @Test
    public void testCalculateChange_UTCID04() {
        // UTCID04: cash is total + 300000 -> change is 300000
        assertEquals(300000, service.calculateChange(200000, 500000));
    }

    @Test
    public void testCalculateChange_UTCID05() {
        // UTCID05: insufficient cash -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.calculateChange(200000, 199999)
        );
        assertEquals("Insufficient cash received.", ex.getMessage());
    }

    @Test
    public void testCalculateChange_UTCID06() {
        // UTCID06: negative cash received -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.calculateChange(200000, -1)
        );
        assertEquals("Amounts must not be negative.", ex.getMessage());
    }

    // ==========================================
    // UT-F06: Forgot Password OTP (5 Cases)
    // ==========================================

    @Test
    public void testVerifyOtp_Success() {
        // Correct OTP, valid time, 0 failed attempts
        String userCode = "123456";
        String correctHash = org.mindrot.jbcrypt.BCrypt.hashpw(userCode, org.mindrot.jbcrypt.BCrypt.gensalt(10));
        assertTrue(service.verifyOtp(userCode, correctHash, 100000, 50000, 0));
    }

    @Test
    public void testVerifyOtp_Incorrect() {
        // Incorrect OTP, valid time, 0 failed attempts -> returns false
        String userCode = "123456";
        String correctHash = org.mindrot.jbcrypt.BCrypt.hashpw("654321", org.mindrot.jbcrypt.BCrypt.gensalt(10));
        assertFalse(service.verifyOtp(userCode, correctHash, 100000, 50000, 0));
    }

    @Test
    public void testVerifyOtp_Expired() {
        // Expired OTP -> throws IllegalArgumentException
        String userCode = "123456";
        String correctHash = org.mindrot.jbcrypt.BCrypt.hashpw(userCode, org.mindrot.jbcrypt.BCrypt.gensalt(10));
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.verifyOtp(userCode, correctHash, 100000, 100001, 0)
        );
        assertEquals("Your verification code has expired (15 minutes). Please request a new one.", ex.getMessage());
    }

    @Test
    public void testVerifyOtp_LockedOut() {
        // 3 failed attempts (locked out) -> throws IllegalArgumentException
        String userCode = "123456";
        String correctHash = org.mindrot.jbcrypt.BCrypt.hashpw(userCode, org.mindrot.jbcrypt.BCrypt.gensalt(10));
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.verifyOtp(userCode, correctHash, 100000, 50000, 3)
        );
        assertEquals("This verification session has been locked due to too many failed attempts. Please start over.", ex.getMessage());
    }

    @Test
    public void testVerifyOtp_Empty() {
        // Empty user code -> throws IllegalArgumentException
        String correctHash = org.mindrot.jbcrypt.BCrypt.hashpw("123456", org.mindrot.jbcrypt.BCrypt.gensalt(10));
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.verifyOtp("", correctHash, 100000, 50000, 0)
        );
        assertEquals("Verification code cannot be empty.", ex.getMessage());
    }

    // ==========================================
    // UT-F07: Password Strength (6 Cases)
    // ==========================================

    @Test
    public void testValidatePasswordStrength_Success() {
        // Valid strong password -> returns true
        assertTrue(service.validatePasswordStrength("StrongP@ss1"));
    }

    @Test
    public void testValidatePasswordStrength_TooShort() {
        // Too short -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.validatePasswordStrength("P@ss1")
        );
        assertEquals("Password must be at least 8 characters long.", ex.getMessage());
    }

    @Test
    public void testValidatePasswordStrength_NoUpper() {
        // No uppercase -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.validatePasswordStrength("strongp@ss1")
        );
        assertTrue(ex.getMessage().contains("Password must contain at least one"));
    }

    @Test
    public void testValidatePasswordStrength_NoLower() {
        // No lowercase -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.validatePasswordStrength("STRONGP@SS1")
        );
        assertTrue(ex.getMessage().contains("Password must contain at least one"));
    }

    @Test
    public void testValidatePasswordStrength_NoDigit() {
        // No digit -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.validatePasswordStrength("StrongP@ssx")
        );
        assertTrue(ex.getMessage().contains("Password must contain at least one"));
    }

    @Test
    public void testValidatePasswordStrength_NoSpecial() {
        // No special char -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.validatePasswordStrength("StrongPass1")
        );
        assertTrue(ex.getMessage().contains("Password must contain at least one"));
    }

    // ==========================================
    // UT-F08: F&B Item Validation (4 Cases)
    // ==========================================

    @Test
    public void testValidateFoodItem_Success() {
        // Valid food item -> returns true
        assertTrue(service.validateFoodItem("Combo Bap Nuoc", new java.math.BigDecimal("99000"), 50));
    }

    @Test
    public void testValidateFoodItem_EmptyName() {
        // Empty name -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.validateFoodItem("   ", new java.math.BigDecimal("99000"), 50)
        );
        assertEquals("Ten mon khong duoc de trong.", ex.getMessage());
    }

    @Test
    public void testValidateFoodItem_NegativePrice() {
        // Negative price -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.validateFoodItem("Combo Bap Nuoc", new java.math.BigDecimal("-1"), 50)
        );
        assertEquals("Gia khong hop le.", ex.getMessage());
    }

    @Test
    public void testValidateFoodItem_NegativeStock() {
        // Negative stock -> throws IllegalArgumentException
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.validateFoodItem("Combo Bap Nuoc", new java.math.BigDecimal("99000"), -5)
        );
        assertEquals("Ton kho khong duoc am.", ex.getMessage());
    }

    // ==========================================
    // UT-F09: Booking State Transitions (6 Cases)
    // ==========================================

    @Test
    public void testTransitionBookingStatus_Confirm() {
        assertEquals("CONFIRMED", service.transitionBookingStatus("PENDING", "PAY_SUCCESS"));
    }

    @Test
    public void testTransitionBookingStatus_Expire() {
        assertEquals("EXPIRED", service.transitionBookingStatus("PENDING", "PAY_TIMEOUT"));
    }

    @Test
    public void testTransitionBookingStatus_CancelPending() {
        assertEquals("CANCELLED", service.transitionBookingStatus("PENDING", "USER_CANCEL"));
    }

    @Test
    public void testTransitionBookingStatus_Use() {
        assertEquals("USED", service.transitionBookingStatus("CONFIRMED", "PRINT_TICKET"));
    }

    @Test
    public void testTransitionBookingStatus_CancelConfirmed() {
        assertEquals("CANCELLED", service.transitionBookingStatus("CONFIRMED", "USER_CANCEL"));
    }

    @Test
    public void testTransitionBookingStatus_Invalid() {
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> 
            service.transitionBookingStatus("USED", "PAY_SUCCESS")
        );
        assertTrue(ex.getMessage().contains("Invalid state transition"));
    }

    // ==========================================
    // UT-F10: Occupancy Calculations (6 Cases)
    // ==========================================

    @Test
    public void testCalculateOccupancyPercentage_Half() {
        assertEquals(50.0, service.calculateOccupancyPercentage(50, 100));
    }

    @Test
    public void testCalculateOccupancyPercentage_Zero() {
        assertEquals(0.0, service.calculateOccupancyPercentage(0, 120));
    }

    @Test
    public void testCalculateOccupancyPercentage_Full() {
        assertEquals(100.0, service.calculateOccupancyPercentage(150, 150));
    }

    @Test
    public void testCalculateOccupancyPercentage_NegativeBooked() {
        assertThrows(IllegalArgumentException.class, () -> 
            service.calculateOccupancyPercentage(-1, 100)
        );
    }

    @Test
    public void testCalculateOccupancyPercentage_BookedOverTotal() {
        assertThrows(IllegalArgumentException.class, () -> 
            service.calculateOccupancyPercentage(101, 100)
        );
    }

    @Test
    public void testCalculateOccupancyPercentage_TotalZero() {
        assertThrows(IllegalArgumentException.class, () -> 
            service.calculateOccupancyPercentage(0, 0)
        );
    }
}

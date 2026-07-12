package com.mbcms.util;

import java.util.Set;
import java.util.regex.Pattern;

/**
 * ValidationUtil - Cac ham validate dung chung
 */
public class ValidationUtil {

    private static final Pattern EMAIL_PATTERN
            = Pattern.compile("^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$");

    private static final Pattern PHONE_PATTERN
            = Pattern.compile("^(0|\\+84)[3-9][0-9]{8}$");

    /** Whitelist thanh pho VN pho bien (branch city). */
    private static final Set<String> VN_CITIES = Set.of(
            "Ha Noi", "Hà Nội",
            "TP. Ho Chi Minh", "TP. Hồ Chí Minh", "Ho Chi Minh", "Hồ Chí Minh",
            "Da Nang", "Đà Nẵng",
            "Hai Phong", "Hải Phòng",
            "Can Tho", "Cần Thơ",
            "Hue", "Huế",
            "Nha Trang",
            "Vung Tau", "Vũng Tàu",
            "Bien Hoa", "Biên Hòa",
            "Buon Ma Thuot", "Buôn Ma Thuột",
            "Quy Nhon", "Quy Nhơn",
            "Thai Nguyen", "Thái Nguyên",
            "Nam Dinh", "Nam Định",
            "Vinh"
    );

    private ValidationUtil() {
    }

    public static boolean isValidVnCity(String city) {
        if (city == null) {
            return false;
        }
        String t = city.trim();
        if (t.isEmpty() || t.length() > 50) {
            return false;
        }
        for (String allowed : VN_CITIES) {
            if (allowed.equalsIgnoreCase(t)) {
                return true;
            }
        }
        return false;
    }

    /** Canonical city label from whitelist, or null if invalid. */
    public static String normalizeVnCity(String city) {
        if (city == null) {
            return null;
        }
        String t = city.trim();
        for (String allowed : VN_CITIES) {
            if (allowed.equalsIgnoreCase(t)) {
                return allowed;
            }
        }
        return null;
    }

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    /**
     * Password: toi thieu 8 ky tu, co chu hoa, chu thuong, so
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        boolean hasUpper = false, hasLower = false, hasDigit = false;
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) {
                hasUpper = true;
            } else if (Character.isLowerCase(c)) {
                hasLower = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            }
        }
        return hasUpper && hasLower && hasDigit;
    }

    /**
     * So di dong Viet Nam: 10 so bat dau bang 0 (vd 0981234567) hoac tien to
     * quoc te +84 (vd +84981234567). Cho phep nguoi dung go kem dau cach /
     * gach ngang / dau cham (0981 234 567) - se strip truoc khi validate.
     * (Chua ho tro so ban co dinh - ngoai pham vi.)
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null) return false;
        return PHONE_PATTERN.matcher(normalizePhone(phone)).matches();
    }

    /**
     * Chuan hoa so dien thoai ve dang khong dau cach/gach/cham de LUU DB dong
     * nhat (vd "098 123 4567" -> "0981234567"). Tra ve null neu input rong.
     */
    public static String normalizePhone(String phone) {
        if (phone == null) return null;
        String normalized = phone.trim().replaceAll("[\\s\\-.]", "");
        return normalized.isEmpty() ? null : normalized;
    }

    public static boolean isNullOrEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}
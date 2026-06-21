package com.mbcms.service.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.dao.impl.PromotionDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.model.Promotion;
import com.mbcms.service.BookingService;

import java.math.BigDecimal;
import java.util.List;

/**
 * BookingServiceImpl - Trien khai logic nghiệp vụ dat ve.
 */
public class BookingServiceImpl implements BookingService {

    private final BookingDAO bookingDAO;
    private final CustomerDAO customerDAO;
    private final PromotionDAO promotionDAO;

    public BookingServiceImpl() {
        this.bookingDAO = new BookingDAOImpl();
        this.customerDAO = new CustomerDAOImpl();
        this.promotionDAO = new PromotionDAOImpl();
    }

    public BookingServiceImpl(BookingDAO bookingDAO, CustomerDAO customerDAO, PromotionDAO promotionDAO) {
        this.bookingDAO = bookingDAO;
        this.customerDAO = customerDAO;
        this.promotionDAO = promotionDAO;
    }

    @Override
    public Booking createCounterBooking(Booking booking, List<Long> seatIds, String promoCode, String customerPhone) {
        // 1. Tim kiem thanh vien bang SĐT (neu khong co -> mac dinh guest01)
        String username = "guest01";
        if (customerPhone != null && !customerPhone.trim().isEmpty()) {
            Customer member = customerDAO.findByPhone(customerPhone.trim());
            if (member != null) {
                username = member.getUsername();
            }
        }
        booking.setCustomerUsername(username);

        // 2. Ap dung ma khuyen mai neu co
        Long promoId = null;
        BigDecimal discount = BigDecimal.ZERO;
        if (promoCode != null && !promoCode.trim().isEmpty()) {
            Promotion promo = promotionDAO.findByCode(promoCode.trim().toUpperCase());
            if (promo != null && promo.isActive() && "Active".equals(promo.getStatus())) {
                BigDecimal minAmt = promo.getMinOrderAmount();
                // Kiem tra gia tri don hang toi thieu
                if (minAmt == null || booking.getSubtotal().compareTo(minAmt) >= 0) {
                    promoId = promo.getPromoId();
                    if (Promotion.TYPE_PERCENT.equals(promo.getDiscountType())) {
                        discount = booking.getSubtotal()
                                .multiply(promo.getDiscountValue())
                                .divide(BigDecimal.valueOf(100), 0, java.math.RoundingMode.HALF_UP);
                    } else if (Promotion.TYPE_FIXED_AMOUNT.equals(promo.getDiscountType())) {
                        discount = promo.getDiscountValue();
                    }

                    // Khong duoc giam nhieu hon gia tri don hang
                    if (discount.compareTo(booking.getSubtotal()) > 0) {
                        discount = booking.getSubtotal();
                    }
                }
            }
        }
        booking.setPromoId(promoId);
        booking.setDiscountAmount(discount);
        booking.setTotalAmount(booking.getSubtotal().subtract(discount));

        // 3. Goi DAO ghi nhan Booking + Seats + CASH Payment trong 1 transaction
        return bookingDAO.createCounterBooking(booking, seatIds);
    }
}

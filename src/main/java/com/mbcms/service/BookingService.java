/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mbcms.service;

/**
 *
 * @author Lenovo
 */
import com.mbcms.model.Booking;
import java.util.List;

public interface BookingService {

    /**
     * Xử lý đặt vé tại quầy cho nhân viên (Branch Staff). Bao gồm: kiểm tra ghế
     * trống, áp dụng khuyến mãi, liên kết thành viên, và thanh toán tiền mặt
     * thành công (CASH) trong 1 Transaction.
     */
    Booking createCounterBooking(Booking booking, List<Long> seatIds, String promoCode, String customerPhone);
}

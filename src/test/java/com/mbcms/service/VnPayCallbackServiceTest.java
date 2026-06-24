package com.mbcms.service;

import com.mbcms.dao.BookingDAO;
import com.mbcms.model.Booking;
import com.mbcms.model.Payment;
import com.mbcms.util.VnPayUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VnPayCallbackServiceTest {

    @Mock private PaymentService paymentService;
    @Mock private BookingDAO bookingDao;

    private VnPayCallbackService service;

    @BeforeEach
    void setUp() {
        service = new VnPayCallbackService(paymentService, bookingDao);
    }

    @Test
    void process_returnsAmountMismatchWhenVnpAmountMissing() {
        Booking booking = new Booking();
        booking.setBookingId(99L);
        booking.setCustomerUsername("cust1");
        booking.setTotalAmount(new BigDecimal("100000"));
        booking.setStatus(Booking.STATUS_PENDING);

        when(bookingDao.findById(99L)).thenReturn(booking);

        Map<String, String> params = new HashMap<>();
        params.put("vnp_TxnRef", "BK99");
        params.put("vnp_ResponseCode", "00");
        params.put("vnp_TransactionStatus", "00");

        try (MockedStatic<VnPayUtil> vnPay = mockStatic(VnPayUtil.class)) {
            vnPay.when(() -> VnPayUtil.verifyReturn(anyMap())).thenReturn(true);
            vnPay.when(() -> VnPayUtil.parseBookingId("BK99")).thenReturn(99L);
            vnPay.when(() -> VnPayUtil.isSuccessResponse("00", "00")).thenReturn(true);

            VnPayCallbackService.Result result = service.process(params);
            assertEquals(VnPayCallbackService.Outcome.AMOUNT_MISMATCH, result.getOutcome());
        }
    }

    @Test
    void process_returnsAmountMismatchWhenVnpAmountDiffers() {
        Booking booking = new Booking();
        booking.setBookingId(42L);
        booking.setCustomerUsername("cust1");
        booking.setTotalAmount(new BigDecimal("150000"));
        booking.setStatus(Booking.STATUS_PENDING);

        when(bookingDao.findById(42L)).thenReturn(booking);

        Map<String, String> params = new HashMap<>();
        params.put("vnp_TxnRef", "BK42");
        params.put("vnp_ResponseCode", "00");
        params.put("vnp_TransactionStatus", "00");
        params.put("vnp_Amount", "20000000");

        try (MockedStatic<VnPayUtil> vnPay = mockStatic(VnPayUtil.class)) {
            vnPay.when(() -> VnPayUtil.verifyReturn(anyMap())).thenReturn(true);
            vnPay.when(() -> VnPayUtil.parseBookingId("BK42")).thenReturn(42L);
            vnPay.when(() -> VnPayUtil.isSuccessResponse("00", "00")).thenReturn(true);

            VnPayCallbackService.Result result = service.process(params);
            assertEquals(VnPayCallbackService.Outcome.AMOUNT_MISMATCH, result.getOutcome());
        }
    }

    @Test
    void process_acceptsMatchingAmount() {
        Booking booking = new Booking();
        booking.setBookingId(7L);
        booking.setCustomerUsername("cust1");
        booking.setTotalAmount(new BigDecimal("99000"));
        booking.setStatus(Booking.STATUS_PENDING);

        when(bookingDao.findById(7L)).thenReturn(booking);
        when(paymentService.markPaymentSuccess(7L, Payment.METHOD_VNPAY, "cust1", "TXN1"))
                .thenReturn(PaymentService.Result.SUCCESS);
        when(bookingDao.findByIdWithSeats(7L)).thenReturn(booking);

        Map<String, String> params = new HashMap<>();
        params.put("vnp_TxnRef", "BK7");
        params.put("vnp_ResponseCode", "00");
        params.put("vnp_TransactionStatus", "00");
        params.put("vnp_Amount", "9900000");
        params.put("vnp_TransactionNo", "TXN1");

        try (MockedStatic<VnPayUtil> vnPay = mockStatic(VnPayUtil.class)) {
            vnPay.when(() -> VnPayUtil.verifyReturn(anyMap())).thenReturn(true);
            vnPay.when(() -> VnPayUtil.parseBookingId("BK7")).thenReturn(7L);
            vnPay.when(() -> VnPayUtil.isSuccessResponse("00", "00")).thenReturn(true);

            VnPayCallbackService.Result result = service.process(params);
            assertEquals(VnPayCallbackService.Outcome.SUCCESS, result.getOutcome());
        }
    }
}

package com.mbcms.service.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.model.Booking;
import com.mbcms.model.Showtime;
import com.mbcms.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BookingServiceImplTest {

    @Mock private BookingDAO bookingDao;
    @Mock private SeatDAO seatDao;
    @Mock private ShowtimeDAO showtimeDao;
    @Mock private PromotionDAO promoDao;
    @Mock private NotificationService notificationService;

    private BookingServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new BookingServiceImpl(bookingDao, seatDao, showtimeDao, promoDao, notificationService);
    }

    @Test
    void createPendingBooking_rejectsMoreThan8Seats() {
        List<Long> nineSeats = List.of(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L);
        assertThrows(IllegalArgumentException.class,
                () -> service.createPendingBooking("user1", 1L, nineSeats, null, null, null));
    }

    @Test
    void createCounterBooking_rejectsPastShowtime() {
        Showtime past = new Showtime();
        past.setShowtimeId(1L);
        past.setStatus("SCHEDULED");
        past.setStartTime(LocalDateTime.now(ZoneOffset.UTC).minusHours(1));
        when(showtimeDao.findById(anyLong())).thenReturn(past);

        Booking booking = new Booking();
        booking.setShowtimeId(1L);
        booking.setSubtotal(BigDecimal.valueOf(100_000));

        assertThrows(IllegalArgumentException.class,
                () -> service.createCounterBooking(booking, List.of(1L), null, null));
    }

    @Test
    void createCounterBooking_rejectsCancelledShowtime() {
        Showtime cancelled = new Showtime();
        cancelled.setShowtimeId(1L);
        cancelled.setStatus("CANCELLED");
        cancelled.setStartTime(LocalDateTime.now(ZoneOffset.UTC).plusHours(2));
        when(showtimeDao.findById(anyLong())).thenReturn(cancelled);

        Booking booking = new Booking();
        booking.setShowtimeId(1L);
        booking.setSubtotal(BigDecimal.valueOf(100_000));

        assertThrows(IllegalArgumentException.class,
                () -> service.createCounterBooking(booking, Collections.singletonList(1L), null, null));
    }
}

package com.mbcms.util;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.NotificationService;
import com.mbcms.service.impl.NotificationServiceImpl;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * ShowtimeReminderScheduler - tu dong gui thong bao nhac nho suất chieu.
 *
 * Chay moi 5 phut. Tim CONFIRMED booking co showtime bat dau trong khoang
 * 60 phut ke tiep va chua gui reminder, roi gui thong bao + email.
 *
 * Pattern giong BookingExpiryScheduler: @WebListener + ScheduledExecutorService.
 * Dedup: dung existsReminderForBooking() de tranh gui trung lap.
 */
@WebListener
public class ShowtimeReminderScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    private final NotificationService notificationService = new NotificationServiceImpl();
    private final BookingDAO          bookingDAO          = new BookingDAOImpl();
    private final CustomerDAO         customerDAO         = new CustomerDAOImpl();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "showtime-reminder-scheduler");
            t.setDaemon(true);
            return t;
        });

        // Chay lan dau sau 1 phut, sau do moi 5 phut
        scheduler.scheduleAtFixedRate(this::sendReminders, 1, 5, TimeUnit.MINUTES);
        System.out.println("[ShowtimeReminderScheduler] Khoi dong – kiem tra moi 5 phut.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            System.out.println("[ShowtimeReminderScheduler] Tat.");
        }
    }

    // ── Core logic ────────────────────────────────────────────────────────────

    private void sendReminders() {
        try {
            // Lay cac booking CONFIRMED co showtime bat dau trong 30–60 phut nua
            // (window 30 phut de tranh gui qua som, nhung du thoi gian di den rap)
            List<Booking> bookings = bookingDAO.findConfirmedForReminder(5, 20);
            if (bookings == null || bookings.isEmpty()) return;

            int sent = 0;
            for (Booking booking : bookings) {
                try {
                    String email = getCustomerEmail(booking.getCustomerUsername());
                    boolean wasSent = notificationService.sendReminderIfNotSent(
                            booking,
                            email,
                            booking.getMovieTitle(),
                            booking.getShowtimeStartTime()
                    );
                    if (wasSent) sent++;
                } catch (Exception e) {
                    System.err.println("[ShowtimeReminderScheduler] Loi gui reminder cho booking "
                            + booking.getBookingId() + ": " + e.getMessage());
                }
            }

            if (sent > 0) {
                System.out.println("[ShowtimeReminderScheduler] Da gui " + sent + " reminder.");
            }
        } catch (Exception e) {
            System.err.println("[ShowtimeReminderScheduler] Loi: " + e.getMessage());
        }
    }

    private String getCustomerEmail(String username) {
        try {
            Customer c = customerDAO.findByUsername(username);
            return c != null ? c.getEmail() : null;
        } catch (Exception e) {
            return null;
        }
    }
}

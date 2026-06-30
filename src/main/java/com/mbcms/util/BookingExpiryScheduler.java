package com.mbcms.util;

import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * BookingExpiryScheduler:
 *  1. Tu dong giai phong PENDING booking qua 10 phut (releaseExpiredLocks).
 *  2. Tu dong danh dau CONFIRMED -> USED khi suat chieu da bat dau qua 30
 *     phut (markCompletedBookingsAsUsed).
 *
 * Chay moi 60 giay. Duoc khoi dong khi deploy, tat khi undeploy.
 *
 * Dang ky: @WebListener (tu dong phat hien boi servlet container).
 * Khong can khai bao them trong web.xml.
 */
@WebListener
public class BookingExpiryScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;
    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "booking-expiry-scheduler");
            t.setDaemon(true);
            return t;
        });

        scheduler.scheduleAtFixedRate(() -> {
            try {
                int released = bookingService.releaseExpiredLocks();
                if (released > 0) {
                    System.out.println("[BookingExpiryScheduler] Giai phong "
                        + released + " booking het han.");
                }
            } catch (Exception e) {
                System.err.println("[BookingExpiryScheduler] Loi: " + e.getMessage());
            }

            try {
                int used = bookingService.markCompletedBookingsAsUsed();
                if (used > 0) {
                    System.out.println("[BookingExpiryScheduler] Danh dau "
                        + used + " booking CONFIRMED -> USED (qua 30 phut chieu).");
                }
            } catch (Exception e) {
                System.err.println("[BookingExpiryScheduler] Loi markCompletedBookingsAsUsed: " + e.getMessage());
            }
        }, 60, 60, TimeUnit.SECONDS);

        System.out.println("[BookingExpiryScheduler] Khoi dong - kiem tra moi 60 giay.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            System.out.println("[BookingExpiryScheduler] Tat.");
        }
    }
}
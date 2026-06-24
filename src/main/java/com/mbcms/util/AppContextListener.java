package com.mbcms.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * AppContextListener - Khoi dong va tat ung dung - Start: khoi dong DBCP2 pool
 * - Destroy: dong pool de tranh leak
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        DBUtil.reinitialize();
        // Cache-busting token cho tai nguyen tinh (CSS/JS): doi moi lan khoi dong/redeploy
        // -> trinh duyet luon nap ban moi sau khi deploy, khong dung CSS cu trong cache.
        // Truoc day attribute nay khong duoc set -> "?v=" co dinh -> CSS bi cache vinh vien.
        sce.getServletContext().setAttribute("assetVersion",
                String.valueOf(System.currentTimeMillis()));
        System.out.println("[MBCMS] Ung dung khoi dong - DBCP2 pool ready");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DBUtil.shutdown();
        System.out.println("[MBCMS] Ung dung tat - DBCP2 pool dong");
    }
}

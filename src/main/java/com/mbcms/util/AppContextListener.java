package com.mbcms.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * AppContextListener - Khoi dong va tat ung dung
 * - Start: khoi dong DBCP2 pool
 * - Destroy: dong pool de tranh leak
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[MBCMS] Ung dung khoi dong - DBCP2 pool ready");
        // DBUtil tu khoi dong trong static block
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DBUtil.shutdown();
        System.out.println("[MBCMS] Ung dung tat - DBCP2 pool dong");
    }
}

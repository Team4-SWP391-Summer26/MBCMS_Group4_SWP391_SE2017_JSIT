package com.mbcms;

import com.mbcms.dao.impl.ReportDAOImpl;
import java.time.LocalDate;

public class TestDB {
    public static void main(String[] args) {
        try {
            ReportDAOImpl dao = new ReportDAOImpl();
            dao.getDashboardMetrics(LocalDate.now().minusDays(30), LocalDate.now());
            System.out.println("SUCCESSFULLY RAN ALL QUERIES!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

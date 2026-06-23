package com.mbcms.controller.branch;

import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.model.Branch;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * ConsoleSupport - tien ich nho cho cac man manager console (/branch/*).
 * Owner: HungNT.
 *
 * Cache ten branch vao session 1 lan (key "currentBranchName") de sidebar
 * va scope notice khong phai query branches moi request.
 */
public final class ConsoleSupport {

    private ConsoleSupport() {}

    /** Dam bao session co "currentBranchName" (load tu DB lan dau). */
    public static void ensureBranchName(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentBranchName") != null) {
            return;
        }
        Long branchId = (Long) session.getAttribute("currentBranchId");
        if (branchId == null) {
            return;
        }
        Branch branch = new BranchDAOImpl().findById(branchId);
        if (branch != null) {
            session.setAttribute("currentBranchName", branch.getName());
        }
    }
}

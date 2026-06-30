package com.mbcms.controller.admin;

import com.mbcms.service.GenreService;
import com.mbcms.service.impl.GenreServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * AdminGenreServlet - Manage genres (them / sua / xoa the loai phim).
 */
@WebServlet("/admin/genres")
public class AdminGenreServlet extends HttpServlet {

    private final GenreService genreService = new GenreServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("genres", genreService.listWithCount());
            req.setAttribute("successMsg", req.getParameter("successMsg"));
            req.setAttribute("errorMsg", req.getParameter("errorMsg"));
            req.getRequestDispatcher("/WEB-INF/views/admin/genres.jsp").forward(req, resp);
        } catch (Exception e) {
            getServletContext().log("Lỗi doGet AdminGenreServlet: ", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tải thể loại.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/genres?errorMsg=" + enc("Hành động không hợp lệ."));
            return;
        }
        try {
            switch (action) {
                case "add":
                    genreService.create(req.getParameter("name"));
                    redirect(req, resp, "successMsg", "Thêm thể loại thành công!");
                    break;
                case "edit":
                    genreService.rename(Integer.parseInt(req.getParameter("genreId")), req.getParameter("name"));
                    redirect(req, resp, "successMsg", "Cập nhật thể loại thành công!");
                    break;
                case "delete":
                    genreService.delete(Integer.parseInt(req.getParameter("genreId")));
                    redirect(req, resp, "successMsg", "Đã xóa thể loại!");
                    break;
                default:
                    redirect(req, resp, "errorMsg", "Hành động không xác định.");
            }
        } catch (NumberFormatException e) {
            redirect(req, resp, "errorMsg", "Tham số không hợp lệ.");
        } catch (IllegalArgumentException e) {
            redirect(req, resp, "errorMsg", e.getMessage());
        } catch (Exception e) {
            getServletContext().log("Lỗi trong AdminGenreServlet: ", e);
            redirect(req, resp, "errorMsg", "Đã xảy ra lỗi hệ thống.");
        }
    }

    private void redirect(HttpServletRequest req, HttpServletResponse resp, String key, String msg)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/admin/genres?" + key + "=" + enc(msg));
    }

    private String enc(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8);
    }
}

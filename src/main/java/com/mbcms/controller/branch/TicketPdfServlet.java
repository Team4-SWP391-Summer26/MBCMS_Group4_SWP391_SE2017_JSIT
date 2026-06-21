package com.mbcms.controller.branch;

import com.itextpdf.io.font.PdfEncodings;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import java.io.InputStream;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.properties.HorizontalAlignment;
import com.itextpdf.layout.properties.TextAlignment;
import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;
import com.mbcms.util.QRCodeUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * TicketPdfServlet - Tiện ích sinh file PDF vé kèm mã QR trực tuyến. Mapped:
 * /staff/ticket-pdf
 */
@WebServlet("/staff/ticket-pdf")
public class TicketPdfServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAOImpl();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAOImpl();
    private final SeatDAO seatDAO = new SeatDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String bookingCode = req.getParameter("bookingCode");
        if (bookingCode == null || bookingCode.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã đặt vé không hợp lệ");
            return;
        }

        Booking booking = bookingDAO.findByCode(bookingCode.trim().toUpperCase());
        if (booking == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy giao dịch đặt vé");
            return;
        }

        Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());
        if (showtime == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch chiếu tương ứng");
            return;
        }

        // Lấy tên các ghế đã chọn
        List<Seat> allSeats = seatDAO.findByRoom(showtime.getRoomId());
        List<String> selectedLabels = new ArrayList<>();
        if (booking.getSeatIds() != null) {
            for (Long seatId : booking.getSeatIds()) {
                for (Seat s : allSeats) {
                    if (s.getSeatId() == seatId) {
                        selectedLabels.add(s.getRowLabel() + s.getColNumber());
                    }
                }
            }
        }
        String seatsDisplay = String.join(", ", selectedLabels);

        // Định dạng thời gian chiếu
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
        String timeDisplay = showtime.getStartTime().format(dtf);

        try {
            // 1. Tạo QR Code dưới dạng bytes bằng ZXing
            byte[] qrBytes = QRCodeUtil.generateQRCodeBytes(booking.getBookingCode(), 200, 200);

            // 2. Tạo PDF bằng iText 7
            ByteArrayOutputStream pdfBos = new ByteArrayOutputStream();
            PdfWriter writer = new PdfWriter(pdfBos);
            PdfDocument pdfDoc = new PdfDocument(writer);
            Document doc = new Document(pdfDoc);

            initFonts();
            if (fontRegular != null) {
                doc.setFont(fontRegular);
            }

            // Cấu trúc nội dung vé
            doc.add(createBoldParagraph("MBCMS CINEMA TICKET", 22).setTextAlignment(TextAlignment.CENTER));
            doc.add(new Paragraph("=========================================")
                    .setTextAlignment(TextAlignment.CENTER)
                    .setFontSize(10));

            doc.add(createBoldParagraph("Mã vé: " + booking.getBookingCode()));
            doc.add(createBoldParagraph("Phim: " + showtime.getMovieTitle(), 14));
            doc.add(new Paragraph("Suất chiếu: " + timeDisplay));
            doc.add(new Paragraph("Phòng chiếu: " + showtime.getRoomName() + " (" + showtime.getFormat() + ")"));
            doc.add(createBoldParagraph("Ghế chọn: " + seatsDisplay));
            doc.add(new Paragraph("Tổng tiền: " + booking.getTotalAmount() + " VND"));
            doc.add(new Paragraph("Loại thanh toán: Tiền mặt (CASH)").setFontSize(9));
            doc.add(new Paragraph("-----------------------------------------")
                    .setTextAlignment(TextAlignment.CENTER)
                    .setFontSize(10));

            // Nhúng mã QR vào PDF
            Image qrImage = new Image(ImageDataFactory.create(qrBytes));
            qrImage.setHorizontalAlignment(HorizontalAlignment.CENTER);
            doc.add(qrImage);

            doc.add(new Paragraph("Vui lòng quét mã QR tại cổng kiểm soát vé.")
                    .setTextAlignment(TextAlignment.CENTER)
                    .setFontSize(9)
                    .setItalic());

            doc.close();

            // 3. Trả về bytes trực tiếp lên response
            byte[] pdfBytes = pdfBos.toByteArray();

            resp.setContentType("application/pdf");
            resp.setContentLength(pdfBytes.length);
            // "inline" mở trực tiếp trên trình duyệt để in; "attachment" để tải xuống
            resp.setHeader("Content-Disposition", "inline; filename=Ticket_" + booking.getBookingCode() + ".pdf");
            resp.getOutputStream().write(pdfBytes);
            resp.getOutputStream().flush();

        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi sinh vé PDF: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String bookingCode = req.getParameter("bookingCode");
        String email = req.getParameter("email");

        java.util.Map<String, Object> result = new java.util.HashMap<>();

        if (bookingCode == null || bookingCode.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Thiếu mã đặt vé hoặc địa chỉ email");
            new com.fasterxml.jackson.databind.ObjectMapper().writeValue(resp.getWriter(), result);
            return;
        }

        Booking booking = bookingDAO.findByCode(bookingCode.trim().toUpperCase());
        if (booking == null) {
            result.put("success", false);
            result.put("message", "Không tìm thấy giao dịch đặt vé");
            new com.fasterxml.jackson.databind.ObjectMapper().writeValue(resp.getWriter(), result);
            return;
        }

        Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());
        if (showtime == null) {
            result.put("success", false);
            result.put("message", "Không tìm thấy lịch chiếu");
            new com.fasterxml.jackson.databind.ObjectMapper().writeValue(resp.getWriter(), result);
            return;
        }

        List<Seat> allSeats = seatDAO.findByRoom(showtime.getRoomId());
        List<String> selectedLabels = new ArrayList<>();
        if (booking.getSeatIds() != null) {
            for (Long seatId : booking.getSeatIds()) {
                for (Seat s : allSeats) {
                    if (s.getSeatId() == seatId) {
                        selectedLabels.add(s.getRowLabel() + s.getColNumber());
                    }
                }
            }
        }
        String seatsDisplay = String.join(", ", selectedLabels);
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
        String timeDisplay = showtime.getStartTime().format(dtf);

        try {
            byte[] qrBytes = QRCodeUtil.generateQRCodeBytes(booking.getBookingCode(), 200, 200);

            ByteArrayOutputStream pdfBos = new ByteArrayOutputStream();
            PdfWriter writer = new PdfWriter(pdfBos);
            PdfDocument pdfDoc = new PdfDocument(writer);
            Document doc = new Document(pdfDoc);

            initFonts();
            if (fontRegular != null) {
                doc.setFont(fontRegular);
            }

            doc.add(createBoldParagraph("MBCMS CINEMA TICKET", 22).setTextAlignment(TextAlignment.CENTER));
            doc.add(new Paragraph("=========================================")
                    .setTextAlignment(TextAlignment.CENTER)
                    .setFontSize(10));

            doc.add(createBoldParagraph("Mã vé: " + booking.getBookingCode()));
            doc.add(createBoldParagraph("Phim: " + showtime.getMovieTitle(), 14));
            doc.add(new Paragraph("Suất chiếu: " + timeDisplay));
            doc.add(new Paragraph("Phòng chiếu: " + showtime.getRoomName() + " (" + showtime.getFormat() + ")"));
            doc.add(createBoldParagraph("Ghế chọn: " + seatsDisplay));
            doc.add(new Paragraph("Tổng tiền: " + booking.getTotalAmount() + " VND"));
            doc.add(new Paragraph("Loại thanh toán: Tiền mặt (CASH)").setFontSize(9));
            doc.add(new Paragraph("-----------------------------------------")
                    .setTextAlignment(TextAlignment.CENTER)
                    .setFontSize(10));

            Image qrImage = new Image(ImageDataFactory.create(qrBytes));
            qrImage.setHorizontalAlignment(HorizontalAlignment.CENTER);
            doc.add(qrImage);

            doc.add(new Paragraph("Vui lòng quét mã QR tại cổng kiểm soát vé.")
                    .setTextAlignment(TextAlignment.CENTER)
                    .setFontSize(9)
                    .setItalic());

            doc.close();

            byte[] pdfBytes = pdfBos.toByteArray();

            // Send via email
            boolean sent = com.mbcms.util.EmailUtil.sendTicketEmail(email.trim(), booking.getBookingCode(), pdfBytes);
            if (sent) {
                result.put("success", true);
                result.put("message", "Vé điện tử đã được gửi tới email " + email);
            } else {
                result.put("success", false);
                result.put("message", "Gửi email thất bại. Vui lòng kiểm tra lại cấu hình SMTP.");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Lỗi khi sinh hoặc gửi vé: " + e.getMessage());
        }

        new com.fasterxml.jackson.databind.ObjectMapper().writeValue(resp.getWriter(), result);
    }

    private static PdfFont fontRegular = null;
    private static PdfFont fontBold = null;

    private synchronized static void initFonts() {
        if (fontRegular != null && fontBold != null) {
            return;
        }
        try {
            byte[] regularBytes;
            try (InputStream is = TicketPdfServlet.class.getClassLoader().getResourceAsStream("fonts/Arial.ttf")) {
                if (is == null) {
                    throw new RuntimeException("Font Arial.ttf not found in classpath");
                }
                regularBytes = readAllBytes(is);
            }

            byte[] boldBytes;
            try (InputStream is = TicketPdfServlet.class.getClassLoader().getResourceAsStream("fonts/Arial-Bold.ttf")) {
                if (is == null) {
                    throw new RuntimeException("Font Arial-Bold.ttf not found in classpath");
                }
                boldBytes = readAllBytes(is);
            }

            fontRegular = PdfFontFactory.createFont(regularBytes, PdfEncodings.IDENTITY_H);
            fontBold = PdfFontFactory.createFont(boldBytes, PdfEncodings.IDENTITY_H);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static byte[] readAllBytes(InputStream is) throws IOException {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        int nRead;
        byte[] data = new byte[16384];
        while ((nRead = is.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, nRead);
        }
        return buffer.toByteArray();
    }

    private static Paragraph createBoldParagraph(String text, float fontSize) {
        Paragraph p = new Paragraph(text).setFontSize(fontSize);
        if (fontBold != null) {
            p.setFont(fontBold);
        } else {
            p.setBold();
        }
        return p;
    }

    private static Paragraph createBoldParagraph(String text) {
        Paragraph p = new Paragraph(text);
        if (fontBold != null) {
            p.setFont(fontBold);
        } else {
            p.setBold();
        }
        return p;
    }
}

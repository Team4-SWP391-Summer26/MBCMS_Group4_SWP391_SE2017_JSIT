package com.mbcms.util;

import com.itextpdf.io.font.PdfEncodings;
import com.itextpdf.io.font.constants.StandardFonts;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.HorizontalAlignment;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.Payment;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * InvoicePdfUtil - sinh PDF hoa don thanh toan tu Bookings + Payments (owner: HungNT).
 * Feature: Invoice generation (SRS 3.3.2.3). Noi dung GIONG man Payment Receipt:
 * itemize dung phan da thanh toan (ve - giam gia = total). Read-only, khong ghi DB.
 *
 * Font: uu tien Arial (Unicode, ho tro tieng Viet) tren Windows; fallback Helvetica.
 * Tien hien thi "VND" (khong dung ky tu d/dong de tranh thieu glyph giua cac font).
 */
public final class InvoicePdfUtil {

    private static final DeviceRgb NAVY  = new DeviceRgb(15, 30, 54);
    private static final DeviceRgb BLUE  = new DeviceRgb(37, 99, 235);
    private static final DeviceRgb MUTED = new DeviceRgb(100, 116, 139);
    private static final DeviceRgb LIGHT = new DeviceRgb(247, 249, 252);
    private static final DecimalFormat MONEY = new DecimalFormat("#,###");
    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    /** QR: 200x200 px khi sinh (net khi in), ve xuong PDF 100pt cho can trang A4. */
    private static final int QR_PX = 200;
    private static final float QR_PT = 100f;

    private InvoicePdfUtil() {}

    public static byte[] build(BookingTicket t, Payment p, LocalDateTime paidAtVn) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfFont font = loadFont(false);
        PdfFont bold = loadFont(true);

        PdfDocument pdf = new PdfDocument(new PdfWriter(baos));
        Document doc = new Document(pdf, PageSize.A4);
        try {
            doc.setMargins(36, 40, 36, 40);
            doc.setFont(font);
            doc.setFontSize(10);

            doc.add(header(t, bold, font));
            doc.add(new Paragraph("PAYMENT RECEIPT").setFont(bold).setFontSize(16)
                    .setFontColor(NAVY).setMarginTop(18).setMarginBottom(2));
            doc.add(new Paragraph("Status: " + statusLabel(p)).setFontColor(MUTED)
                    .setFontSize(9).setMarginBottom(10));

            doc.add(metaTable(t, p, paidAtVn, bold));
            doc.add(itemsTable(t, bold));
            doc.add(totalsTable(t, bold));
            addQrBlock(doc, t, p, bold);

            doc.add(new Paragraph("Thank you for choosing PentaPlex. This receipt is your proof of payment.")
                    .setFontColor(MUTED).setFontSize(8).setTextAlignment(TextAlignment.CENTER)
                    .setMarginTop(24));
        } finally {
            doc.close(); // dong luon PdfDocument + writer
        }
        return baos.toByteArray();
    }

    /**
     * QR e-ticket (ZXing) nhung vao PDF: ma hoa booking_code de Staff quet o cua rap.
     * Chi in khi payment SUCCESS - hoa don chua thanh toan thi QR vo nghia (vao rap
     * bi tu choi voi trang thai NOT_PAID), in ra chi gay hieu lam.
     * QR loi (text rong / ZXing nem) KHONG duoc lam vo ca hoa don -> bo qua khoi nay.
     */
    private static void addQrBlock(Document doc, BookingTicket t, Payment p, PdfFont bold) {
        if (p == null || !Payment.STATUS_SUCCESS.equals(p.getStatus())) {
            return;
        }
        if (isBlank(t.getBookingCode())) {
            return;
        }
        try {
            byte[] png = QRCodeUtil.generateQRCodeBytes(t.getBookingCode(), QR_PX, QR_PX);
            Image qr = new Image(ImageDataFactory.create(png))
                    .setWidth(QR_PT).setHeight(QR_PT)
                    .setHorizontalAlignment(HorizontalAlignment.CENTER);

            doc.add(new Paragraph("E-TICKET").setFont(bold).setFontSize(9).setFontColor(MUTED)
                    .setTextAlignment(TextAlignment.CENTER).setMarginTop(18).setMarginBottom(4));
            doc.add(qr);
            doc.add(new Paragraph(nz(t.getBookingCode())).setFont(bold).setFontSize(11).setFontColor(NAVY)
                    .setTextAlignment(TextAlignment.CENTER).setMarginTop(4).setMarginBottom(0));
            doc.add(new Paragraph("Present this QR code at the entrance. Valid for one entry only.")
                    .setFontColor(MUTED).setFontSize(8).setTextAlignment(TextAlignment.CENTER));
        } catch (Exception e) {
            // Hoa don van xuat duoc, chi thieu khoi QR.
        }
    }

    // ── Header (navy block): brand + issued-to | official receipt # ──────────
    private static Table header(BookingTicket t, PdfFont bold, PdfFont font) {
        Table tbl = new Table(UnitValue.createPercentArray(new float[]{60, 40}))
                .useAllAvailableWidth();
        Cell left = bgCell(NAVY);
        left.add(new Paragraph("PentaPlex").setFont(bold).setFontSize(18).setFontColor(ColorConstants.WHITE).setMarginBottom(14));
        left.add(small("ISSUED TO", new DeviceRgb(150, 165, 190)));
        left.add(new Paragraph(nz(t.getCustomerFullName())).setFont(bold).setFontColor(ColorConstants.WHITE).setFontSize(12).setMarginBottom(0));
        left.add(new Paragraph(nz(t.getCustomerEmail())).setFontColor(new DeviceRgb(190, 200, 215)).setFontSize(9));

        Cell right = bgCell(NAVY);
        right.add(small("OFFICIAL RECEIPT", new DeviceRgb(150, 165, 190)).setTextAlignment(TextAlignment.RIGHT));
        right.add(new Paragraph("#" + nz(t.getBookingCode())).setFont(bold).setFontColor(ColorConstants.WHITE)
                .setFontSize(12).setTextAlignment(TextAlignment.RIGHT));
        return tbl.addCell(left).addCell(right);
    }

    // ── Meta grid (2 cols) ───────────────────────────────────────────────────
    private static Table metaTable(BookingTicket t, Payment p, LocalDateTime paidAt, PdfFont bold) {
        Table tbl = new Table(UnitValue.createPercentArray(new float[]{50, 50}))
                .useAllAvailableWidth().setMarginTop(6).setMarginBottom(14);
        tbl.addCell(meta("Payment status", statusLabel(p), bold));
        tbl.addCell(meta("Payment method", p == null ? "—" : nz(p.getMethod()), bold));
        tbl.addCell(meta("Paid time", paidAt == null ? "—" : DT.format(paidAt), bold));
        tbl.addCell(meta("Transaction reference", p == null || isBlank(p.getTransactionRef()) ? "—" : p.getTransactionRef(), bold));
        tbl.addCell(meta("Booking code", nz(t.getBookingCode()), bold));
        tbl.addCell(meta("Cinema", nz(t.getBranchName()) + (isBlank(t.getRoomName()) ? "" : " - " + t.getRoomName()), bold));
        String showtime = nz(t.getMovieTitle())
                + (t.getStartTime() == null ? "" : "  -  " + DT.format(t.getStartTime()));
        Cell movie = meta("Movie / Showtime", showtime, bold);
        // span ca 2 cot? giu 1 cot cho don gian
        tbl.addCell(movie);
        tbl.addCell(meta("Seats", t.getSeatLabels() == null ? "—" : String.join(", ", t.getSeatLabels()), bold));
        return tbl;
    }

    // ── Itemized (1 dong ve) ─────────────────────────────────────────────────
    private static Table itemsTable(BookingTicket t, PdfFont bold) {
        Table tbl = new Table(UnitValue.createPercentArray(new float[]{52, 12, 18, 18}))
                .useAllAvailableWidth().setMarginBottom(6);
        tbl.addHeaderCell(th("Description", TextAlignment.LEFT, bold));
        tbl.addHeaderCell(th("Qty", TextAlignment.CENTER, bold));
        tbl.addHeaderCell(th("Unit price", TextAlignment.RIGHT, bold));
        tbl.addHeaderCell(th("Amount", TextAlignment.RIGHT, bold));

        int seats = t.getSeatLabels() == null ? 0 : t.getSeatLabels().size();
        BigDecimal subtotal = nzAmt(t.getSubtotal());
        BigDecimal unit = seats > 0 ? subtotal.divide(BigDecimal.valueOf(seats), 0, java.math.RoundingMode.HALF_UP) : subtotal;
        String desc = "Movie ticket" + (isBlank(t.getFormat()) ? "" : " - " + t.getFormat());

        tbl.addCell(td(desc, TextAlignment.LEFT));
        tbl.addCell(td(String.valueOf(seats), TextAlignment.CENTER));
        tbl.addCell(td(money(unit), TextAlignment.RIGHT));
        tbl.addCell(td(money(subtotal), TextAlignment.RIGHT));
        return tbl;
    }

    // ── Totals (right aligned) ───────────────────────────────────────────────
    private static Table totalsTable(BookingTicket t, PdfFont bold) {
        Table tbl = new Table(UnitValue.createPercentArray(new float[]{60, 40}))
                .useAllAvailableWidth();
        tbl.addCell(blank()); tbl.addCell(totRow("Subtotal", money(nzAmt(t.getSubtotal())), false, false));
        if (nzAmt(t.getDiscountAmount()).signum() > 0) {
            tbl.addCell(blank());
            tbl.addCell(totRow("Discount", "- " + money(t.getDiscountAmount()), false, true));
        }
        tbl.addCell(blank());
        tbl.addCell(totRow("Total Paid", money(nzAmt(t.getTotalAmount())), true, false).setFont(bold));
        return tbl;
    }

    // ── small builders ───────────────────────────────────────────────────────
    private static Cell bgCell(DeviceRgb bg) {
        return new Cell().setBackgroundColor(bg).setBorder(Border.NO_BORDER).setPadding(16);
    }
    private static Paragraph small(String s, DeviceRgb color) {
        return new Paragraph(s).setFontSize(7).setFontColor(color).setMarginBottom(2);
    }
    private static Cell meta(String label, String value, PdfFont bold) {
        Cell c = new Cell().setBorder(Border.NO_BORDER).setPaddingBottom(10);
        c.add(new Paragraph(label).setFontSize(7).setFontColor(MUTED));
        c.add(new Paragraph(nz(value)).setFont(bold).setFontColor(NAVY).setFontSize(10));
        return c;
    }
    private static Cell th(String s, TextAlignment a, PdfFont bold) {
        return new Cell().add(new Paragraph(s).setFont(bold).setFontSize(8).setFontColor(MUTED))
                .setBackgroundColor(LIGHT).setBorder(Border.NO_BORDER).setPadding(6).setTextAlignment(a);
    }
    private static Cell td(String s, TextAlignment a) {
        return new Cell().add(new Paragraph(nz(s))).setBorder(Border.NO_BORDER)
                .setPadding(6).setTextAlignment(a).setFontColor(NAVY);
    }
    private static Cell blank() { return new Cell().setBorder(Border.NO_BORDER); }
    private static Cell totRow(String k, String v, boolean grand, boolean discount) {
        Cell c = new Cell().setBorder(Border.NO_BORDER).setPadding(4);
        Table inner = new Table(UnitValue.createPercentArray(new float[]{55, 45})).useAllAvailableWidth();
        inner.addCell(new Cell().add(new Paragraph(k).setFontColor(grand ? NAVY : MUTED)
                .setFontSize(grand ? 11 : 9)).setBorder(Border.NO_BORDER));
        inner.addCell(new Cell().add(new Paragraph(v).setFontColor(grand ? BLUE : (discount ? new DeviceRgb(22, 163, 74) : NAVY))
                .setFontSize(grand ? 13 : 9)).setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.RIGHT));
        if (grand) inner.setMarginTop(4);
        c.add(inner);
        return c;
    }

    private static String statusLabel(Payment p) {
        if (p == null) return "UNPAID";
        return Payment.STATUS_SUCCESS.equals(p.getStatus()) ? "COMPLETED" : p.getStatus();
    }
    private static String money(BigDecimal v) { return MONEY.format(nzAmt(v)) + " VND"; }
    private static BigDecimal nzAmt(BigDecimal v) { return v == null ? BigDecimal.ZERO : v; }
    private static String nz(String s) { return s == null ? "" : s; }
    private static boolean isBlank(String s) { return s == null || s.isBlank(); }

    private static PdfFont loadFont(boolean boldStyle) {
        String[] paths = boldStyle
                ? new String[]{"C:/Windows/Fonts/arialbd.ttf", "C:/Windows/Fonts/Arialbd.ttf"}
                : new String[]{"C:/Windows/Fonts/arial.ttf", "C:/Windows/Fonts/Arial.ttf"};
        for (String path : paths) {
            try {
                return PdfFontFactory.createFont(path, PdfEncodings.IDENTITY_H,
                        PdfFontFactory.EmbeddingStrategy.PREFER_EMBEDDED);
            } catch (Exception ignored) { /* thu font tiep theo / fallback */ }
        }
        try {
            return PdfFontFactory.createFont(boldStyle ? StandardFonts.HELVETICA_BOLD : StandardFonts.HELVETICA);
        } catch (Exception e) {
            throw new RuntimeException("Khong tao duoc font PDF: " + e.getMessage(), e);
        }
    }
}

package com.mbcms.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMultipart;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * EmailUtil - Helper class to send emails using Gmail SMTP server.
 */
public class EmailUtil {

    // Properties holder loaded once during startup
    private static final Properties emailProps = new Properties();

    static {
        // Load email configuration from properties file
        try (InputStream is = EmailUtil.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (is != null) {
                emailProps.load(is);
            } else {
                System.err.println("[WARNING] email.properties not found in classpath. Using default SMTP configurations.");
                // Set default Gmail SMTP properties
                emailProps.put("mail.smtp.host", "smtp.gmail.com");
                emailProps.put("mail.smtp.port", "587");
                emailProps.put("mail.smtp.auth", "true");
                emailProps.put("mail.smtp.starttls.enable", "true");
                emailProps.put("mail.sender.email", "your-gmail@gmail.com");
                emailProps.put("mail.sender.password", "your-app-password");
            }
        } catch (IOException e) {
            System.err.println("[ERROR] Failed to load email.properties: " + e.getMessage());
        }
    }

    /**
     * Send OTP Verification Code to recipient's email address.
     *
     * @param recipientEmail The recipient's email address.
     * @param otpCode The 6-digit numeric OTP code.
     * @return true if sent successfully, false otherwise.
     */
    public static boolean sendOTPEmail(String recipientEmail, String otpCode) {
        final String senderEmail = emailProps.getProperty("mail.sender.email");
        final String senderPassword = emailProps.getProperty("mail.sender.password");

        // Validate that credentials have been configured
        if (senderEmail == null || senderEmail.equals("your-gmail@gmail.com")
                || senderPassword == null || senderPassword.equals("your-app-password")) {
            System.err.println("[ERROR] Gmail sender credentials are not configured in email.properties. Cannot send OTP email.");
            return false;
        }

        // Setup session properties
        Properties props = new Properties();
        props.put("mail.smtp.host", emailProps.getProperty("mail.smtp.host", "smtp.gmail.com"));
        props.put("mail.smtp.port", emailProps.getProperty("mail.smtp.port", "587"));
        props.put("mail.smtp.auth", emailProps.getProperty("mail.smtp.auth", "true"));
        props.put("mail.smtp.starttls.enable", emailProps.getProperty("mail.smtp.starttls.enable", "true"));

        // Add timeout properties to prevent hanging
        props.put("mail.smtp.connectiontimeout", "5000"); // 5s connection timeout
        props.put("mail.smtp.timeout", "5000");           // 5s read timeout

        // Create a mail session with SMTP authenticator
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        try {
            // Create a default MimeMessage object
            MimeMessage message = new MimeMessage(session);

            // Set From: header field
            message.setFrom(new InternetAddress(senderEmail));

            // Set To: header field
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));

            // Set Subject: header field
            message.setSubject("[PentaPlex] Password Reset Verification Code", "UTF-8");

            // Compose HTML message body
            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e5e7eb; border-radius: 12px; background-color: #ffffff;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h2 style='color: #182c54; margin: 0;'>PentaPlex Cinema</h2>"
                    + "</div>"
                    + "<hr style='border: 0; border-top: 1px solid #e5e7eb; margin-bottom: 20px;'>"
                    + "<p>Hello,</p>"
                    + "<p>We received a request to reset the password for your PentaPlex account. Please use the verification code below to proceed with resetting your password:</p>"
                    + "<div style='text-align: center; margin: 30px 0;'>"
                    + "  <span style='display: inline-block; font-size: 32px; font-weight: bold; color: #2563eb; letter-spacing: 6px; padding: 12px 24px; background-color: #f3f4f6; border-radius: 8px; border: 1px dashed #d1d5db;'>" + otpCode + "</span>"
                    + "</div>"
                    + "<p style='color: #ef4444; font-weight: 500;'>This code will expire in 15 minutes. For security, do not share this code with anyone.</p>"
                    + "<p>If you did not make this request, you can safely ignore this email. Your password will remain unchanged.</p>"
                    + "<br>"
                    + "<p>Thank you,<br>The PentaPlex Team</p>"
                    + "</div>";

            // Set content type and encoding
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            // Send email
            Transport.send(message);
            return true;

        } catch (MessagingException e) {
            System.err.println("[ERROR] Failed to send OTP email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Send Account Activation Verification Link to recipient's email address.
     *
     * @param recipientEmail The recipient's email address.
     * @param username The registered customer's username.
     * @param verificationLink The unique activation URL.
     * @return true if sent successfully, false otherwise.
     */
    public static boolean sendVerificationEmail(String recipientEmail, String username, String verificationLink) {
        final String senderEmail = emailProps.getProperty("mail.sender.email");
        final String senderPassword = emailProps.getProperty("mail.sender.password");

        // Validate that credentials have been configured
        if (senderEmail == null || senderEmail.equals("your-gmail@gmail.com")
                || senderPassword == null || senderPassword.equals("your-app-password")) {
            System.err.println("[ERROR] Gmail sender credentials are not configured. Cannot send verification email.");
            return false;
        }

        // Setup session properties
        Properties props = new Properties();
        props.put("mail.smtp.host", emailProps.getProperty("mail.smtp.host", "smtp.gmail.com"));
        props.put("mail.smtp.port", emailProps.getProperty("mail.smtp.port", "587"));
        props.put("mail.smtp.auth", emailProps.getProperty("mail.smtp.auth", "true"));
        props.put("mail.smtp.starttls.enable", emailProps.getProperty("mail.smtp.starttls.enable", "true"));

        // Add timeout properties to prevent hanging
        props.put("mail.smtp.connectiontimeout", "5000"); // 5s connection timeout
        props.put("mail.smtp.timeout", "5000");           // 5s read timeout

        // Create a mail session with SMTP authenticator
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        try {
            // Create a default MimeMessage object
            MimeMessage message = new MimeMessage(session);

            // Set From: header field
            message.setFrom(new InternetAddress(senderEmail));

            // Set To: header field
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));

            // Set Subject: header field
            message.setSubject("[PentaPlex] Xác thực đăng ký tài khoản mới", "UTF-8");

            // Compose HTML message body with a stylized button
            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e5e7eb; border-radius: 12px; background-color: #ffffff;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h2 style='color: #182c54; margin: 0;'>PentaPlex Cinema</h2>"
                    + "</div>"
                    + "<hr style='border: 0; border-top: 1px solid #e5e7eb; margin-bottom: 20px;'>"
                    + "<p>Xin chào <strong>" + username + "</strong>,</p>"
                    + "<p>Cảm ơn bạn đã đăng ký tài khoản tại hệ thống rạp chiếu phim PentaPlex. Vui lòng bấm vào nút bên dưới để hoàn tất kích hoạt tài khoản của bạn:</p>"
                    + "<div style='text-align: center; margin: 30px 0;'>"
                    + "  <a href='" + verificationLink + "' style='display: inline-block; padding: 12px 24px; font-size: 16px; color: #ffffff; background-color: #2563eb; text-decoration: none; border-radius: 8px; font-weight: bold;'>Xác Thực Tài Khoản</a>"
                    + "</div>"
                    + "<p style='font-size: 0.9rem; color: #6b7280;'>Nếu nút bấm trên không hoạt động, bạn có thể sao chép liên kết dưới đây và dán vào thanh địa chỉ trình duyệt:</p>"
                    + "<p style='font-size: 0.85rem; color: #2563eb; word-break: break-all;'>" + verificationLink + "</p>"
                    + "<br>"
                    + "<p>Trân trọng,<br>Đội ngũ hỗ trợ PentaPlex</p>"
                    + "</div>";

            // Set content type and encoding
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            // Send email
            Transport.send(message);
            return true;

        } catch (MessagingException e) {
            System.err.println("[ERROR] Failed to send verification email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Send Cinema Ticket PDF to recipient's email address.
     *
     * @param recipientEmail The recipient's email address.
     * @param bookingCode The booking code.
     * @param pdfBytes The generated PDF bytes.
     * @return true if sent successfully, false otherwise.
     */
    public static boolean sendTicketEmail(String recipientEmail, String bookingCode, byte[] pdfBytes) {
        final String senderEmail = emailProps.getProperty("mail.sender.email");
        final String senderPassword = emailProps.getProperty("mail.sender.password");

        if (senderEmail == null || senderEmail.equals("your-gmail@gmail.com")
                || senderPassword == null || senderPassword.equals("your-app-password")) {
            System.err.println("[ERROR] Gmail sender credentials are not configured in email.properties. Cannot send ticket email.");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", emailProps.getProperty("mail.smtp.host", "smtp.gmail.com"));
        props.put("mail.smtp.port", emailProps.getProperty("mail.smtp.port", "587"));
        props.put("mail.smtp.auth", emailProps.getProperty("mail.smtp.auth", "true"));
        props.put("mail.smtp.starttls.enable", emailProps.getProperty("mail.smtp.starttls.enable", "true"));
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            message.setSubject("[PentaPlex] Vé Xem Phim Điện Tử - " + bookingCode, "UTF-8");

            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e5e7eb; border-radius: 12px; background-color: #ffffff;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h2 style='color: #182c54; margin: 0;'>PentaPlex Cinema</h2>"
                    + "</div>"
                    + "<hr style='border: 0; border-top: 1px solid #e5e7eb; margin-bottom: 20px;'>"
                    + "<p>Xin chào quý khách,</p>"
                    + "<p>Cảm ơn quý khách đã tin tưởng và sử dụng dịch vụ đặt vé của PentaPlex.</p>"
                    + "<p>Thông tin vé xem phim điện tử của quý khách đã được xuất thành công. Vui lòng xem chi tiết vé trong file đính kèm PDF của email này.</p>"
                    + "<p>Hãy quét mã QR đính kèm trên vé tại cổng kiểm soát để vào phòng chiếu.</p>"
                    + "<br>"
                    + "<p>Chúc quý khách có những trải nghiệm xem phim tuyệt vời tại PentaPlex!</p>"
                    + "<p>Trân trọng,<br>Đội ngũ PentaPlex</p>"
                    + "</div>";

            // Create multipart content
            Multipart multipart = new jakarta.mail.internet.MimeMultipart();

            // Body text part
            MimeBodyPart messageBodyPart = new jakarta.mail.internet.MimeBodyPart();
            messageBodyPart.setContent(htmlContent, "text/html; charset=UTF-8");
            multipart.addBodyPart(messageBodyPart);

            // Attachment part
            MimeBodyPart attachPart = new jakarta.mail.internet.MimeBodyPart();
            jakarta.activation.DataSource source = new jakarta.mail.util.ByteArrayDataSource(pdfBytes, "application/pdf");
            attachPart.setDataHandler(new jakarta.activation.DataHandler(source));
            attachPart.setFileName("Ticket_" + bookingCode + ".pdf");
            multipart.addBodyPart(attachPart);

            message.setContent(multipart);

            Transport.send(message);
            return true;

        } catch (Exception e) {
            System.err.println("[ERROR] Failed to send ticket email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
// ADD THESE THREE METHODS to the existing EmailUtil class
// Place after the existing sendVerificationEmail() method
// ═══════════════════════════════════════════════════════════════════════════
    /**
     * Gui email xac nhan dat ve + thanh toan thanh cong. Goi boi
     * NotificationServiceImpl.sendBookingConfirmation() bat dong bo.
     */
    public static boolean sendBookingConfirmationEmail(String recipientEmail,
            com.mbcms.model.Booking booking) {
        final String senderEmail = emailProps.getProperty("mail.sender.email");
        final String senderPassword = emailProps.getProperty("mail.sender.password");

        if (!isConfigured(senderEmail, senderPassword)) {
            System.err.println("[EmailUtil] Chua cau hinh SMTP. Bo qua email xac nhan dat ve.");
            return false;
        }

        Properties props = buildSmtpProps();
        Session session = buildSession(props, senderEmail, senderPassword);

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            message.setSubject("[PentaPlex] Xác nhận đặt vé thành công – " + booking.getBookingCode(), "UTF-8");

            String total = String.format("%,.0f", booking.getTotalAmount());
            String html
                    = "<div style='font-family:Arial,sans-serif;max-width:600px;margin:0 auto;"
                    + "padding:20px;border:1px solid #e5e7eb;border-radius:12px;background:#fff'>"
                    + "  <div style='text-align:center;margin-bottom:20px'>"
                    + "    <h2 style='color:#182c54;margin:0'>PentaPlex Cinema</h2>"
                    + "  </div>"
                    + "  <hr style='border:0;border-top:1px solid #e5e7eb;margin-bottom:20px'>"
                    + "  <div style='background:#f0fdf4;border:1px solid #86efac;border-radius:8px;"
                    + "       padding:16px;text-align:center;margin-bottom:20px'>"
                    + "    <div style='font-size:2rem'>✅</div>"
                    + "    <h3 style='color:#15803d;margin:8px 0 4px'>Đặt vé thành công!</h3>"
                    + "    <p style='color:#166534;margin:0'>Thanh toán đã được ghi nhận.</p>"
                    + "  </div>"
                    + "  <div style='background:#eff6ff;border:2px dashed #bfdbfe;border-radius:8px;"
                    + "       padding:14px;text-align:center;margin-bottom:20px'>"
                    + "    <p style='margin:0 0 4px;font-size:.78rem;color:#6b7280;font-weight:600;"
                    + "       text-transform:uppercase;letter-spacing:.08em'>Mã đặt vé</p>"
                    + "    <p style='margin:0;font-family:monospace;font-size:1.8rem;font-weight:800;"
                    + "       color:#1d4ed8;letter-spacing:.1em'>" + booking.getBookingCode() + "</p>"
                    + "  </div>"
                    + "  <table style='width:100%;border-collapse:collapse;font-size:.9rem'>"
                    + "    <tr><td style='padding:8px 0;color:#6b7280;width:140px'>Suất chiếu</td>"
                    + "        <td style='padding:8px 0;font-weight:600'>#" + booking.getShowtimeId() + "</td></tr>"
                    + "    <tr style='border-top:1px solid #f1f5f9'>"
                    + "        <td style='padding:8px 0;color:#6b7280'>Tổng thanh toán</td>"
                    + "        <td style='padding:8px 0;font-weight:800;color:#1d4ed8'>" + total + " ₫</td></tr>"
                    + "  </table>"
                    + "  <div style='background:#f8fafc;border-radius:8px;padding:10px 14px;"
                    + "       font-size:.8rem;color:#4b5563;margin:20px 0'>"
                    + "    💡 Vui lòng xuất trình mã đặt vé này tại quầy vé hoặc cổng vào rạp."
                    + "  </div>"
                    + "  <p style='font-size:.85rem;color:#6b7280'>Trân trọng,<br>Đội ngũ PentaPlex</p>"
                    + "</div>";

            message.setContent(html, "text/html; charset=UTF-8");
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            System.err.println("[EmailUtil] Loi gui email xac nhan dat ve: " + e.getMessage());
            return false;
        }
    }

    /**
     * Gui email nhac nho suất chieu. Goi boi
     * NotificationServiceImpl.sendReminderIfNotSent() bat dong bo.
     */
    public static boolean sendReminderEmail(String recipientEmail, String bookingCode,
            String movieTitle, String startTimeStr) {
        final String senderEmail = emailProps.getProperty("mail.sender.email");
        final String senderPassword = emailProps.getProperty("mail.sender.password");

        if (!isConfigured(senderEmail, senderPassword)) {
            System.err.println("[EmailUtil] Chua cau hinh SMTP. Bo qua email nhac nho.");
            return false;
        }

        Properties props = buildSmtpProps();
        Session session = buildSession(props, senderEmail, senderPassword);

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            message.setSubject("[PentaPlex] Nhắc nhở: Phim \"" + movieTitle + "\" sắp bắt đầu", "UTF-8");

            String html
                    = "<div style='font-family:Arial,sans-serif;max-width:600px;margin:0 auto;"
                    + "padding:20px;border:1px solid #e5e7eb;border-radius:12px;background:#fff'>"
                    + "  <div style='text-align:center;margin-bottom:20px'>"
                    + "    <h2 style='color:#182c54;margin:0'>PentaPlex Cinema</h2>"
                    + "  </div>"
                    + "  <hr style='border:0;border-top:1px solid #e5e7eb;margin-bottom:20px'>"
                    + "  <div style='background:#fef9c3;border:1px solid #fde047;border-radius:8px;"
                    + "       padding:16px;text-align:center;margin-bottom:20px'>"
                    + "    <div style='font-size:2rem'>⏰</div>"
                    + "    <h3 style='color:#92400e;margin:8px 0 4px'>Suất chiếu sắp bắt đầu!</h3>"
                    + "    <p style='color:#78350f;margin:0'>Hãy đến rạp trước 15 phút để làm thủ tục.</p>"
                    + "  </div>"
                    + "  <table style='width:100%;border-collapse:collapse;font-size:.9rem'>"
                    + "    <tr><td style='padding:8px 0;color:#6b7280;width:140px'>Phim</td>"
                    + "        <td style='padding:8px 0;font-weight:700'>" + movieTitle + "</td></tr>"
                    + "    <tr style='border-top:1px solid #f1f5f9'>"
                    + "        <td style='padding:8px 0;color:#6b7280'>Giờ chiếu</td>"
                    + "        <td style='padding:8px 0;font-weight:700;color:#d97706'>" + startTimeStr + "</td></tr>"
                    + "    <tr style='border-top:1px solid #f1f5f9'>"
                    + "        <td style='padding:8px 0;color:#6b7280'>Mã đặt vé</td>"
                    + "        <td style='padding:8px 0;font-family:monospace;font-weight:800'>" + bookingCode + "</td></tr>"
                    + "  </table>"
                    + "  <p style='font-size:.85rem;color:#6b7280;margin-top:20px'>"
                    + "    Trân trọng,<br>Đội ngũ PentaPlex</p>"
                    + "</div>";

            message.setContent(html, "text/html; charset=UTF-8");
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            System.err.println("[EmailUtil] Loi gui email nhac nho: " + e.getMessage());
            return false;
        }
    }

    /**
     * Gui email khuyen mai den danh sach customer. Gui BCC (blind carbon copy)
     * de bao ve quyen rieng tu cua nguoi nhan. Goi boi
     * NotificationServiceImpl.broadcastPromotion() bat dong bo.
     */
    public static boolean sendPromotionBroadcastEmail(java.util.List<String> usernames,
            com.mbcms.model.Promotion promotion) {
        // Lay email cho tung username – chi gui den nhung ai co email hop le
        com.mbcms.dao.CustomerDAO customerDAO = new com.mbcms.dao.impl.CustomerDAOImpl();
        java.util.List<String> emails = new java.util.ArrayList<>();
        for (String username : usernames) {
            try {
                com.mbcms.model.Customer c = customerDAO.findByUsername(username);
                if (c != null && c.getEmail() != null && !c.getEmail().isEmpty()) {
                    emails.add(c.getEmail());
                }
            } catch (Exception ignored) {
            }
        }
        if (emails.isEmpty()) {
            return false;
        }

        final String senderEmail = emailProps.getProperty("mail.sender.email");
        final String senderPassword = emailProps.getProperty("mail.sender.password");

        if (!isConfigured(senderEmail, senderPassword)) {
            System.err.println("[EmailUtil] Chua cau hinh SMTP. Bo qua email promo.");
            return false;
        }

        Properties props = buildSmtpProps();
        Session session = buildSession(props, senderEmail, senderPassword);

        String discountStr = "PERCENT".equals(promotion.getDiscountType())
                ? promotion.getDiscountValue().toPlainString() + "%"
                : String.format("%,.0f ₫", promotion.getDiscountValue());

        String html
                = "<div style='font-family:Arial,sans-serif;max-width:600px;margin:0 auto;"
                + "padding:20px;border:1px solid #e5e7eb;border-radius:12px;background:#fff'>"
                + "  <div style='text-align:center;margin-bottom:20px'>"
                + "    <h2 style='color:#182c54;margin:0'>PentaPlex Cinema</h2>"
                + "  </div>"
                + "  <hr style='border:0;border-top:1px solid #e5e7eb;margin-bottom:20px'>"
                + "  <div style='background:linear-gradient(135deg,#1d4ed8,#3b82f6);border-radius:12px;"
                + "       padding:24px;text-align:center;margin-bottom:20px'>"
                + "    <div style='font-size:2.5rem'>🎁</div>"
                + "    <h3 style='color:#fff;margin:8px 0 4px;font-size:1.4rem'>" + promotion.getName() + "</h3>"
                + "    <p style='color:#bfdbfe;margin:0'>Ưu đãi đặc biệt dành cho bạn!</p>"
                + "  </div>"
                + "  <div style='background:#eff6ff;border-radius:8px;padding:16px;text-align:center;margin-bottom:20px'>"
                + "    <p style='margin:0 0 8px;color:#6b7280;font-size:.9rem'>Giảm ngay</p>"
                + "    <p style='margin:0;font-size:2rem;font-weight:800;color:#1d4ed8'>" + discountStr + "</p>"
                + "    <div style='margin-top:12px;background:#fff;border:2px dashed #bfdbfe;"
                + "         border-radius:8px;padding:8px'>"
                + "      <p style='margin:0 0 2px;font-size:.75rem;color:#6b7280'>Mã khuyến mãi</p>"
                + "      <p style='margin:0;font-family:monospace;font-weight:800;font-size:1.2rem;"
                + "           color:#1d4ed8;letter-spacing:.1em'>" + promotion.getCode() + "</p>"
                + "    </div>"
                + "  </div>"
                + "  <p style='font-size:.85rem;color:#6b7280'>Trân trọng,<br>Đội ngũ PentaPlex</p>"
                + "</div>";

        // Gui theo batch nho (50/lan) de tranh bi spam filter
        int batchSize = 50;
        int totalSent = 0;
        for (int i = 0; i < emails.size(); i += batchSize) {
            java.util.List<String> batch = emails.subList(i, Math.min(i + batchSize, emails.size()));
            try {
                MimeMessage message = new MimeMessage(session);
                message.setFrom(new InternetAddress(senderEmail));
                // To: chinh la sender, BCC la batch customer
                message.addRecipient(Message.RecipientType.TO, new InternetAddress(senderEmail));
                for (String email : batch) {
                    message.addRecipient(Message.RecipientType.BCC, new InternetAddress(email));
                }
                message.setSubject("[PentaPlex] Ưu đãi mới: " + promotion.getName(), "UTF-8");
                message.setContent(html, "text/html; charset=UTF-8");
                Transport.send(message);
                totalSent += batch.size();
            } catch (MessagingException e) {
                System.err.println("[EmailUtil] Loi gui batch promo email (batch " + i + "): " + e.getMessage());
            }
        }
        System.out.println("[EmailUtil] Gui promo email: " + totalSent + "/" + emails.size() + " thanh cong.");
        return totalSent > 0;
    }

    // ── Private SMTP helpers (thay the code trung lap trong moi method) ───────
    private static boolean isConfigured(String email, String password) {
        return email != null && !email.equals("your-gmail@gmail.com")
                && password != null && !password.equals("your-app-password");
    }

    private static Properties buildSmtpProps() {
        Properties props = new Properties();
        props.put("mail.smtp.host", emailProps.getProperty("mail.smtp.host", "smtp.gmail.com"));
        props.put("mail.smtp.port", emailProps.getProperty("mail.smtp.port", "587"));
        props.put("mail.smtp.auth", emailProps.getProperty("mail.smtp.auth", "true"));
        props.put("mail.smtp.starttls.enable", emailProps.getProperty("mail.smtp.starttls.enable", "true"));
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");
        return props;
    }

    private static Session buildSession(Properties props, String email, String password) {
        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(email, password);
            }
        });
    }
}

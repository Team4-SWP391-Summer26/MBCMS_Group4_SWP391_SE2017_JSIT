package com.mbcms.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
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
            message.setSubject("[MBCMS] Password Reset Verification Code", "UTF-8");

            // Compose HTML message body
            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e5e7eb; border-radius: 12px; background-color: #ffffff;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h2 style='color: #182c54; margin: 0;'>MBCMS Cinema</h2>"
                    + "</div>"
                    + "<hr style='border: 0; border-top: 1px solid #e5e7eb; margin-bottom: 20px;'>"
                    + "<p>Hello,</p>"
                    + "<p>We received a request to reset the password for your MBCMS account. Please use the verification code below to proceed with resetting your password:</p>"
                    + "<div style='text-align: center; margin: 30px 0;'>"
                    + "  <span style='display: inline-block; font-size: 32px; font-weight: bold; color: #2563eb; letter-spacing: 6px; padding: 12px 24px; background-color: #f3f4f6; border-radius: 8px; border: 1px dashed #d1d5db;'>" + otpCode + "</span>"
                    + "</div>"
                    + "<p style='color: #ef4444; font-weight: 500;'>This code will expire in 15 minutes. For security, do not share this code with anyone.</p>"
                    + "<p>If you did not make this request, you can safely ignore this email. Your password will remain unchanged.</p>"
                    + "<br>"
                    + "<p>Thank you,<br>The MBCMS Team</p>"
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
}

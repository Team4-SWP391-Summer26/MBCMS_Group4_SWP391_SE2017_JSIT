package com.mbcms.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.InputStream;
import java.util.Properties;

/**
 * EmailUtil - Gui mail qua SMTP Gmail.
 * Neu khong cau hinh username/password, se in ra Console de test.
 */
public class EmailUtil {
    private static String smtpHost = "smtp.gmail.com";
    private static String smtpPort = "587";
    private static String username = "";
    private static String password = "";
    private static String fromEmail = "";

    static {
        try {
            Properties props = new Properties();
            InputStream is = EmailUtil.class.getClassLoader()
                    .getResourceAsStream("email.properties");
            if (is != null) {
                props.load(is);
                smtpHost = props.getProperty("mail.smtp.host", "smtp.gmail.com");
                smtpPort = props.getProperty("mail.smtp.port", "587");
                username = props.getProperty("mail.username", "");
                password = props.getProperty("mail.password", "");
                fromEmail = props.getProperty("mail.from", username);
            }
        } catch (Exception e) {
            System.err.println("[EmailUtil] Loi doc file email.properties: " + e.getMessage());
        }
    }

    /**
     * Gui email dang HTML
     */
    public static void sendEmail(String toEmail, String subject, String body) throws MessagingException {
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            // Che do gia lap (Mock Mode) - In ra console de nguoi phat trien lay ma OTP
            System.out.println("==========================================================================");
            System.out.println("[MOCK EMAIL SENDER - OTP FOR PASSWORD RESET]");
            System.out.println("TO: " + toEmail);
            System.out.println("SUBJECT: " + subject);
            System.out.println("BODY: " + body);
            System.out.println("==========================================================================");
            return;
        }

        Properties properties = new Properties();
        properties.put("mail.smtp.host", smtpHost);
        properties.put("mail.smtp.port", smtpPort);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(fromEmail));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(body, "text/html; charset=utf-8");

        Transport.send(message);
    }
}

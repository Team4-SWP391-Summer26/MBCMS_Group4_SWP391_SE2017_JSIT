package com.mbcms.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

import java.io.ByteArrayOutputStream;
import java.util.Base64;

/**
 * QRCodeUtil - Sinh ma QR su dung thu vien ZXing.
 */
public class QRCodeUtil {

    /**
     * Sinh ma QR duoi dang mang byte (PNG).
     */
    public static byte[] generateQRCodeBytes(String text, int width, int height) throws Exception {
        QRCodeWriter qrCodeWriter = new QRCodeWriter();
        BitMatrix bitMatrix = qrCodeWriter.encode(text, BarcodeFormat.QR_CODE, width, height);
        ByteArrayOutputStream pngOutputStream = new ByteArrayOutputStream();
        MatrixToImageWriter.writeToStream(bitMatrix, "PNG", pngOutputStream);
        return pngOutputStream.toByteArray();
    }

    /**
     * Sinh ma QR duoi dang chuoi Base64 (dung de hien thi trong the img src).
     */
    public static String generateQRCodeBase64(String text, int width, int height) {
        try {
            byte[] bytes = generateQRCodeBytes(text, width, height);
            return Base64.getEncoder().encodeToString(bytes);
        } catch (Exception e) {
            throw new RuntimeException("Loi sinh QR Code: " + e.getMessage(), e);
        }
    }
}

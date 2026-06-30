package com.mbcms.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.EnumMap;
import java.util.Map;

/**
 * QrCodeUtil - sinh ma QR (PNG) phia server bang ZXing.
 */
public final class QrCodeUtil {

    private QrCodeUtil() {}

    /**
     * Ghi QR cua {@code text} ra {@code out} duoi dang PNG vuong {@code size}px.
     */
    public static void writePng(String text, int size, OutputStream out)
            throws WriterException, IOException {
        Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
        // Error correction muc M: QR van doc duoc khi bi che/hong ~15% (mau in moi truong rap).
        hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        hints.put(EncodeHintType.MARGIN, 1);

        BitMatrix matrix = new QRCodeWriter()
                .encode(text, BarcodeFormat.QR_CODE, size, size, hints);
        MatrixToImageWriter.writeToStream(matrix, "PNG", out);
    }

    /**
     * Sinh ma QR cua {@code text} duoi dang byte array (PNG format).
     */
    public static byte[] generateQRCodeBytes(String text, int width, int height)
            throws WriterException, IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
        hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        hints.put(EncodeHintType.MARGIN, 1);

        BitMatrix matrix = new QRCodeWriter()
                .encode(text, BarcodeFormat.QR_CODE, width, height, hints);
        MatrixToImageWriter.writeToStream(matrix, "PNG", baos);
        return baos.toByteArray();
    }
}

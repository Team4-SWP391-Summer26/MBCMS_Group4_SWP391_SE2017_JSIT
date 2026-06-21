package com.mbcms.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.io.IOException;
import java.io.OutputStream;
import java.util.EnumMap;
import java.util.Map;

/**
 * QrCodeUtil - sinh ma QR (PNG) phia server bang ZXing.
 *
 * Dung cho ve dien tu (e-ticket): he thong TU DONG tao QR nhung ma booking_code
 * de staff quet/kiem tra ve tai cua rap. Sinh server-side => khong phu thuoc
 * internet/CDN, defendable tai van dap.
 */
public final class QrCodeUtil {

    private QrCodeUtil() {}

    /**
     * Ghi QR cua {@code text} ra {@code out} duoi dang PNG vuong {@code size}px.
     *
     * @param text noi dung ma hoa (vd booking_code "BK-19D6D1")
     * @param size canh anh (px), vd 200
     * @param out  stream dich (vd response.getOutputStream())
     */
    public static void writePng(String text, int size, OutputStream out)
            throws WriterException, IOException {
        Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
        hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        hints.put(EncodeHintType.MARGIN, 1);

        BitMatrix matrix = new QRCodeWriter()
                .encode(text, BarcodeFormat.QR_CODE, size, size, hints);
        MatrixToImageWriter.writeToStream(matrix, "PNG", out);
    }
}

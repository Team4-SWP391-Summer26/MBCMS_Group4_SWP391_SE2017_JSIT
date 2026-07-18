package com.mbcms.dao.impl;

import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.model.Showtime;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ShowtimeDAOImpl extends BaseDAO implements ShowtimeDAO {

    /** PENDING counts only if hold not expired (align with SeatDAOImpl.findOccupiedSeatIds). */
    private static final String ACTIVE_BOOKING_FILTER =
            " AND b.status IN ('PENDING','CONFIRMED','USED') "
            + " AND (b.[status] != 'PENDING' "
            + "      OR DATEADD(MINUTE, dbo.fn_setting_int('pending_hold_minutes', 10), b.created_at) > SYSUTCDATETIME()) ";

    // SELECT chung cho findByBranch + findById.
    // Subquery dem ghe da dat: chi tinh booking con hieu luc, bo PENDING het han.
    private static final String BASE_SELECT
            = "SELECT st.showtime_id, st.room_id, st.movie_id, st.start_time, st.end_time, "
            + "st.base_price, st.format, st.subtitle_type, st.status, "
            + "m.title AS movie_title, m.poster_url AS poster_url, r.name AS room_name, r.room_type AS room_type, r.capacity AS room_capacity, "
            + "(SELECT COUNT(*) FROM booking_seats bs "
            + " JOIN bookings b ON bs.booking_id = b.booking_id "
            + " WHERE b.showtime_id = st.showtime_id "
            + ACTIVE_BOOKING_FILTER
            + ") AS booked_seats "
            + "FROM showtimes st "
            + "JOIN movies m ON st.movie_id = m.movie_id "
            + "JOIN rooms r ON st.room_id = r.room_id ";

    /**
     * Lay danh sach suat chieu cua 1 branch, co the loc them theo
     * phim/phong/ngay. 3 filter movieId, roomId, date la TUY CHON: null = bo
     * qua filter do. Cau SQL duoc build DONG theo filter nao co mat (xem ben
     * duoi).
     */
    @Override
    public List<Showtime> findByBranch(long branchId, Long movieId, Long roomId, LocalDate date) {
        StringBuilder sql = new StringBuilder(BASE_SELECT + "WHERE r.branch_id = ?");

        // Filter dong: chi append menh de CO DINH, gia tri van di qua PreparedStatement (?)
        // -> khong co nguy co SQL Injection.
        if (movieId != null) {
            sql.append(" AND st.movie_id = ?");
        }
        if (roomId != null) {
            sql.append(" AND st.room_id = ?");
        }
        if (date != null) {
            sql.append(" AND CAST(st.start_time AS DATE) = ?");
        }
        sql.append(" ORDER BY st.start_time");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());

            // Gan gia tri cho cac dau ? theo DUNG THU TU da append o tren.
            // idx tu tang (idx++) -> chi set ? cho filter nao thuc su co mat,
            // khop chinx xac so luong dau ? trong cau SQL dong phia tren.
            int idx = 1;
            ps.setLong(idx++, branchId);
            if (movieId != null) {
                ps.setLong(idx++, movieId);
            }
            if (roomId != null) {
                ps.setLong(idx++, roomId);
            }
            if (date != null) {
                ps.setDate(idx++, java.sql.Date.valueOf(date));
            }

            rs = ps.executeQuery();

            // Duyet tung dong ket qua -> chuyen thanh object Showtime -> bo vao list.
            List<Showtime> showtimes = new ArrayList<>();
            while (rs.next()) {
                showtimes.add(mapRow(rs));
            }
            return showtimes;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van showtimes.findByBranch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Check trung lich + INSERT trong CUNG 1 transaction (diem defend van dap):
     *
     * 2 suat chieu CHONG LAN khi: new.start < old.end AND new.end > old.start.
     * UNIQUE(room_id, start_time) chi chan trung CHINH XAC gio bat dau, khong
     * chan chong lan mot phan -> bat buoc check bang query nay.
     *
     * Moi chi nhanh chi co 1 Branch Manager (xem employees) -> khong co canh
     * 2 nguoi cung xep lich 1 phong. Check-then-INSERT trong 1 transaction la
     * du; khong dung sp_getapplock (khoa ung dung tung gay ket lam chet ca
     * chuc nang tao suat).
     */
    @Override
    public boolean createWithConflictCheck(Showtime st) {
        // Cleaning buffer from Admin Settings (showtime_gap_minutes, default 30).
        String checkSql = "SELECT COUNT(*) FROM showtimes "
                + "WHERE room_id = ? AND status = 'SCHEDULED' "
                + "AND start_time < DATEADD(MINUTE, dbo.fn_setting_int('showtime_gap_minutes', 30), ?) "
                + "AND DATEADD(MINUTE, dbo.fn_setting_int('showtime_gap_minutes', 30), end_time) > ?";

        String insertSql = "INSERT INTO showtimes "
                + "(room_id, movie_id, start_time, end_time, base_price, format, subtitle_type, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psInsert = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false); // bat dau transaction

            // 1. Check overlap trong cung phong
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setLong(1, st.getRoomId());
            psCheck.setTimestamp(2, Timestamp.valueOf(st.getEndTime()));   // old.start < new.end
            psCheck.setTimestamp(3, Timestamp.valueOf(st.getStartTime())); // old.end > new.start
            rs = psCheck.executeQuery();

            rs.next();
            if (rs.getInt(1) > 0) {
                conn.rollback();
                return false; // trung lich
            }

            // 2. Khong trung -> INSERT
            psInsert = conn.prepareStatement(insertSql);
            psInsert.setLong(1, st.getRoomId());
            psInsert.setLong(2, st.getMovieId());
            psInsert.setTimestamp(3, Timestamp.valueOf(st.getStartTime()));
            psInsert.setTimestamp(4, Timestamp.valueOf(st.getEndTime()));
            psInsert.setBigDecimal(5, st.getBasePrice());
            psInsert.setString(6, st.getFormat());
            psInsert.setString(7, st.getSubtitleType());
            psInsert.setString(8, st.getStatus());
            psInsert.executeUpdate();

            conn.commit(); // ket thuc transaction
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            // Neu 2 request lach qua duoc check cung luc, UNIQUE(room_id, start_time)
            // se nem loi o day -> van khong the co 2 suat trung gio bat dau.
            throw new RuntimeException("Loi tao showtimes.createWithConflictCheck: " + e.getMessage(), e);
        } finally {
            // Tra connection ve che do autocommit truoc khi tra lai pool (vi minh da tat o tren).
            restoreAutoCommitQuietly(conn);
            // Co 2 PreparedStatement (check va insert) nen phai dong ca hai.
            // Dong dau: rs + psCheck (truyen null o vi tri conn de CHUA dong connection).
            // Dong sau: psInsert + conn (dong connection o buoc cuoi cung).
            closeAll(rs, psCheck, null);
            closeAll(psInsert, conn);
        }
    }

    /**
     * Tim 1 suat chieu theo khoa chinh showtime_id. Dung lai BASE_SELECT (co
     * JOIN movies + rooms + dem ghe da dat) nhung loc theo id.
     *
     * @return object Showtime neu tim thay; null neu khong co suat nao co id
     * do.
     */
    @Override
    public Showtime findById(long showtimeId) {
        String sql = BASE_SELECT + "WHERE st.showtime_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, showtimeId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van showtimes.findById: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Giong createWithConflictCheck nhung check LOAI TRU CHINH NO (showtime_id
     * <> ?) - neu khong, sua suat ma giu nguyen gio se bi bao trung voi...
     * chinh suat dang sua.
     */
    @Override
    public boolean updateWithConflictCheck(Showtime st) {
        String checkSql = "SELECT COUNT(*) FROM showtimes "
                + "WHERE room_id = ? AND status = 'SCHEDULED' "
                + "AND start_time < DATEADD(MINUTE, dbo.fn_setting_int('showtime_gap_minutes', 30), ?) "
                + "AND DATEADD(MINUTE, dbo.fn_setting_int('showtime_gap_minutes', 30), end_time) > ? "
                + "AND showtime_id <> ?";

        String updateSql = "UPDATE showtimes SET room_id = ?, movie_id = ?, start_time = ?, "
                + "end_time = ?, base_price = ?, format = ?, subtitle_type = ? "
                + "WHERE showtime_id = ? AND status = 'SCHEDULED'";

        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psUpdate = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            psCheck = conn.prepareStatement(checkSql);
            psCheck.setLong(1, st.getRoomId());
            psCheck.setTimestamp(2, Timestamp.valueOf(st.getEndTime()));
            psCheck.setTimestamp(3, Timestamp.valueOf(st.getStartTime()));
            psCheck.setLong(4, st.getShowtimeId());
            rs = psCheck.executeQuery();

            rs.next();
            if (rs.getInt(1) > 0) {
                conn.rollback();
                return false; // trung lich voi suat KHAC
            }

            psUpdate = conn.prepareStatement(updateSql);
            psUpdate.setLong(1, st.getRoomId());
            psUpdate.setLong(2, st.getMovieId());
            psUpdate.setTimestamp(3, Timestamp.valueOf(st.getStartTime()));
            psUpdate.setTimestamp(4, Timestamp.valueOf(st.getEndTime()));
            psUpdate.setBigDecimal(5, st.getBasePrice());
            psUpdate.setString(6, st.getFormat());
            psUpdate.setString(7, st.getSubtitleType());
            psUpdate.setLong(8, st.getShowtimeId());
            psUpdate.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            throw new RuntimeException("Loi cap nhat showtimes.updateWithConflictCheck: " + e.getMessage(), e);
        } finally {
            restoreAutoCommitQuietly(conn);
            closeAll(rs, psCheck, null);
            closeAll(psUpdate, conn);
        }
    }

    /**
     * Kiem tra suat chieu nay da co ai dat ve chua (booking con hieu luc). Dung
     * "SELECT 1 ... " (chi can biet CO/KHONG, khong can dem so luong) cho nhe.
     * Bo qua booking CANCELLED vi nhung ve da huy khong tinh la dang giu cho.
     *
     * @return true neu co it nhat 1 booking PENDING/CONFIRMED/USED.
     */
    @Override
    public boolean hasActiveBookings(long showtimeId) {
        String sql = "SELECT 1 FROM bookings b "
                + "WHERE b.showtime_id = ? "
                + ACTIVE_BOOKING_FILTER;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, showtimeId);
            rs = ps.executeQuery();

            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van showtimes.hasActiveBookings: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Huy 1 suat chieu = doi status sang CANCELLED (soft cancel). KHONG DELETE
     * de giu lich su va cac booking dang tham chieu toi suat nay.
     *
     * @return true neu co dung 1 dong bi cap nhat (huy thanh cong); false neu
     * khong.
     */
    @Override
    public boolean cancel(long showtimeId) {
        // Soft cancel: doi status, KHONG DELETE (giu lich su + booking tham chieu).
        // Dieu kien status = 'SCHEDULED' chan huy lai suat da CANCELLED/ENDED.
        String sql = "UPDATE showtimes SET status = 'CANCELLED' "
                + "WHERE showtime_id = ? AND status = 'SCHEDULED'";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, showtimeId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi cap nhat showtimes.cancel: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    /**
     * Rollback transaction "nhe nhang": neu rollback cung loi thi chi log,
     * khong nem tiep.
     */
    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                System.err.println("Loi rollback showtimes: " + e.getMessage());
            }
        }
    }

    /**
     * Bat lai autocommit truoc khi connection ve pool (vi mac dinh pool ky vong
     * autocommit=true).
     */
    private void restoreAutoCommitQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("Loi restore autocommit: " + e.getMessage());
            }
        }
    }

    @Override
    public List<Showtime> findByMovieId(long movieId) {
        String sql = "SELECT " + "showtime_id, room_id, movie_id, start_time, end_time, "
                + "base_price, format, subtitle_type, status" + " FROM showtimes "
                + "WHERE movie_id = ? AND status = 'SCHEDULED' AND start_time > GETDATE() "
                + "ORDER BY start_time";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Showtime> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, movieId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Loi findByMovieId showtime: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean hasUnfinishedShowtimes(long branchId, long movieId) {
        // SCHEDULED + end_time > now = dang chieu hoac se chieu. Di qua room -> branch
        // vi showtimes khong co branch_id truc tiep.
        String sql = "SELECT 1 FROM showtimes st "
                + "JOIN rooms r ON r.room_id = st.room_id "
                + "WHERE r.branch_id = ? AND st.movie_id = ? "
                + "AND st.status = 'SCHEDULED' AND st.end_time > GETDATE()";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            ps.setLong(2, movieId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van showtimes.hasUnfinishedShowtimes: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Chuyen 1 dong (row) cua ResultSet thanh 1 object Showtime. Tach rieng ra
     * ham nay de findByBranch va findById dung chung, khong lap code.
     */
    private Showtime mapRow(ResultSet rs) throws SQLException {
        Showtime st = new Showtime();
        st.setShowtimeId(rs.getLong("showtime_id"));
        st.setRoomId(rs.getLong("room_id"));
        st.setMovieId(rs.getLong("movie_id"));
        st.setStartTime(rs.getTimestamp("start_time").toLocalDateTime());
        st.setEndTime(rs.getTimestamp("end_time").toLocalDateTime());
        st.setBasePrice(rs.getBigDecimal("base_price"));
        st.setFormat(rs.getString("format"));
        st.setSubtitleType(rs.getString("subtitle_type"));
        st.setStatus(rs.getString("status"));
        // Display fields tu JOIN
        st.setMovieTitle(rs.getString("movie_title"));
        st.setPosterUrl(rs.getString("poster_url"));
        st.setRoomName(rs.getString("room_name"));
        st.setRoomType(rs.getString("room_type"));
        st.setRoomCapacity(rs.getInt("room_capacity"));
        st.setBookedSeats(rs.getInt("booked_seats"));
        return st;
    }
}

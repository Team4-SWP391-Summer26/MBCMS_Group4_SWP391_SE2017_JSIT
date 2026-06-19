package com.mbcms.service.impl;

import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;
import com.mbcms.service.SeatAvailabilityService;

import java.util.*;

public class SeatAvailabilityServiceImpl implements SeatAvailabilityService {

    private final SeatDAO seatDAO;
    private final ShowtimeDAO showtimeDAO;

    public SeatAvailabilityServiceImpl() {
        this.seatDAO = new SeatDAOImpl();
        this.showtimeDAO = new ShowtimeDAOImpl();
    }

    public SeatAvailabilityServiceImpl(SeatDAO seatDAO, ShowtimeDAO showtimeDAO) {
        this.seatDAO = seatDAO;
        this.showtimeDAO = showtimeDAO;
    }

    @Override
    public List<Seat> getSeats(long showtimeId) {
        Showtime st = requireShowtime(showtimeId);
        return seatDAO.findByRoom(st.getRoomId());
    }

    @Override
    public Set<Long> getBookedSeatIds(long showtimeId) {
        return seatDAO.findBookedSeatIds(showtimeId);
    }

    @Override
    public Map<String, List<Seat>> getSeatsByRow(long showtimeId) {
        List<Seat> seats = getSeats(showtimeId);
        Map<String, List<Seat>> byRow = new LinkedHashMap<>();
        for (Seat seat : seats) {
            byRow.computeIfAbsent(seat.getRowLabel(), k -> new ArrayList<>())
                    .add(seat);
        }
        return byRow;
    }

    @Override
    public int countAvailable(long showtimeId) {
        List<Seat> seats = getSeats(showtimeId);
        Set<Long> booked = getBookedSeatIds(showtimeId);
        int count = 0;
        for (Seat seat : seats) {
            if (seat.isActive() && !booked.contains(seat.getSeatId())) {
                count++;
            }
        }
        return count;
    }

    @Override
    public boolean isSeatAvailable(long showtimeId, long seatId) {
        Set<Long> booked = getBookedSeatIds(showtimeId);
        for (Seat seat : getSeats(showtimeId)) {
            if (seat.getSeatId() == seatId) {
                return seat.isActive() && !booked.contains(seatId);
            }
        }
        return false;
    }

    @Override
    public Showtime getShowtime(long showtimeId) {
        return showtimeDAO.findById(showtimeId);
    }

    private Showtime requireShowtime(long showtimeId){
        Showtime st = showtimeDAO.findById(showtimeId);
        if (st == null) {
            throw new IllegalArgumentException(
                    "Showtime khong ton tai: " + showtimeId);
        }
        return st;
    }

}

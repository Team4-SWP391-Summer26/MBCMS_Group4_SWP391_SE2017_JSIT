/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mbcms.dao;

import com.mbcms.model.Seat;
import java.util.List;
import java.util.Set;

/**
 *
 * @author Lenovo
 */
public interface SeatDAO {
    
    List<Seat> findByRoom(long roomId);
    Set<Long> findBookedSeatIds(long showtimeId);
    
}

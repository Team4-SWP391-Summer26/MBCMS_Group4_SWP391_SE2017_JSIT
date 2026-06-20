package com.mbcms.service;

import com.mbcms.model.Seat;

import java.util.List;
import java.util.Map;

/**
 * SeatManagementService - business logic cho "Manage seat types" (Feature 3).
 * Cho phep Branch Manager phan loai ghe STANDARD / VIP theo tung phong.
 * Owner: HungNT.
 *
 * Moi quy tac nghiep vu (verify phong thuoc dung branch, whitelist loai ghe,
 * chi update ghe thuoc phong) nam o tang nay - servlet KHONG tu kiem tra.
 */
public interface SeatManagementService {

    String RESULT_OK = "OK";
    String RESULT_ROOM_INVALID = "ROOM_INVALID";     // phong khong thuoc branch / khong active
    String RESULT_INVALID_INPUT = "INVALID_INPUT";   // loai ghe khong hop le

    /**
     * Lay danh sach ghe cua 1 phong de hien so do.
     * @return danh sach ghe (sap theo row, col); null neu phong khong thuoc
     *         branch nay (khong tiet lo phong cua branch khac).
     */
    List<Seat> getSeatsForRoom(long roomId, long branchId);

    /**
     * Cap nhat loai ghe cho phong. Chi update nhung ghe THUC SU doi loai
     * va THUOC dung phong; bo qua seatId khong hop le.
     *
     * @param seatTypes map seatId -> seat_type moi ('STANDARD' | 'VIP')
     * @return RESULT_OK | RESULT_ROOM_INVALID | RESULT_INVALID_INPUT
     */
    String updateSeatTypes(long roomId, long branchId, Map<Long, String> seatTypes);
}

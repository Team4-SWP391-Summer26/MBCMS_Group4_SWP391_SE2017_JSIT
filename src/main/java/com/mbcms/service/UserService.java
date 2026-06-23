package com.mbcms.service;

import com.mbcms.dto.UserDTO;
import com.mbcms.dto.UserStatsDTO;
import java.util.List;

public interface UserService {
    List<UserDTO> getUsers(String search, String role, Long branchId, String status, int page, int pageSize);
    int getTotalUsersCount(String search, String role, Long branchId, String status);
    UserStatsDTO getUserStats();
    UserDTO getUserByUsername(String username);
    
    boolean addUser(UserDTO user, String rawPassword);
    boolean editUser(UserDTO user, String rawPassword, String currentUserSessionUsername);
    boolean toggleStatus(String username, boolean active, String currentUserSessionUsername);
    boolean deleteUser(String username, String currentUserSessionUsername);
    boolean sendPasswordResetEmail(String username);
}

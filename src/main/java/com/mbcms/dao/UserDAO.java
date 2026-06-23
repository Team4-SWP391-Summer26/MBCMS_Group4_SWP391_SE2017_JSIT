package com.mbcms.dao;

import com.mbcms.dto.UserDTO;
import com.mbcms.dto.UserStatsDTO;
import java.util.List;

public interface UserDAO {
    List<UserDTO> searchUsers(String search, String role, Long branchId, String status, int offset, int limit);
    int countUsers(String search, String role, Long branchId, String status);
    UserStatsDTO getUserStats();
    UserDTO findByUsername(String username);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    boolean hasRelatedTransactions(String username, String role);

    // Mutation methods
    boolean insertCustomer(UserDTO user, String passwordHash);
    boolean updateCustomer(UserDTO user, String passwordHash);
    boolean deleteCustomer(String username);

    boolean insertEmployee(UserDTO user, String passwordHash);
    boolean updateEmployee(UserDTO user, String passwordHash);
    boolean deleteEmployee(String username);

    boolean updateActiveStatus(String username, String role, boolean active);
    boolean updatePassword(String username, String role, String passwordHash);
}

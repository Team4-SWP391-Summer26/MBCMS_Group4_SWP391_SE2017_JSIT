package com.mbcms.dao;

import com.mbcms.model.SystemSetting;

import java.util.List;
import java.util.Map;

public interface SystemSettingDAO {

    List<SystemSetting> findAll();

    String findValue(String key);

    void upsert(String key, String value);

    void upsertAll(Map<String, String> values);
}

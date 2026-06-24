package com.mbcms.service;

import com.mbcms.model.Customer;

/**
 * GoogleOAuthService - hop dong nghiep vu cho luong dang nhap Google OAuth 2.0.
 * Tach biet HTTP I/O (goi Google API) khoi servlet de de unit-test va thay the.
 */
public interface GoogleOAuthService {


    String buildAuthorizationUrl(String state);

    /*
     * Doi authorization code lay access_token tu Google token endpoint.
     *
     */
    String exchangeCodeForToken(String code);

    Customer loginWithGoogle(String accessToken);
}

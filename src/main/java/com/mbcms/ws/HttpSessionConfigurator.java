package com.mbcms.ws;

import com.mbcms.model.Customer;
import jakarta.servlet.http.HttpSession;
import jakarta.websocket.HandshakeResponse;
import jakarta.websocket.server.HandshakeRequest;
import jakarta.websocket.server.ServerEndpointConfig;

/**
 * Truyền username từ HTTP session sang WebSocket session.
 * Khai báo trong @ServerEndpoint(configurator = HttpSessionConfigurator.class)
 */
public class HttpSessionConfigurator extends ServerEndpointConfig.Configurator {

    @Override
    public void modifyHandshake(ServerEndpointConfig config,
                                HandshakeRequest request,
                                HandshakeResponse response) {
        HttpSession httpSession = (HttpSession) request.getHttpSession();
        if (httpSession != null) {
            Customer customer = (Customer) httpSession.getAttribute("customer");
            if (customer != null) {
                config.getUserProperties().put("username", customer.getUsername());
                return;
            }
        }
        config.getUserProperties().put("username", "guest_" + System.currentTimeMillis());
    }
}
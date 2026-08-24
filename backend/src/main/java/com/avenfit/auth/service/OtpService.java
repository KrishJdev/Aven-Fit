package com.avenfit.auth.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * MVP placeholder OTP service per DEVELOPMENT_PLAN.md Task 2.2:
 * a static OTP (123456) is "sent" by logging it. No real SMS provider is
 * integrated yet — replace with an SMS gateway before production.
 */
@Service
public class OtpService {

    public static final String MVP_STATIC_OTP = "123456";
    public static final int OTP_EXPIRES_IN_SECONDS = 300;

    private static final Logger log = LoggerFactory.getLogger(OtpService.class);

    /**
     * "Sends" an OTP to the phone number. MVP: logs the static OTP.
     */
    public void sendOtp(String phoneNumber) {
        log.info("[OTP PLACEHOLDER] OTP for {} is {} (valid {}s) — no real SMS sent",
                phoneNumber, MVP_STATIC_OTP, OTP_EXPIRES_IN_SECONDS);
    }

    public boolean verifyOtp(String phoneNumber, String otp) {
        return MVP_STATIC_OTP.equals(otp);
    }
}

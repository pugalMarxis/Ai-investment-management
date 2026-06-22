package com.investms.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Password hashing utility using SHA-256 + random salt.
 * For production, replace with BCrypt (add bcrypt library to libs).
 */
public class PasswordUtil {

    private static final Logger LOGGER = Logger.getLogger(PasswordUtil.class.getName());
    private static final String ALGORITHM = "SHA-256";
    private static final int SALT_BYTES = 16;

    private PasswordUtil() {}

    /** Generate a random Base64 salt. */
    public static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] saltBytes = new byte[SALT_BYTES];
        random.nextBytes(saltBytes);
        return Base64.getEncoder().encodeToString(saltBytes);
    }

    /** Hash password with provided salt. Returns "salt:hash". */
    public static String hashPassword(String plainPassword, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(salt.getBytes());
            byte[] hashedBytes = md.digest(plainPassword.getBytes());
            String hash = Base64.getEncoder().encodeToString(hashedBytes);
            return salt + ":" + hash;
        } catch (NoSuchAlgorithmException e) {
            LOGGER.log(Level.SEVERE, "SHA-256 not available", e);
            throw new RuntimeException("Hashing algorithm unavailable", e);
        }
    }

    /** Hash password with a fresh random salt. Returns "salt:hash". */
    public static String hashPassword(String plainPassword) {
        return hashPassword(plainPassword, generateSalt());
    }

    /**
     * Verify plain password against stored "salt:hash" string.
     */
    public static boolean verifyPassword(String plainPassword, String storedHash) {
        if (storedHash == null || !storedHash.contains(":")) return false;
        String[] parts = storedHash.split(":", 2);
        String salt = parts[0];
        String expected = hashPassword(plainPassword, salt);
        return expected.equals(storedHash);
    }
}

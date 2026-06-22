-- ============================================================
-- AI POWERED INVESTMENT MANAGEMENT SYSTEM
-- Database: investment_ms
-- Author: InvestMS
-- ============================================================

CREATE DATABASE IF NOT EXISTS investment_ms
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE investment_ms;

-- ============================================================
-- TABLE: roles
-- ============================================================
CREATE TABLE IF NOT EXISTS roles (
    role_id   INT          NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(50)  NOT NULL UNIQUE,
    PRIMARY KEY (role_id)
) ENGINE=InnoDB;

INSERT INTO roles (role_name) VALUES ('ADMIN'), ('INVESTOR');

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    user_id        INT           NOT NULL AUTO_INCREMENT,
    full_name      VARCHAR(120)  NOT NULL,
    email          VARCHAR(150)  NOT NULL UNIQUE,
    password_hash  VARCHAR(255)  NOT NULL,
    phone          VARCHAR(20),
    role_id        INT           NOT NULL DEFAULT 2,
    status         ENUM('ACTIVE','INACTIVE','SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    profile_pic    VARCHAR(255)  DEFAULT NULL,
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(role_id)
) ENGINE=InnoDB;

-- Default admin  (password: Admin@123  — bcrypt hash stored below)
INSERT INTO users (full_name, email, password_hash, phone, role_id, status)
VALUES (
    'System Administrator',
    'admin@investms.com',
    '$2a$12$KIX/6oqYpNmHZ3GX5u9kBOZyqHSMrWkYgTbQuLpWzAoUnzBsM.OoO',
    '+1-555-0100',
    1,
    'ACTIVE'
);

-- ============================================================
-- TABLE: portfolios
-- ============================================================
CREATE TABLE IF NOT EXISTS portfolios (
    portfolio_id    INT           NOT NULL AUTO_INCREMENT,
    user_id         INT           NOT NULL,
    portfolio_name  VARCHAR(150)  NOT NULL,
    description     TEXT,
    risk_level      ENUM('LOW','MEDIUM','HIGH') NOT NULL DEFAULT 'MEDIUM',
    target_amount   DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    current_value   DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    status          ENUM('ACTIVE','CLOSED','PAUSED') NOT NULL DEFAULT 'ACTIVE',
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (portfolio_id),
    CONSTRAINT fk_portfolio_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: assets
-- ============================================================
CREATE TABLE IF NOT EXISTS assets (
    asset_id     INT           NOT NULL AUTO_INCREMENT,
    asset_name   VARCHAR(150)  NOT NULL,
    asset_type   ENUM('STOCK','BOND','CRYPTO','REAL_ESTATE','MUTUAL_FUND','ETF','COMMODITY','OTHER') NOT NULL,
    symbol       VARCHAR(20),
    description  TEXT,
    risk_rating  TINYINT       NOT NULL DEFAULT 5  COMMENT '1=lowest risk, 10=highest risk',
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (asset_id)
) ENGINE=InnoDB;

-- Seed assets
INSERT INTO assets (asset_name, asset_type, symbol, description, risk_rating) VALUES
('Apple Inc.',            'STOCK',       'AAPL',  'Technology company',              6),
('Microsoft Corp.',       'STOCK',       'MSFT',  'Technology company',              5),
('Bitcoin',               'CRYPTO',      'BTC',   'Leading cryptocurrency',          9),
('Ethereum',              'CRYPTO',      'ETH',   'Smart contract platform',         8),
('US Treasury Bond 10Y',  'BOND',        'USTB',  'US government bond',             2),
('S&P 500 ETF',           'ETF',         'SPY',   'Tracks S&P 500 index',           4),
('Gold Commodity',        'COMMODITY',   'GOLD',  'Physical gold tracking',          3),
('Vanguard Total Market', 'MUTUAL_FUND', 'VTI',   'Total stock market mutual fund',  4),
('Amazon.com Inc.',       'STOCK',       'AMZN',  'E-commerce & cloud',              6),
('Tesla Inc.',            'STOCK',       'TSLA',  'Electric vehicles & energy',      8);

-- ============================================================
-- TABLE: investments
-- ============================================================
CREATE TABLE IF NOT EXISTS investments (
    investment_id    INT           NOT NULL AUTO_INCREMENT,
    user_id          INT           NOT NULL,
    portfolio_id     INT           NOT NULL,
    asset_id         INT           NOT NULL,
    plan_name        VARCHAR(150)  NOT NULL,
    invested_amount  DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    current_value    DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    units            DECIMAL(18,6) NOT NULL DEFAULT 0.000000,
    buy_price        DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    current_price    DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    return_pct       DECIMAL(8,4)  NOT NULL DEFAULT 0.0000,
    status           ENUM('ACTIVE','SOLD','MATURED','PENDING') NOT NULL DEFAULT 'ACTIVE',
    notes            TEXT,
    invested_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (investment_id),
    CONSTRAINT fk_inv_user      FOREIGN KEY (user_id)      REFERENCES users(user_id)      ON DELETE CASCADE,
    CONSTRAINT fk_inv_portfolio FOREIGN KEY (portfolio_id) REFERENCES portfolios(portfolio_id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_asset     FOREIGN KEY (asset_id)     REFERENCES assets(asset_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: transactions
-- ============================================================
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id   INT           NOT NULL AUTO_INCREMENT,
    user_id          INT           NOT NULL,
    investment_id    INT           DEFAULT NULL,
    type             ENUM('DEPOSIT','WITHDRAWAL','BUY','SELL','DIVIDEND','FEE') NOT NULL,
    amount           DECIMAL(18,2) NOT NULL,
    fee              DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    balance_after    DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    description      VARCHAR(255),
    status           ENUM('PENDING','COMPLETED','FAILED','CANCELLED') NOT NULL DEFAULT 'COMPLETED',
    reference_no     VARCHAR(64)   UNIQUE,
    created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (transaction_id),
    CONSTRAINT fk_txn_user       FOREIGN KEY (user_id)      REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_txn_investment FOREIGN KEY (investment_id) REFERENCES investments(investment_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: ai_recommendations
-- ============================================================
CREATE TABLE IF NOT EXISTS ai_recommendations (
    rec_id            INT           NOT NULL AUTO_INCREMENT,
    user_id           INT           NOT NULL,
    recommendation    TEXT          NOT NULL,
    confidence_score  DECIMAL(5,2)  NOT NULL DEFAULT 0.00  COMMENT '0-100 percent',
    rec_type          ENUM('BUY','SELL','HOLD','REBALANCE','DIVERSIFY') NOT NULL,
    asset_id          INT           DEFAULT NULL,
    is_read           TINYINT(1)    NOT NULL DEFAULT 0,
    generated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (rec_id),
    CONSTRAINT fk_rec_user  FOREIGN KEY (user_id)  REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_rec_asset FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: reports
-- ============================================================
CREATE TABLE IF NOT EXISTS reports (
    report_id     INT           NOT NULL AUTO_INCREMENT,
    user_id       INT           NOT NULL,
    title         VARCHAR(200)  NOT NULL,
    content       LONGTEXT      NOT NULL,
    report_type   ENUM('PERFORMANCE','RISK','TAX','PORTFOLIO','AI_INSIGHT') NOT NULL,
    generated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (report_id),
    CONSTRAINT fk_report_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    notif_id    INT           NOT NULL AUTO_INCREMENT,
    user_id     INT           NOT NULL,
    title       VARCHAR(200)  NOT NULL,
    message     TEXT          NOT NULL,
    type        ENUM('INFO','SUCCESS','WARNING','DANGER') NOT NULL DEFAULT 'INFO',
    is_read     TINYINT(1)    NOT NULL DEFAULT 0,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notif_id),
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: chat_history  (AI Chatbot)
-- ============================================================
CREATE TABLE IF NOT EXISTS chat_history (
    chat_id     INT       NOT NULL AUTO_INCREMENT,
    user_id     INT       NOT NULL,
    role        ENUM('USER','AI') NOT NULL,
    message     TEXT      NOT NULL,
    created_at  DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (chat_id),
    CONSTRAINT fk_chat_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: user_wallet  (running balance)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_wallet (
    wallet_id   INT           NOT NULL AUTO_INCREMENT,
    user_id     INT           NOT NULL UNIQUE,
    balance     DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    total_invested DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    total_profit   DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (wallet_id),
    CONSTRAINT fk_wallet_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- VIEWS
-- ============================================================

-- Portfolio summary view
CREATE OR REPLACE VIEW vw_portfolio_summary AS
SELECT
    p.portfolio_id,
    p.user_id,
    u.full_name,
    p.portfolio_name,
    p.risk_level,
    p.target_amount,
    p.current_value,
    p.status,
    COUNT(i.investment_id)                           AS total_investments,
    COALESCE(SUM(i.invested_amount), 0)              AS total_invested,
    COALESCE(SUM(i.current_value), 0)                AS total_current_value,
    COALESCE(SUM(i.current_value - i.invested_amount), 0) AS total_profit_loss,
    CASE
        WHEN COALESCE(SUM(i.invested_amount), 0) = 0 THEN 0
        ELSE ROUND(
            (COALESCE(SUM(i.current_value - i.invested_amount), 0) /
             COALESCE(SUM(i.invested_amount), 1)) * 100, 2)
    END AS return_pct
FROM portfolios p
JOIN users u ON u.user_id = p.user_id
LEFT JOIN investments i ON i.portfolio_id = p.portfolio_id AND i.status = 'ACTIVE'
GROUP BY p.portfolio_id;

-- User investment overview
CREATE OR REPLACE VIEW vw_user_investment_overview AS
SELECT
    u.user_id,
    u.full_name,
    u.email,
    COALESCE(w.balance, 0)          AS wallet_balance,
    COALESCE(w.total_invested, 0)   AS total_invested,
    COALESCE(w.total_profit, 0)     AS total_profit,
    COUNT(DISTINCT p.portfolio_id)  AS portfolio_count,
    COUNT(DISTINCT i.investment_id) AS investment_count
FROM users u
LEFT JOIN user_wallet   w ON w.user_id = u.user_id
LEFT JOIN portfolios    p ON p.user_id = u.user_id AND p.status = 'ACTIVE'
LEFT JOIN investments   i ON i.user_id = u.user_id AND i.status = 'ACTIVE'
GROUP BY u.user_id;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- Recalculate portfolio current value
CREATE PROCEDURE sp_update_portfolio_value(IN p_portfolio_id INT)
BEGIN
    UPDATE portfolios
    SET current_value = (
        SELECT COALESCE(SUM(current_value), 0)
        FROM investments
        WHERE portfolio_id = p_portfolio_id AND status = 'ACTIVE'
    )
    WHERE portfolio_id = p_portfolio_id;
END$$

-- Update user wallet totals
CREATE PROCEDURE sp_update_wallet(IN p_user_id INT)
BEGIN
    DECLARE v_invested DECIMAL(18,2);
    DECLARE v_current  DECIMAL(18,2);

    SELECT COALESCE(SUM(invested_amount), 0),
           COALESCE(SUM(current_value), 0)
    INTO   v_invested, v_current
    FROM   investments
    WHERE  user_id = p_user_id AND status = 'ACTIVE';

    INSERT INTO user_wallet (user_id, total_invested, total_profit)
    VALUES (p_user_id, v_invested, v_current - v_invested)
    ON DUPLICATE KEY UPDATE
        total_invested = v_invested,
        total_profit   = v_current - v_invested;
END$$

DELIMITER ;

-- ============================================================
-- END OF SCRIPT
-- ============================================================

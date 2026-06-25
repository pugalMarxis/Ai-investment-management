-- ============================================================
-- AI POWERED INVESTMENT MANAGEMENT SYSTEM
-- Sample Data Script - Fills database with realistic test data
-- ============================================================
-- Run this AFTER importing investment_ms.sql
-- ============================================================

USE investment_ms;

-- ============================================================
-- STEP 1: Insert Test Users
-- All passwords below = "Admin@123" (SHA-256 hashed with salt)
-- ============================================================

-- Update existing admin password to SHA-256 format (password: Admin@123)
UPDATE users 
SET password_hash = 'kVMRDg8gIxqV3aQwjrtgQg==:HRJZ7nEEcRsoJ1uwYHGv3xKWVa6/2qkn/9C2hQM1ifM='
WHERE email = 'admin@investms.com';

-- Insert test investor users (all passwords = "Admin@123")
INSERT INTO users (full_name, email, password_hash, phone, role_id, status) VALUES
('John Smith',      'john@test.com',    'kVMRDg8gIxqV3aQwjrtgQg==:HRJZ7nEEcRsoJ1uwYHGv3xKWVa6/2qkn/9C2hQM1ifM=', '+1-555-0101', 2, 'ACTIVE'),
('Sarah Johnson',   'sarah@test.com',   'kVMRDg8gIxqV3aQwjrtgQg==:HRJZ7nEEcRsoJ1uwYHGv3xKWVa6/2qkn/9C2hQM1ifM=', '+1-555-0102', 2, 'ACTIVE'),
('Michael Chen',    'michael@test.com', 'kVMRDg8gIxqV3aQwjrtgQg==:HRJZ7nEEcRsoJ1uwYHGv3xKWVa6/2qkn/9C2hQM1ifM=', '+1-555-0103', 2, 'ACTIVE'),
('Emma Williams',   'emma@test.com',    'kVMRDg8gIxqV3aQwjrtgQg==:HRJZ7nEEcRsoJ1uwYHGv3xKWVa6/2qkn/9C2hQM1ifM=', '+1-555-0104', 2, 'ACTIVE'),
('David Brown',     'david@test.com',   'kVMRDg8gIxqV3aQwjrtgQg==:HRJZ7nEEcRsoJ1uwYHGv3xKWVa6/2qkn/9C2hQM1ifM=', '+1-555-0105', 2, 'ACTIVE');

-- ============================================================
-- STEP 2: Create wallets for all users with starting balance
-- ============================================================

INSERT INTO user_wallet (user_id, balance, total_invested, total_profit) VALUES
(1, 50000.00, 75000.00, 8500.00),  -- Admin
(2, 25000.00, 50000.00, 4200.00),  -- John
(3, 18000.00, 30000.00, 2800.00),  -- Sarah
(4, 35000.00, 65000.00, 7100.00),  -- Michael
(5,  8000.00, 15000.00,  -800.00), -- Emma (loss)
(6, 42000.00, 85000.00, 12500.00); -- David


-- ============================================================
-- STEP 3: Create Sample Portfolios
-- ============================================================

INSERT INTO portfolios (user_id, portfolio_name, description, risk_level, target_amount, current_value, status) VALUES
-- Admin portfolios
(1, 'Tech Growth Portfolio',    'Aggressive tech-focused portfolio with high growth potential', 'HIGH',   100000.00, 83500.00, 'ACTIVE'),
(1, 'Stable Income Portfolio',  'Conservative portfolio focused on bonds and dividends',        'LOW',     50000.00, 32000.00, 'ACTIVE'),
-- John's portfolios  
(2, 'Retirement Fund',          'Long-term wealth building for retirement at 65',                'MEDIUM',  200000.00, 54200.00, 'ACTIVE'),
(2, 'Crypto Speculation',       'High-risk cryptocurrency investments',                          'HIGH',    20000.00, 12500.00, 'ACTIVE'),
-- Sarah's portfolio
(3, 'Balanced Growth',          'Diversified portfolio with moderate risk',                      'MEDIUM',   75000.00, 32800.00, 'ACTIVE'),
-- Michael's portfolios
(4, 'Aggressive Tech Stocks',   'Heavy tech stock allocation for maximum growth',                'HIGH',   150000.00, 72100.00, 'ACTIVE'),
(4, 'Real Estate ETFs',         'Real estate investment trusts for steady income',               'LOW',     50000.00, 18000.00, 'ACTIVE'),
-- Emma's portfolio
(5, 'Beginner Portfolio',       'First-time investor learning the basics',                       'LOW',     25000.00, 14200.00, 'ACTIVE'),
-- David's portfolios
(6, 'Diversified Investments',  'Well-balanced across multiple asset classes',                   'MEDIUM',  250000.00, 97500.00, 'ACTIVE'),
(6, 'High-Risk Crypto Trading', 'Active crypto trading portfolio',                               'HIGH',    50000.00, 25500.00, 'ACTIVE');

-- ============================================================
-- STEP 4: Create Sample Investments
-- Asset IDs: 1=AAPL, 2=MSFT, 3=BTC, 4=ETH, 5=USTB, 6=SPY, 7=GOLD, 8=VTI, 9=AMZN, 10=TSLA
-- ============================================================

INSERT INTO investments (user_id, portfolio_id, asset_id, plan_name, invested_amount, current_value, units, buy_price, current_price, return_pct, status, notes) VALUES
-- Admin (user_id=1) - Tech Growth Portfolio (id=1)
(1, 1, 1,  'Apple Long Position',         15000.00, 18500.00, 100.000000, 150.0000, 185.0000,  23.33, 'ACTIVE', 'Strong fundamentals'),
(1, 1, 2,  'Microsoft Cloud Bet',         10000.00, 12300.00,  35.000000, 285.7143, 351.4286,  23.00, 'ACTIVE', 'Azure growth thesis'),
(1, 1, 9,  'Amazon E-commerce',           12000.00, 14800.00,  80.000000, 150.0000, 185.0000,  23.33, 'ACTIVE', 'AWS dominance'),
(1, 1, 10, 'Tesla EV Future',              8000.00,  6900.00,  40.000000, 200.0000, 172.5000, -13.75, 'ACTIVE', 'Volatile but long-term'),

-- Admin - Stable Income Portfolio (id=2)
(1, 2, 5,  'US Treasury 10Y',             20000.00, 21000.00, 200.000000, 100.0000, 105.0000,   5.00, 'ACTIVE', 'Safe haven'),
(1, 2, 6,  'S&P 500 ETF',                 12000.00, 13500.00,  30.000000, 400.0000, 450.0000,  12.50, 'ACTIVE', 'Broad market exposure'),

-- John (user_id=2) - Retirement Fund (id=3)
(2, 3, 6,  'S&P 500 Long Term',           20000.00, 22800.00,  50.000000, 400.0000, 456.0000,  14.00, 'ACTIVE', 'Buy and hold'),
(2, 3, 8,  'Vanguard Total Market',       15000.00, 17400.00, 150.000000, 100.0000, 116.0000,  16.00, 'ACTIVE', 'Diversification'),
(2, 3, 5,  'Treasury Bonds',              15000.00, 14000.00, 150.000000, 100.0000,  93.3333,  -6.67, 'ACTIVE', 'Interest rate risk'),

-- John - Crypto Speculation (id=4)
(2, 4, 3,  'Bitcoin DCA',                  8000.00, 10500.00,   0.150000, 53333.33, 70000.00,  31.25, 'ACTIVE', 'Long-term hold'),
(2, 4, 4,  'Ethereum Stake',               5000.00,  2000.00,   2.000000,  2500.00,  1000.00, -60.00, 'ACTIVE', 'Bear market loss'),

-- Sarah (user_id=3) - Balanced Growth (id=5)
(3, 5, 1,  'Apple Shares',                 5000.00,  6200.00,  33.000000, 151.5152, 187.8788,  24.00, 'ACTIVE', 'Tech leader'),
(3, 5, 2,  'Microsoft Position',           5000.00,  6100.00,  17.500000, 285.7143, 348.5714,  22.00, 'ACTIVE', 'Steady growth'),
(3, 5, 6,  'S&P 500 ETF',                  8000.00,  9000.00,  20.000000, 400.0000, 450.0000,  12.50, 'ACTIVE', 'Index investing'),
(3, 5, 7,  'Gold Hedge',                   4000.00,  4500.00,  20.000000, 200.0000, 225.0000,  12.50, 'ACTIVE', 'Inflation protection'),
(3, 5, 5,  'Bond Position',                3000.00,  3000.00,  30.000000, 100.0000, 100.0000,   0.00, 'ACTIVE', 'Stable yield'),

-- Michael (user_id=4) - Aggressive Tech Stocks (id=6)
(4, 6, 1,  'Apple Heavy',                 18000.00, 22500.00, 120.000000, 150.0000, 187.5000,  25.00, 'ACTIVE', 'High conviction'),
(4, 6, 2,  'Microsoft Mega Position',     15000.00, 18750.00,  52.500000, 285.7143, 357.1429,  25.00, 'ACTIVE', 'Cloud dominance'),
(4, 6, 9,  'Amazon Growth',               12000.00, 15600.00,  80.000000, 150.0000, 195.0000,  30.00, 'ACTIVE', 'E-commerce king'),
(4, 6, 10, 'Tesla Bet',                   10000.00,  8250.00,  50.000000, 200.0000, 165.0000, -17.50, 'ACTIVE', 'High risk'),

-- Michael - Real Estate ETFs (id=7)
(4, 7, 8,  'Real Estate Fund',            12000.00, 12600.00, 120.000000, 100.0000, 105.0000,   5.00, 'ACTIVE', 'Stable income'),
(4, 7, 5,  'Bond Mix',                     6000.00,  5400.00,  60.000000, 100.0000,  90.0000, -10.00, 'ACTIVE', 'Defensive'),

-- Emma (user_id=5) - Beginner Portfolio (id=8) - mostly losses
(5, 8, 10, 'Tesla First Buy',              5000.00,  4200.00,  25.000000, 200.0000, 168.0000, -16.00, 'ACTIVE', 'Bought at peak'),
(5, 8, 3,  'Bitcoin First Try',            5000.00,  4000.00,   0.093750, 53333.33, 42666.67, -20.00, 'ACTIVE', 'Market timing fail'),
(5, 8, 6,  'S&P 500 ETF',                  5000.00,  6000.00,  12.500000, 400.0000, 480.0000,  20.00, 'ACTIVE', 'Index always wins'),

-- David (user_id=6) - Diversified Investments (id=9)
(6, 9, 1,  'Apple Core Holding',          20000.00, 25000.00, 133.330000, 150.0000, 187.5000,  25.00, 'ACTIVE', 'Long-term winner'),
(6, 9, 2,  'Microsoft Cloud',              18000.00, 22500.00,  63.000000, 285.7143, 357.1429,  25.00, 'ACTIVE', 'AI growth'),
(6, 9, 6,  'S&P 500 Diversification',     15000.00, 16800.00,  37.500000, 400.0000, 448.0000,  12.00, 'ACTIVE', 'Broad market'),
(6, 9, 5,  'Treasury Bonds',              12000.00, 12500.00, 120.000000, 100.0000, 104.1667,   4.17, 'ACTIVE', 'Risk balance'),
(6, 9, 7,  'Gold Position',                8000.00,  9000.00,  40.000000, 200.0000, 225.0000,  12.50, 'ACTIVE', 'Hedge'),
(6, 9, 8,  'Mutual Fund',                 12000.00, 11700.00, 120.000000, 100.0000,  97.5000,  -2.50, 'ACTIVE', 'Slight loss'),

-- David - High-Risk Crypto Trading (id=10)
(6, 10, 3, 'Bitcoin Large Position',      15000.00, 19500.00,   0.281250, 53333.33, 69333.33,  30.00, 'ACTIVE', 'BTC bull thesis'),
(6, 10, 4, 'Ethereum Position',            8000.00,  6000.00,   3.200000,  2500.00,  1875.00, -25.00, 'ACTIVE', 'ETH underperform');


-- ============================================================
-- STEP 5: Create Sample Transactions
-- ============================================================

INSERT INTO transactions (user_id, investment_id, type, amount, fee, balance_after, description, status, reference_no, created_at) VALUES
-- Admin transactions
(1, NULL, 'DEPOSIT',     100000.00, 0.00, 100000.00, 'Initial deposit',          'COMPLETED', 'TXN-INITIAL001', DATE_SUB(NOW(), INTERVAL 90 DAY)),
(1, NULL, 'DEPOSIT',      25000.00, 0.00, 125000.00, 'Bank transfer',            'COMPLETED', 'TXN-DEPO00001A', DATE_SUB(NOW(), INTERVAL 60 DAY)),
(1, 1,    'BUY',          15000.00, 5.00, 110000.00, 'Bought: Apple Long Position',  'COMPLETED', 'TXN-BUY0000001', DATE_SUB(NOW(), INTERVAL 55 DAY)),
(1, 2,    'BUY',          10000.00, 5.00, 100000.00, 'Bought: Microsoft Cloud Bet',  'COMPLETED', 'TXN-BUY0000002', DATE_SUB(NOW(), INTERVAL 50 DAY)),
(1, 3,    'BUY',          12000.00, 5.00,  88000.00, 'Bought: Amazon E-commerce',    'COMPLETED', 'TXN-BUY0000003', DATE_SUB(NOW(), INTERVAL 45 DAY)),
(1, 4,    'BUY',           8000.00, 5.00,  80000.00, 'Bought: Tesla EV Future',      'COMPLETED', 'TXN-BUY0000004', DATE_SUB(NOW(), INTERVAL 40 DAY)),
(1, 5,    'BUY',          20000.00, 5.00,  60000.00, 'Bought: US Treasury 10Y',      'COMPLETED', 'TXN-BUY0000005', DATE_SUB(NOW(), INTERVAL 35 DAY)),
(1, 6,    'BUY',          12000.00, 5.00,  48000.00, 'Bought: S&P 500 ETF',          'COMPLETED', 'TXN-BUY0000006', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(1, 1,    'DIVIDEND',       450.00, 0.00,  48450.00, 'AAPL Quarterly Dividend',      'COMPLETED', 'TXN-DIV0000001', DATE_SUB(NOW(), INTERVAL 15 DAY)),
(1, 5,    'DIVIDEND',       250.00, 0.00,  48700.00, 'Treasury Interest',            'COMPLETED', 'TXN-DIV0000002', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(1, NULL, 'WITHDRAWAL',    2000.00, 0.00,  46700.00, 'Wallet withdrawal',            'COMPLETED', 'TXN-WD00000001', DATE_SUB(NOW(), INTERVAL 5 DAY)),

-- John transactions  
(2, NULL, 'DEPOSIT',      75000.00, 0.00,  75000.00, 'Initial fund',                 'COMPLETED', 'TXN-INITIAL002', DATE_SUB(NOW(), INTERVAL 85 DAY)),
(2, NULL, 'DEPOSIT',      15000.00, 0.00,  90000.00, 'Monthly contribution',         'COMPLETED', 'TXN-DEPO00002A', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(2, 7,    'BUY',          20000.00, 5.00,  70000.00, 'Bought: S&P 500 Long Term',    'COMPLETED', 'TXN-BUY0000007', DATE_SUB(NOW(), INTERVAL 70 DAY)),
(2, 8,    'BUY',          15000.00, 5.00,  55000.00, 'Bought: Vanguard Total Market','COMPLETED', 'TXN-BUY0000008', DATE_SUB(NOW(), INTERVAL 65 DAY)),
(2, 9,    'BUY',          15000.00, 5.00,  40000.00, 'Bought: Treasury Bonds',       'COMPLETED', 'TXN-BUY0000009', DATE_SUB(NOW(), INTERVAL 60 DAY)),
(2, 10,   'BUY',           8000.00, 5.00,  32000.00, 'Bought: Bitcoin DCA',          'COMPLETED', 'TXN-BUY0000010', DATE_SUB(NOW(), INTERVAL 55 DAY)),
(2, 11,   'BUY',           5000.00, 5.00,  27000.00, 'Bought: Ethereum Stake',       'COMPLETED', 'TXN-BUY0000011', DATE_SUB(NOW(), INTERVAL 50 DAY)),

-- Sarah transactions
(3, NULL, 'DEPOSIT',      50000.00, 0.00,  50000.00, 'Initial deposit',              'COMPLETED', 'TXN-INITIAL003', DATE_SUB(NOW(), INTERVAL 80 DAY)),
(3, 12,   'BUY',           5000.00, 2.50,  45000.00, 'Bought: Apple Shares',         'COMPLETED', 'TXN-BUY0000012', DATE_SUB(NOW(), INTERVAL 75 DAY)),
(3, 13,   'BUY',           5000.00, 2.50,  40000.00, 'Bought: Microsoft Position',   'COMPLETED', 'TXN-BUY0000013', DATE_SUB(NOW(), INTERVAL 70 DAY)),
(3, 14,   'BUY',           8000.00, 4.00,  32000.00, 'Bought: S&P 500 ETF',          'COMPLETED', 'TXN-BUY0000014', DATE_SUB(NOW(), INTERVAL 60 DAY)),
(3, 15,   'BUY',           4000.00, 2.00,  28000.00, 'Bought: Gold Hedge',           'COMPLETED', 'TXN-BUY0000015', DATE_SUB(NOW(), INTERVAL 50 DAY)),
(3, 16,   'BUY',           3000.00, 1.50,  25000.00, 'Bought: Bond Position',        'COMPLETED', 'TXN-BUY0000016', DATE_SUB(NOW(), INTERVAL 40 DAY)),
(3, NULL, 'WITHDRAWAL',    7000.00, 0.00,  18000.00, 'Cash withdrawal',              'COMPLETED', 'TXN-WD00000002', DATE_SUB(NOW(), INTERVAL 20 DAY)),

-- Michael transactions
(4, NULL, 'DEPOSIT',     100000.00, 0.00, 100000.00, 'Initial deposit',              'COMPLETED', 'TXN-INITIAL004', DATE_SUB(NOW(), INTERVAL 75 DAY)),
(4, 17,   'BUY',          18000.00, 9.00,  82000.00, 'Bought: Apple Heavy',          'COMPLETED', 'TXN-BUY0000017', DATE_SUB(NOW(), INTERVAL 70 DAY)),
(4, 18,   'BUY',          15000.00, 7.50,  67000.00, 'Bought: MS Mega Position',     'COMPLETED', 'TXN-BUY0000018', DATE_SUB(NOW(), INTERVAL 65 DAY)),
(4, 19,   'BUY',          12000.00, 6.00,  55000.00, 'Bought: Amazon Growth',        'COMPLETED', 'TXN-BUY0000019', DATE_SUB(NOW(), INTERVAL 60 DAY)),
(4, 20,   'BUY',          10000.00, 5.00,  45000.00, 'Bought: Tesla Bet',            'COMPLETED', 'TXN-BUY0000020', DATE_SUB(NOW(), INTERVAL 55 DAY)),
(4, 21,   'BUY',          12000.00, 6.00,  33000.00, 'Bought: Real Estate Fund',     'COMPLETED', 'TXN-BUY0000021', DATE_SUB(NOW(), INTERVAL 45 DAY)),
(4, 22,   'BUY',           6000.00, 3.00,  27000.00, 'Bought: Bond Mix',             'COMPLETED', 'TXN-BUY0000022', DATE_SUB(NOW(), INTERVAL 40 DAY)),

-- Emma transactions
(5, NULL, 'DEPOSIT',      20000.00, 0.00,  20000.00, 'First deposit',                'COMPLETED', 'TXN-INITIAL005', DATE_SUB(NOW(), INTERVAL 60 DAY)),
(5, 23,   'BUY',           5000.00, 2.50,  15000.00, 'Bought: Tesla First Buy',      'COMPLETED', 'TXN-BUY0000023', DATE_SUB(NOW(), INTERVAL 55 DAY)),
(5, 24,   'BUY',           5000.00, 2.50,  10000.00, 'Bought: Bitcoin First Try',    'COMPLETED', 'TXN-BUY0000024', DATE_SUB(NOW(), INTERVAL 45 DAY)),
(5, 25,   'BUY',           5000.00, 2.50,   5000.00, 'Bought: S&P 500 ETF',          'COMPLETED', 'TXN-BUY0000025', DATE_SUB(NOW(), INTERVAL 30 DAY)),

-- David transactions
(6, NULL, 'DEPOSIT',     150000.00, 0.00, 150000.00, 'Large initial deposit',        'COMPLETED', 'TXN-INITIAL006', DATE_SUB(NOW(), INTERVAL 90 DAY)),
(6, 26,   'BUY',          20000.00,10.00, 130000.00, 'Bought: Apple Core Holding',   'COMPLETED', 'TXN-BUY0000026', DATE_SUB(NOW(), INTERVAL 80 DAY)),
(6, 27,   'BUY',          18000.00, 9.00, 112000.00, 'Bought: Microsoft Cloud',      'COMPLETED', 'TXN-BUY0000027', DATE_SUB(NOW(), INTERVAL 75 DAY)),
(6, 28,   'BUY',          15000.00, 7.50,  97000.00, 'Bought: S&P 500 Div',          'COMPLETED', 'TXN-BUY0000028', DATE_SUB(NOW(), INTERVAL 70 DAY)),
(6, 29,   'BUY',          12000.00, 6.00,  85000.00, 'Bought: Treasury Bonds',       'COMPLETED', 'TXN-BUY0000029', DATE_SUB(NOW(), INTERVAL 65 DAY)),
(6, 30,   'BUY',           8000.00, 4.00,  77000.00, 'Bought: Gold Position',        'COMPLETED', 'TXN-BUY0000030', DATE_SUB(NOW(), INTERVAL 60 DAY)),
(6, 31,   'BUY',          12000.00, 6.00,  65000.00, 'Bought: Mutual Fund',          'COMPLETED', 'TXN-BUY0000031', DATE_SUB(NOW(), INTERVAL 55 DAY)),
(6, 32,   'BUY',          15000.00, 7.50,  50000.00, 'Bought: Bitcoin Large',        'COMPLETED', 'TXN-BUY0000032', DATE_SUB(NOW(), INTERVAL 45 DAY)),
(6, 33,   'BUY',           8000.00, 4.00,  42000.00, 'Bought: Ethereum Position',    'COMPLETED', 'TXN-BUY0000033', DATE_SUB(NOW(), INTERVAL 35 DAY));


-- ============================================================
-- STEP 6: Sample AI Recommendations
-- ============================================================

INSERT INTO ai_recommendations (user_id, recommendation, confidence_score, rec_type, asset_id, is_read) VALUES
(1, 'Your Tech Growth Portfolio shows strong returns (+23%). Consider taking partial profits on AAPL and reinvesting in bonds to lock in gains.', 87.50, 'REBALANCE', 1, 0),
(1, 'Tesla position is underperforming (-13.75%). AI suggests reviewing fundamentals or considering exit if losses exceed 20%.', 75.00, 'SELL', 10, 0),
(1, 'Bitcoin shows strong momentum (+30%). Consider adding to position on market dips, but maintain max 10% portfolio allocation.', 80.00, 'BUY', 3, 0),
(2, 'Your portfolio lacks gold/commodity exposure. Adding 5-10% gold (GOLD) could provide inflation hedge and reduce overall volatility.', 82.00, 'DIVERSIFY', 7, 0),
(2, 'Ethereum position down 60%. AI recommends not adding more until clear reversal signal. Consider tax-loss harvesting if eligible.', 90.00, 'HOLD', 4, 0),
(3, 'Your Balanced Growth portfolio is well-diversified across 5 asset types. Maintain current allocation and review quarterly.', 78.00, 'HOLD', NULL, 0),
(3, 'AAPL position performing strongly. Consider adding to winners on any pullback for compounding effect.', 85.00, 'BUY', 1, 0),
(4, 'Tech sector heavily overweighted (60%+). AI recommends rebalancing toward bonds, REITs, or international stocks for safety.', 92.00, 'REBALANCE', NULL, 0),
(5, 'Beginner portfolio shows learning losses. AI recommends dollar-cost averaging into index funds (SPY) instead of timing market.', 88.00, 'BUY', 6, 0),
(6, 'Strong diversification across 6 asset types. Portfolio health excellent. Continue current strategy with monthly contributions.', 95.00, 'HOLD', NULL, 0);

-- ============================================================
-- STEP 7: Sample Notifications
-- ============================================================

INSERT INTO notifications (user_id, title, message, type, is_read) VALUES
(1, 'Welcome to InvestMS', 'Your account is set up successfully! Start by creating your first portfolio.', 'INFO', 1),
(1, 'AAPL Dividend Received', 'You received $450 dividend from your Apple holdings.', 'SUCCESS', 0),
(1, 'AI Recommendation Available', 'New AI recommendation for portfolio rebalancing is available.', 'INFO', 0),
(1, 'Tesla Price Alert', 'Tesla (TSLA) dropped 5% today. Review your position.', 'WARNING', 0),
(2, 'Monthly Contribution Received', 'Your scheduled $15,000 monthly deposit was successful.', 'SUCCESS', 1),
(2, 'High Risk Alert', 'Your Ethereum position is down 60%. Consider reviewing.', 'DANGER', 0),
(3, 'Portfolio Milestone', 'Your portfolio reached $32,000. Great progress!', 'SUCCESS', 0),
(4, 'Concentration Warning', 'Tech sector exceeds 60% of your portfolio. Consider diversification.', 'WARNING', 0),
(5, 'Beginner Tip', 'Try dollar-cost averaging to reduce market timing risk.', 'INFO', 0),
(6, 'AI Report Ready', 'Your monthly AI performance report is ready to view.', 'INFO', 0);

-- ============================================================
-- STEP 8: Sample Chat History (AI Chatbot)
-- ============================================================

INSERT INTO chat_history (user_id, role, message, created_at) VALUES
(1, 'USER', 'What is diversification?',                                                          DATE_SUB(NOW(), INTERVAL 7 DAY)),
(1, 'AI',   'Diversification is the practice of spreading investments across different assets, sectors, and geographies. The core idea: dont put all your eggs in one basket.', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(1, 'USER', 'How is my portfolio doing?',                                                        DATE_SUB(NOW(), INTERVAL 3 DAY)),
(1, 'AI',   'Your portfolio is performing well with a +14% overall return. You have good diversification across 6 asset types.',                                                  DATE_SUB(NOW(), INTERVAL 3 DAY)),
(1, 'USER', 'Tell me about crypto risk',                                                         DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 'AI',   'Cryptocurrency is highly volatile with risk rating 8-10/10. Never invest more than 5-10% of total portfolio. Use dollar-cost averaging to reduce timing risk.',     DATE_SUB(NOW(), INTERVAL 1 DAY));


-- ============================================================
-- STEP 9: Verification - Show what was inserted
-- ============================================================

SELECT '=== SAMPLE DATA INSERTED SUCCESSFULLY ===' AS Status;

SELECT 'Users' AS Table_Name, COUNT(*) AS Records FROM users
UNION ALL SELECT 'Portfolios',     COUNT(*) FROM portfolios
UNION ALL SELECT 'Investments',    COUNT(*) FROM investments
UNION ALL SELECT 'Transactions',   COUNT(*) FROM transactions
UNION ALL SELECT 'Recommendations',COUNT(*) FROM ai_recommendations
UNION ALL SELECT 'Notifications',  COUNT(*) FROM notifications
UNION ALL SELECT 'Chat History',   COUNT(*) FROM chat_history
UNION ALL SELECT 'User Wallets',   COUNT(*) FROM user_wallet;

-- ============================================================
-- LOGIN CREDENTIALS (All passwords = "Admin@123")
-- ============================================================
-- 1. admin@investms.com    / Admin@123  (ADMIN)
-- 2. john@test.com         / Admin@123  (INVESTOR - active, profitable)
-- 3. sarah@test.com        / Admin@123  (INVESTOR - balanced portfolio)
-- 4. michael@test.com      / Admin@123  (INVESTOR - aggressive tech)
-- 5. emma@test.com         / Admin@123  (INVESTOR - beginner with losses)
-- 6. david@test.com        / Admin@123  (INVESTOR - diversified)
-- ============================================================

-- END OF SAMPLE DATA SCRIPT

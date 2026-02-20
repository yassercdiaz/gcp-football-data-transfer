-- Transfer balance analysis with cleaned numeric values
-- Identifies net buyers vs net sellers with financial impact

WITH cleaned_transfers AS (
  SELECT 
    name,
    stadium_name,
    squad_size,
    average_age,
    
    -- Clean and convert transfer balance to numeric
    CASE
      WHEN REGEXP_CONTAINS(net_transfer_record, r'm$') THEN
        SAFE_CAST(REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'm$', '') AS FLOAT64) * 1000000
      WHEN REGEXP_CONTAINS(net_transfer_record, r'k$') THEN
        SAFE_CAST(REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'k$', '') AS FLOAT64) * 1000
      WHEN net_transfer_record = '+-0' THEN 0
      ELSE NULL
    END as net_balance,
    
    net_transfer_record as original_value
    
  FROM `gcp-football-data-transfer.football_transfer_raw.clubs`
  WHERE net_transfer_record IS NOT NULL
    AND net_transfer_record != '+-0'
)

SELECT 
  name,
  stadium_name,
  squad_size,
  average_age,
  original_value,
  ROUND(net_balance, 0) as net_balance_euros,
  
  -- Transfer strategy classification
  CASE
    WHEN net_balance > 50000000 THEN 'Major Seller (>€50M)'
    WHEN net_balance > 10000000 THEN 'Net Seller (€10M-€50M)'
    WHEN net_balance > 0 THEN 'Minor Seller'
    WHEN net_balance = 0 THEN 'Balanced'
    WHEN net_balance > -10000000 THEN 'Minor Buyer'
    WHEN net_balance > -50000000 THEN 'Net Buyer (€10M-€50M)'
    ELSE 'Major Buyer (<-€50M)'
  END as transfer_strategy,
  
  -- Balance per squad member
  CASE 
    WHEN squad_size > 0 THEN ROUND(net_balance / squad_size, 0)
    ELSE NULL
  END as balance_per_player

FROM cleaned_transfers
WHERE net_balance IS NOT NULL
ORDER BY net_balance DESC
LIMIT 30;
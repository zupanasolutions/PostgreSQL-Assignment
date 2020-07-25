--QUESTION ONE(1): How many users does Wave have?

--ANSWER ONE(1)
SELECT COUNT(*)
FROM users;

--QUESTION TWO(2): How many transfers have been sent in the currency CFA?

--ANSWER TWO(2)
SELECT COUNT(*)
FROM transfers
WHERE send_amount_currency = 'CFA';


--QUESTION THREE(3): How many different users have sent a transfer in CFA?
 
--ANSWER THREE(3)
SELECT COUNT(DISTINCT u_id)
FROM transfers
WHERE send_amount_currency = 'CFA';


--Question Four(4): How many agent_transactions did we have in the month of 2018

--ANSWER FOUR(4)
SELECT COUNT(atx_id) 
FROM agent_transactions
WHERE EXTRACT(YEAR FROM when_created)=2018
GROUP BY EXTRACT(MONTH FROM when_created);


--QUESTION Five(5): Over the course of the last week, how many Wave agents were “net depositors” vs. “net
--withdrawers”?

--ANSWER FIVE(5)

SELECT SUM(CASE WHEN amount>0 THEN amount
		  ELSE 0 END) AS withdrawal, 
		  SUM(CASE WHEN amount<0 THEN amount ELSE 0 END) AS deposit, 
		  CASE WHEN ((SUM(CASE WHEN amount>0 THEN amount ELSE 0 END))>
					 ((SUM(CASE WHEN amount<0 THEN amount ELSE 0 END)))*-1)
					 THEN 'withdrawer' ELSE 'depositor' END as agent_status,
					 COUNT(*) FROM agent_transactions WHERE when_created
					 BETWEEN (now() - '1 WEEK'::INTERVAL) AND now();


--QUESTION SIX(6): Build an “atx volume city summary” table: find the volume of agent transactions created
--in the last week, grouped by city

--ANSWER SIX(6)
SELECT city, volume INTO atx_volume_city_summary
FROM (SELECT agents.city AS city, 
	  COUNT(agent_transactions.atx_id) AS volume 
	 FROM agents INNER JOIN agent_transactions ON
	 agents.agent_id = agent_transactions.agent_id
	 WHERE (agent_transactions.when_created >
			(NOW()-INTERVAL'1 week'))
	 GROUP BY agents.city) AS atx_volume_summary;


--QUESTION SEVEN(7): Now separate the atx volume by country as well (so your columns should be country,
--city, volume)

--ANSWER SEVEN(7)
SELECT city, volume, country INTO atx_volume_city_summary_with_country
FROM(SELECT agents.city AS city, agents.country AS country, COUNT(agent_transactions.atx_id) AS volume 
FROM agents INNER JOIN agent_transactions ON agents.agent_id = agent_transactions.agent_id
WHERE (agent_transactions.when_created > (NOW() - INTERVAL '1 week'))
GROUP BY agents.country, agents.city) AS atx_volume_summary_with_country;



--QUESTION EIGHT(8): Build a “send volume by country and kind” table: find the total volume of transfers (by
--send_amount_scalar) sent in the past week, grouped by country and transfer kind

--ANSWER EIGHT(8)
SELECT transfers.kind AS kind, wallets.ledger_location 
AS country, SUM(transfers.send_amount_scalar) AS volume
FROM transfers 
INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id
GROUP BY wallets.ledger_location, transfers.kind;


--QUESTION NINE(9): Then add columns for transaction count and number of unique senders (still broken
--down by country and transfer kind).

--ANSWER NINE(9)
SELECT COUNT(transfers.source_wallet_id) AS unique_senders, COUNT(transfer_id)
AS transaction_count, transfers.kind AS transfer_kind, wallets.ledger_location AS country,
SUM(transfers.send_amount_scalar) AS volume 
FROM transfers 
INNER JOIN wallets 
ON transfers.source_wallet_id = wallets.wallet_id
WHERE (transfers.when_created > (NOW() -INTERVAL '1 week'))
GROUP BY wallets.ledger_location, transfers.kind;


--QUESTION TEN(10):Finally, which wallets have sent more than 10,000,000 CFA in transfers in the last month
--(as identified by the source_wallet_id column on the transfers table), and how much did
--they send?

--ANSWER TEN(10)
SELECT source_wallet_id, send_amount_scalar 
FROM transfers WEHRE send_amount_currency = 'CFA'
AND (send_amount_scalar > 10000000) AND (transfers.when_created > (NOW() - INTERVAL '1 month'));













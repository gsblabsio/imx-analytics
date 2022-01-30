/***
Author: GSB Labs....but the smarter of the 2 :D
Date written: 2022-01-30

Objective: select all Immutable X price from raw dex.trades table and retrieve only the most recent price/volume

Forked and edit from https://github.com/gsblabsio/imx-analytics/blob/main/sql/volume_price_by_day.sql
***/


--
with dex_trades AS (
    select
        usd_amount,
        token_a_amount_raw as token_amount_raw,
        block_time
    from dex.trades
    where "token_a_address" = '\xf57e7e7c23978c3caec3c3548e3d615c346e79ff'
        AND usd_amount  > 0
        AND category = 'DEX'
    union
    select
        usd_amount,
        token_b_amount_raw as token_amount_raw,
        block_time
    from dex.trades
    where "token_b_address" = '\xf57e7e7c23978c3caec3c3548e3d615c346e79ff'
        AND token_b_amount > 0
        AND category = 'DEX'
)
select
    dt.block_time,
    sum(usd_amount) as volume_usd,
    (sum(usd_amount)/sum(token_amount_raw))* 1e18 as price_usd

from dex_trades dt
group by block_time
order by block_time desc
limit 1;

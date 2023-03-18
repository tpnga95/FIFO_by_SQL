{\rtf1\ansi\ansicpg1252\cocoartf2639
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fmodern\fcharset0 Courier;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;}
{\*\expandedcolortbl;;\cssrgb\c0\c0\c0;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs26 \cf0 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 CREATE TABLE TRAN2 (\
  executeddate date, order_name varchar(8), action varchar(5), quantity int);\
\
insert into TRAN2\
values \
('01/01/2023', 'Buy 1', 'Buy', 3), ('02/01/2023', 'Buy 2', 'Buy', 7),\
('03/01/2023', 'Sell 1', 'Sell', 4), ('04/01/2023', 'Sell 2', 'Sell', 3),\
('05/01/2023', 'Buy 3', 'Buy', 4), ('06/01/2023', 'Buy 4', 'Buy', 4),\
('07/01/2023', 'Sell 3', 'Sell', 8), ('08/01/2023', 'Sell 4', 'Sell', 3);\
\
with \
buy_transaction as \
(\
select executeddate as buy_date, order_name as buy_order, quantity as buy\
      , sum(quantity) over(partition by action order by executeddate) as accum_buy\
from TRAN2\
where action = 'Buy'\
)\
,\
sell_transaction as \
(\
select executeddate as sell_date, order_name as sell_order, quantity as sell\
      , sum(quantity) over(partition by action order by executeddate) as accum_sell\
from TRAN2\
where action = 'Sell'\
)\
\
select b.buy_date, b.buy_order, s.sell_date, s.sell_order,\
      case when b.accum_buy - b.buy <= s.accum_sell - s.sell then -- case1\
          case when s.sell <  b.accum_buy - (s.accum_sell - s.sell) then s.sell\
          else b.accum_buy - (s.accum_sell - s.sell)\
          end\
      else      \
          case when b.accum_buy < s.accum_sell then b.buy -- case2.1\
          else     s.accum_sell - (b.accum_buy - b.buy) -- case 2.2 \
          end\
      end as quantity \
from sell_transaction s \
left join buy_transaction b \
on (b.accum_buy > s.accum_sell - s.sell) and (s.accum_sell > b.accum_buy - b.buy)\
}
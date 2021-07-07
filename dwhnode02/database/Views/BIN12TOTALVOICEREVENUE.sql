--
-- BIN12TOTALVOICEREVENUE  (View) 
--
CREATE OR REPLACE FORCE VIEW DWH_USER.BIN12TOTALVOICEREVENUE
(P, VOICE_REVENUE)
BEQUEATH DEFINER
AS 
select "P","VOICE_REVENUE" from 
   (select P, VOICE_REVENUE
   from BIN12JOINMOREVENUEMTREVENUE
   
   union 
   
   select Q, VOICE_REVENUE
   from BIN12JOINMOREVENUEMTREVENUE
   )
   where P is not null;



--
-- BIN6UNIONJOINSMSRECURRING  (View) 
--
CREATE OR REPLACE FORCE VIEW DWH_USER.BIN6UNIONJOINSMSRECURRING
(S22_PRI_IDENTITY, S395_MAINOFFERINGID, SMSRECURRING_REV)
BEQUEATH DEFINER
AS 
select "S22_PRI_IDENTITY","S395_MAINOFFERINGID","SMSRECURRING_REV" from
 (select S22_PRI_IDENTITY, S395_MAINOFFERINGID, SMSRECURRING_REV
 from BIN6JOINSMSRECURRING
 union
  select R375_CHARGINGPARTYNUMBER, R373_MAINOFFERINGID, SMSRECURRING_REV
 from BIN6JOINSMSRECURRING)
 where S22_PRI_IDENTITY is not null and S395_MAINOFFERINGID is not null;



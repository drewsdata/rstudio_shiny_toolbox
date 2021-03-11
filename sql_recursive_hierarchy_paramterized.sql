WITH RECURSIVE subordinates AS (
  SELECT ad_data_itops_shiny.employeeid,
  ad_data_itops_shiny.samaccountname,
  ad_data_itops_shiny.userprincipalname,
  ad_data_itops_shiny.mail,
  ad_data_itops_shiny.displayname,
  ad_data_itops_shiny.mgr_employeeid,
  ad_data_itops_shiny.dn,
  ad_data_itops_shiny.account_status,
  ad_data_itops_shiny.mgr_mail,
  ad_data_itops_shiny.mgr_samaccountname,
  ad_data_itops_shiny.mgr_userprincipalname
  FROM ad_data_itops_shiny
  WHERE ad_data_itops_shiny.employeeid = {dt_row_empid}
  union distinct 
  SELECT e.employeeid,
  e.samaccountname,
  e.userprincipalname,
  e.mail,
  e.displayname,
  e.mgr_employeeid,
  e.dn,
  e.account_status,
  e.mgr_mail,
  e.mgr_samaccountname,
  e.mgr_userprincipalname
  FROM ad_data_itops_shiny e
  INNER JOIN subordinates s ON e.mgr_employeeid = s.employeeid 
  WHERE e.account_status not like '514'
  and e.samaccountname not like '%dpd'
  and e.mgr_employeeid <> ALL (ARRAY[
    -- employee ID's should be unique values / keys. if not,
    -- here is where those that are not unique can be removed
    -- include any strings matches to filter out non-unique unique empID strings
    -- won't work otherwise
    'dupe',
    'generic_id'
]              
  ))
SELECT subordinates.employeeid,
subordinates.samaccountname,
subordinates.userprincipalname,
subordinates.mail,
subordinates.displayname,
subordinates.dn,
subordinates.account_status,
subordinates.mgr_employeeid,
subordinates.mgr_mail,
subordinates.mgr_samaccountname,
subordinates.mgr_userprincipalname
FROM subordinates

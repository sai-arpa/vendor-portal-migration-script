
 
DELETE FROM masterdata.role_form_rights
WHERE id IN
(
    SELECT rfr.id
    FROM masterdata.role_form_rights AS rfr
    INNER JOIN globaldata.form_master AS fm
        ON fm.id = rfr.form_id
    WHERE fm.parent_form_id = 67
);
 
 
DELETE FROM globaldata.form_master
WHERE parent_form_id = 67;
 
 
DELETE FROM globaldata.form_master
WHERE id = 67;
 ;


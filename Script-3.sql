select count(*) from purchase.pur_rfq_vendor_detail prvd where prvd.quotation_status_id =8

select * from masterdata.approval_setup_master asm where is_audit is true
select * from utility.approval_process_main asm where asm.is_audit is true

select * from masterdata.approval_setup_level_detail asld 
left join masterdata.approval_setup_master asm 
on asm.id = asld.approval_setup_id 
where asm.is_audit is true

select * from purchase.cs_pr_detail cqd where cqd.cs_id = 71683
select * from purchase.cs_company_detail cqd where cqd.cs_id = 71683
select * from purchase.cs_main where id = 71683
select * from purchase.cs_main where doc_no_yearly = '067481'
select count(*) from purchase.cs_quotation_detail
select count(*) from utility.approval_process_detail
select count(*) from sqlserver_fdw.csmain

truncate table utility.approval_process_main cascade


select apm.doc_id , apd.level_no , apd.status_id   from utility.approval_process_detail apd
left join utility.approval_process_main apm 
on apm.id=apd.approval_process_id 
where apm.form_id = 6 and apm.doc_id = 77046
order by apm.doc_id asc, apd.level_no asc

update utility.approval_process_detail apd 
set apd.status_id = 21
where apd.status_id = 7

select apm.form_id , apm.doc_id , apd.level_no, apd.approval_rule_id , apd.status_id, apm.action_by_id, apd.user_id  from utility.approval_process_detail apd
left join utility.approval_process_main apm
on apm.id=apd.approval_process_id
where apm.status_id = 13


select apm.form_id , apm.doc_id , apd.level_no from utility.approval_process_detail apd
left join utility.approval_process_main apm
on apm.id=apd.approval_process_id
group by apm.form_id , apm.doc_id , apd.level_no
having apm.status_id = 12




select um.username, count(*) from "security".user_master um group by um.username having count(*)>1


select * from "security".user_master um where um.username in ('80300','80110','VL00001','VL00020') order by um.created_date 

select um.loginno, um.loginid from sqlserver_fdw.login um where um.loginid in ('80300','80110','VL00001','VL00020')




select distinct apm.status_id, s.status_name   from utility.approval_process_main apm 
left join globaldata.status s
s.id = apm.status_id

select * from utility.approval_process_detail apd
left join utility.approval_process_main apm 
on apm.id=apd.approval_process_id 
where apm.form_id = 6 and apm.doc_id = 77046

select apm.form_id ,apm.doc_id , apd.level_no, apd.status_id, count(*) from utility.approval_process_detail apd
left join utility.approval_process_main apm 
on apm.id=apd.approval_process_id 
group by apm.form_id ,apm.doc_id , apd.level_no, apd.status_id 


select SUM(pom.net_amount ) from purchase.purchase_order_main pom ;
select SUM(pom.netamount ) from sqlserver_fdw.poamendmentmain pom ;

select SUM(pom.qty  ) from purchase.purchase_order_item_detail pom ;
select SUM(pom.quantity  ) from sqlserver_fdw.poamendmentitemdetail pom ;

select SUM(pom.rate) from purchase.purchase_order_item_detail pom ;
select SUM(pom.rate  ) from sqlserver_fdw.poamendmentitemdetail pom ;

select distinct document_status_id from purchase.quotation_main qm 

select distinct a.form_id from masterdata.approval_setup_master a where a.is_audit is true 

select distinct a.statusNo, sm.new_status_name, sm.old_status_name, sm.new_status_id    from sqlserver_fdw.auditdocumentmain a
left join migration.status_mapping sm 
on sm.old_status_id=a.statusNo

select apd.*
FROM utility.approval_process_detail apd
INNER JOIN utility.approval_process_main apm
    ON apm.id = apd.approval_process_id
WHERE apd.status_id = 12
and (
    apm.form_id,
    apm.doc_id,
    apd.level_no
) in (
    SELECT
        apm2.form_id,
        apm2.doc_id,
        apd2.level_no
    FROM utility.approval_process_detail apd2
    INNER JOIN utility.approval_process_main apm2
        ON apm2.id = apd2.approval_process_id
    WHERE apd2.status_id = 12
    GROUP BY
        apm2.form_id,
        apm2.doc_id,
        apd2.level_no
    HAVING COUNT(*) > 1
);








SELECT
    apm.form_id,
    apm.doc_id,
    apd.level_no
FROM utility.approval_process_detail apd
JOIN utility.approval_process_main apm
    ON apm.id = apd.approval_process_id
GROUP BY
    apm.form_id,
    apm.doc_id,
    apd.level_no
HAVING
    COUNT(DISTINCT apd.status_id) = 1
    AND MIN(apd.status_id) = 7;

                   
UPDATE utility.approval_process_main apm
SET status_id = CASE
    WHEN pr.document_status_id = 30 THEN 9
    WHEN pr.document_status_id = 10 AND EXISTS (
             SELECT 1
             FROM sqlserver_fdw.indentauthorizationdetail iad2
             WHERE iad2.IndentNo = pr.id
               AND iad2.StatusNo = 1
         ) THEN 14
    WHEN pr.document_status_id = 10 THEN 7
END
FROM purchase.purchase_order_main pr
WHERE apm.doc_id = pr.id 
  AND apm.form_id = 10; 


----

UPDATE utility.approval_process_detail apd
SET status_id = CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM utility.approval_process_detail x
                        WHERE x.approval_process_id = apd.approval_process_id
                          AND x.level_no = apd.level_no
                          AND x.status_id = 12
                    ) THEN 21

                    WHEN EXISTS (
                        SELECT 1
                        FROM utility.approval_process_detail x
                        WHERE x.approval_process_id = apd.approval_process_id
                          AND x.level_no = apd.level_no
                          AND x.status_id = 13
                    ) THEN 29
                END
WHERE apd.status_id NOT IN (12, 13)
  AND EXISTS (
        SELECT 1
        FROM utility.approval_process_detail x
        WHERE x.approval_process_id = apd.approval_process_id
          AND x.level_no = apd.level_no
        GROUP BY x.approval_process_id, x.level_no
        HAVING COUNT(*) > 1
  )
  AND (
        EXISTS (
            SELECT 1
            FROM utility.approval_process_detail x
            WHERE x.approval_process_id = apd.approval_process_id
              AND x.level_no = apd.level_no
              AND x.status_id = 12
        )
        OR
        EXISTS (
            SELECT 1
            FROM utility.approval_process_detail x
            WHERE x.approval_process_id = apd.approval_process_id
              AND x.level_no = apd.level_no
              AND x.status_id = 13
        )
      );
                    
                 
                    
                    -----

insert into "security".user_master 
(
	user_type_id,
    username,
    password_hash,
    display_name,
    contact_no,
    contact_no_country_id,
    time_zones_id,
    email,
    erp_user_id,
    division_type_id,
    department_type_id,
    is_blocked,
    blocked_date,
    last_password_changed_date,
    last_login_date,
    failed_login_attempt_counter,
    created_by_id,
    created_date,
    modified_by_id,
    modified_date,
    status_id,
    status_remarks,
    supplier_account_id,
    is_guest_login
)
values(1, 'admin', 'QXHuBJatk7R6xD2EfNN9Tg%3D%3D', 'Admin', null, null, null, 'admin@eprocurement.com', null, null, null, false, null, null, null, 0, 1, '2026-06-08 12:30:00.000', 1, '2026-06-08 12:30:00.000', 1, null, null, false);


DELETE FROM utility.approval_process_main
WHERE status_id = 13
  AND is_audit = false
  AND revision_no >= 0;




SELECT
    form_id,
    COUNT(*)
FROM utility.approval_process_main
WHERE status_id = 13
  AND is_audit = false
GROUP BY form_id
ORDER BY form_id;


select count(*) from (
SELECT
    rr.poamendmentno,
    rr.revision_no,
    aprm.new_approval_process_id,
    apm.status_id,
    apm.is_current
FROM migration.po_rejection_revision_mapping aprm
INNER JOIN utility.approval_process_main apm
    ON apm.id = aprm.new_approval_process_id
INNER JOIN
(
    SELECT
        prh.poarejectionhistoryno,
        prh.poamendmentno,
        ROW_NUMBER() OVER
        (
            PARTITION BY prh.poamendmentno
            ORDER BY migration.parse_sqlserver_datetime(prh.rejectiondate)
        ) - 1 AS revision_no
    FROM sqlserver_fdw.poamendmentrejectionhistory prh
) rr
    ON rr.poarejectionhistoryno = aprm.po_rejection_history_no
ORDER BY rr.poamendmentno, rr.revision_no);

DELETE FROM utility.approval_process_main
WHERE form_id = 10
  AND is_audit = false
  AND status_id = 13;

UPDATE utility.approval_process_main
SET revision_no = 0
WHERE form_id = 10
  AND is_audit = false;

DELETE FROM migration.po_rejection_revision_mapping;
DROP TABLE migration.po_rejection_revision_mapping;


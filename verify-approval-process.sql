--- Approval Process
	
--- Active level must contain only status 3
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE apd.status_id = 3) AS pending_count,
    COUNT(*) FILTER (
        WHERE apd.status_id <> 3 OR apd.status_id IS NULL
    ) AS invalid_count
FROM utility.approval_process_detail apd
INNER JOIN utility.approval_process_main apm
    ON apm.id = apd.approval_process_id
WHERE apm.is_current = true
  AND apd.level_no = COALESCE(apm.current_approved_level_no, 0) + 1
  and apm.status_id=14
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (
    WHERE apd.status_id <> 3 OR apd.status_id IS NULL
) > 0
ORDER BY
    apd.approval_process_id;


---Every level before active level must have 12 or 13
--- one issue (19899)
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE apd.status_id IN (12, 13)
    ) AS completed_count
FROM utility.approval_process_detail apd
INNER JOIN utility.approval_process_main apm
    ON apm.id = apd.approval_process_id
WHERE apm.is_current = true
  AND apd.level_no < COALESCE(apm.current_approved_level_no, 0) + 1
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (
    WHERE apd.status_id IN (12, 13)
) = 0
ORDER BY
    apd.approval_process_id,
    apd.level_no;


---Every level after active level must be status 20
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE apd.status_id = 20) AS status_20_count,
    COUNT(*) FILTER (
        WHERE apd.status_id <> 20 OR apd.status_id IS NULL
    ) AS invalid_count
FROM utility.approval_process_detail apd
INNER JOIN utility.approval_process_main apm
    ON apm.id = apd.approval_process_id
WHERE apm.is_current = true
  AND apd.level_no > COALESCE(apm.current_approved_level_no, 0) + 1
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (
    WHERE apd.status_id <> 20 OR apd.status_id IS NULL
) > 0
ORDER BY
    apd.approval_process_id,
    apd.level_no;



---- Current approval level must be highest level which has 12
WITH calculated AS
(
    SELECT
        approval_process_id,
        MAX(
            CASE
                WHEN status_id IN (12, 13)
                THEN level_no
            END
        ) AS calculated_current_approved_level_no
    FROM utility.approval_process_detail
    GROUP BY approval_process_id
)
SELECT
    apm.id AS approval_process_id,
    apm.current_approved_level_no,
    c.calculated_current_approved_level_no
FROM utility.approval_process_main apm
INNER JOIN calculated c
    ON c.approval_process_id = apm.id
WHERE apm.is_current = true
  AND apm.current_approved_level_no IS DISTINCT FROM
      c.calculated_current_approved_level_no
ORDER BY apm.id;


---Completed approved levels: remaining users must be 21
SELECT
    apd.approval_process_id,
    apm.form_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE apd.status_id = 12) AS approved_count,
    COUNT(*) FILTER (WHERE apd.status_id = 21) AS peer_approved_count,
    COUNT(*) FILTER (
        WHERE apd.status_id NOT IN (12, 21)
           OR apd.status_id IS NULL
    ) AS invalid_count
FROM utility.approval_process_detail apd
left join utility.approval_process_main apm
on apm.id = apd.approval_process_id
GROUP BY
    apd.approval_process_id,
    apm.form_id,
    apd.level_no
HAVING COUNT(*) FILTER (WHERE apd.status_id = 12) > 0
   AND COUNT(*) FILTER (
       WHERE apd.status_id NOT IN (12, 21)
          OR apd.status_id IS NULL
   ) > 0
ORDER BY
    apd.approval_process_id,
    apd.level_no;


---Completed rejected levels: remaining users must be 29
SELECT
    apd.approval_process_id,
    apd.level_no,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE apd.status_id = 13) AS rejected_count,
    COUNT(*) FILTER (WHERE apd.status_id = 29) AS peer_rejected_count,
    COUNT(*) FILTER (
        WHERE apd.status_id NOT IN (13, 29)
           OR apd.status_id IS NULL
    ) AS invalid_count
FROM utility.approval_process_detail apd
GROUP BY
    apd.approval_process_id,
    apd.level_no
HAVING COUNT(*) FILTER (WHERE apd.status_id = 13) > 0
   AND COUNT(*) FILTER (
       WHERE apd.status_id NOT IN (13, 29)
          OR apd.status_id IS NULL
   ) > 0
ORDER BY
    apd.approval_process_id,
    apd.level_no;


---Check that 12 and 13 don't coexist at the same level
SELECT
    approval_process_id,
    level_no,
    COUNT(*) FILTER (WHERE status_id = 12) AS approved_count,
    COUNT(*) FILTER (WHERE status_id = 13) AS rejected_count
FROM utility.approval_process_detail
GROUP BY
    approval_process_id,
    level_no
HAVING COUNT(*) FILTER (WHERE status_id = 12) > 0
   AND COUNT(*) FILTER (WHERE status_id = 13) > 0
ORDER BY
    approval_process_id,
    level_no;



---Also check level sequence
WITH levels AS
(
    SELECT DISTINCT
        approval_process_id,
        level_no
    FROM utility.approval_process_detail
),
numbered AS
(
    SELECT
        approval_process_id,
        level_no,
        ROW_NUMBER() OVER (
            PARTITION BY approval_process_id
            ORDER BY level_no
        ) AS expected_level_no
    FROM levels
)
SELECT
    approval_process_id,
    level_no,
    expected_level_no
FROM numbered
WHERE level_no <> expected_level_no
ORDER BY
    approval_process_id,
    level_no;


------Check Statuses
--PR
select * from utility.approval_process_main apm
left join inventory.purchase_request_main prm
on prm.id = apm.doc_id and apm.form_id=6
where prm.document_status_id = 10 and apm.status_id<> 7

select * from utility.approval_process_main apm
left join inventory.purchase_request_main prm
on prm.id = apm.doc_id and apm.form_id=6
where prm.document_status_id = 20 and apm.status_id<> 14

select * from utility.approval_process_main apm
left join inventory.purchase_request_main prm
on prm.id = apm.doc_id and apm.form_id=6
where prm.document_status_id = 30 and apm.status_id<> 9

--PO
select * from utility.approval_process_main apm
left join purchase.purchase_order_main prm
on prm.id = apm.doc_id and apm.form_id=10
where prm.document_status_id = 10 and apm.status_id<> 7

select * from utility.approval_process_main apm
left join purchase.purchase_order_main prm
on prm.id = apm.doc_id and apm.form_id=10
where prm.document_status_id = 20 and apm.status_id<> 14

select * from utility.approval_process_main apm
left join purchase.purchase_order_main prm
on prm.id = apm.doc_id and apm.form_id=10
where prm.document_status_id = 30 and apm.status_id<> 9

--CS
select * from utility.approval_process_main apm
left join purchase.cs_main prm
on prm.id = apm.doc_id and apm.form_id=8
where prm.document_status_id = 10 and apm.status_id<> 7

select count(*) from utility.approval_process_main apm
left join purchase.cs_main prm
on prm.id = apm.doc_id and apm.form_id=8
where prm.document_status_id = 20 and apm.status_id<> 14

select prm.id, prm.document_status_id, apm.status_id from utility.approval_process_main apm
left join purchase.cs_main prm
on prm.id = apm.doc_id and apm.form_id=8
where prm.document_status_id = 30 and apm.status_id<> 9

--------
---approval setup present but no rows in authorizationDetail

select count(1) from purchase.cs_main cm 
where cm.approval_setup_id is not null and
not exists (
select 1 from utility.approval_process_main apm 
where apm.form_id =8 and apm.doc_id =cm.id
)

select cm.id,cm.doc_date  from purchase.purchase_order_main cm 
where cm.approval_setup_id is not null and
not exists (
select 1 from utility.approval_process_main apm 
where apm.form_id =10 and apm.doc_id =cm.id
)

select count(1) from inventory.purchase_request_main cm 
where cm.approval_setup_id is not null and
not exists (
select 1 from utility.approval_process_main apm 
where apm.form_id=6 and apm.doc_id =cm.id
)

-------
---Present in authorizationDetail but approval setup is null
select * from utility.approval_process_main apm 
inner join inventory.purchase_request_main prm 
on apm.form_id =6 and apm.doc_id =prm.id
where prm.approval_setup_id is null

select * from utility.approval_process_main apm 
inner join purchase.purchase_order_main pom 
on apm.form_id =10 and apm.doc_id =pom.id
where pom.approval_setup_id is null

select * from utility.approval_process_main apm 
inner join purchase.cs_main csm
on apm.form_id =8 and apm.doc_id =csm.id
where csm.approval_setup_id is null

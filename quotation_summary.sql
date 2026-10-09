INSERT INTO purchase.quotation_summary
(
    main_quotation_id,
    current_revision_no,
    authorized_revision_no
)
SELECT
    qm.main_quotation_id,
    MAX(qm.revision_no) AS current_revision_no,
    MAX(
        CASE
            WHEN qm.document_status_id = 30
                THEN qm.revision_no
        END
    ) AS authorized_revision_no
FROM purchase.quotation_main qm
GROUP BY
    qm.main_quotation_id;


-- verification

SELECT COUNT(DISTINCT main_quotation_id)
FROM purchase.quotation_main;

SELECT COUNT(*)
FROM purchase.quotation_summary;
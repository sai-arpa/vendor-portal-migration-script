CREATE FOREIGN TABLE sqlserver_fdw.podeptvalue
(
    podeptvalueno INTEGER,
    pono INTEGER,
    deptno INTEGER,
    amount NUMERIC(19,4)
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'Purchase',
    table_name 'PODeptValue'
);


WITH latest_po_amendment AS
(
    SELECT
        pam.pono,
        MAX(pam.poamendmentno) AS poamendmentno
    FROM sqlserver_fdw.poamendmentmain pam
    GROUP BY pam.pono
)
INSERT INTO purchase.po_department_wise
(
    po_id,
    department_id,
    net_amount
)
SELECT
    pom.id AS po_id,
    pdv.deptno AS department_id,
    ROUND(
        COALESCE(pdv.amount,0)::numeric,
        2
    ) AS net_amount
FROM sqlserver_fdw.podeptvalue pdv
INNER JOIN latest_po_amendment lpa
    ON lpa.pono = pdv.pono
INNER JOIN purchase.purchase_order_main pom
    ON pom.id = lpa.poamendmentno;












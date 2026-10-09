select * from utility.system_logs sl where sl.trace_id ='d39ba97d-db12-48c6-8346-6d35eebbc6a1'


select * from purchase.cs_pr_detail where quotation_id =50598



SELECT
    tc.constraint_name,
    tc.table_schema AS referencing_schema,
    tc.table_name AS referencing_table,
    kcu.column_name AS referencing_column,
    ccu.table_schema AS referenced_schema,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.table_schema = ccu.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_schema = 'purchase'
  AND ccu.table_name = 'cs_pr_detail'
  AND ccu.column_name = 'id';
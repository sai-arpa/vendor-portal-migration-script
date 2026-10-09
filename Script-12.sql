SELECT 
    t.relname AS "table_name",
    a.attnum AS "column_id",
    a.attname AS "column_name",
    format_type(a.atttypid, a.atttypmod) AS "data_type",
    CASE 
        WHEN a.atttypmod - 4 > 0 AND format_type(a.atttypid, NULL) IN ('character', 'character varying', 'numeric') 
        THEN (a.atttypmod - 4)
        ELSE NULL 
    END AS "max_length",
    CASE 
        WHEN format_type(a.atttypid, NULL) = 'numeric' THEN ((a.atttypmod - 4) >> 16) & 65535 
        ELSE NULL 
    END AS "precision",
    CASE 
        WHEN format_type(a.atttypid, NULL) = 'numeric' THEN (a.atttypmod - 4) & 65535 
        ELSE NULL 
    END AS "scale",
    CASE WHEN a.attnotnull THEN 'NO' ELSE 'YES' END AS "is_nullable",
    pg_get_expr(d.adbin, d.adrelid) AS "default_value",
    CASE WHEN pk.attnum IS NOT NULL THEN 'YES' ELSE 'NO' END AS "primary_key",
    fk.referenced_table AS "referenced_table",
    fk.referenced_column AS "referenced_column"
FROM 
    pg_catalog.pg_class t
JOIN 
    pg_catalog.pg_attribute a ON t.oid = a.attrelid
-- 1. Check Primary Key
LEFT JOIN (
    SELECT i.indrelid, UNNEST(i.indkey) AS attnum
    FROM pg_catalog.pg_index i WHERE i.indisprimary
) pk ON t.oid = pk.indrelid AND a.attnum = pk.attnum
-- 2. Check Foreign Keys
LEFT JOIN (
    SELECT 
        con.conrelid AS table_oid,
        con.conkey[pos.idx] AS column_id,
        ref_t.relname AS referenced_table,
        ref_a.attname AS referenced_column
    FROM pg_catalog.pg_constraint con
    JOIN pg_catalog.pg_class ref_t ON con.confrelid = ref_t.oid
    CROSS JOIN LATERAL generate_series(1, array_upper(con.conkey, 1)) AS pos(idx)
    JOIN pg_catalog.pg_attribute ref_a ON ref_t.oid = ref_a.attrelid AND ref_a.attnum = con.confkey[pos.idx]
    WHERE con.contype = 'f'
) fk ON t.oid = fk.table_oid AND a.attnum = fk.column_id
-- 3. Check Default Values
LEFT JOIN 
    pg_catalog.pg_attrdef d ON t.oid = d.adrelid AND a.attnum = d.adnum
WHERE 
    t.relname = 'session_logs' -- <--- CHANGE THIS TO YOUR TABLE NAME
    AND t.relkind = 'r' 
    AND a.attnum > 0 
    AND NOT a.attisdropped
ORDER BY 
    a.attnum;









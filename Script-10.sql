SELECT 
    t.table_name AS "table_name",
    c.ordinal_position AS "column_id",
    c.column_name AS "column_name",
    c.data_type AS "data_type",
    COALESCE(c.character_maximum_length, c.numeric_precision) AS "max_length",
    c.numeric_precision AS "precision",
    c.numeric_scale AS "scale",
    c.is_nullable AS "is_nullable",
    c.column_default AS "default_value",
    CASE WHEN pk.column_name IS NOT NULL THEN 'YES' ELSE 'NO' END AS "primary_key",
    fk.referenced_table AS "referenced_table",
    fk.referenced_column AS "referenced_column"
FROM 
    information_schema.tables t
JOIN 
    information_schema.columns c 
    ON t.table_schema = c.table_schema AND t.table_name = c.table_name
-- 1. Identify Primary Keys
LEFT JOIN (
    SELECT 
        ku.table_schema, ku.table_name, ku.column_name
    FROM 
        information_schema.table_constraints tc
    JOIN 
        information_schema.key_column_usage ku 
        ON tc.constraint_name = ku.constraint_name 
        AND tc.table_schema = ku.table_schema
    WHERE 
        tc.constraint_type = 'PRIMARY KEY'
) pk 
    ON c.table_schema = pk.table_schema 
    AND c.table_name = pk.table_name 
    AND c.column_name = pk.column_name
-- 2. Identify Foreign Keys (Referenced Tables & Columns)
LEFT JOIN (
    SELECT
        kcu.table_schema,
        kcu.table_name,
        kcu.column_name,
        ccu.table_name AS referenced_table,
        ccu.column_name AS referenced_column
    FROM
        information_schema.table_constraints AS tc
    JOIN 
        information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    JOIN 
        information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
    WHERE 
        tc.constraint_type = 'FOREIGN KEY'
) fk 
    ON c.table_schema = fk.table_schema 
    AND c.table_name = fk.table_name 
    AND c.column_name = fk.column_name
WHERE 
    t.table_type = 'BASE TABLE' -- Excludes views
    AND t.table_schema NOT IN ('pg_catalog', 'information_schema') -- Excludes system schemas
ORDER BY 
    t.table_schema, 
    t.table_name, 
    c.ordinal_position;
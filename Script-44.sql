
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    CASE
        WHEN pk.column_id IS NOT NULL THEN 1
        ELSE 0
    END AS IsPk,
    CASE
        WHEN fk.parent_column_id IS NOT NULL THEN 1
        ELSE 0
    END AS IsFk,
    rs.name AS RefSchema,
    rt.name AS RefTable,
    rc.name AS RefColumn
FROM sys.tables t
INNER JOIN sys.schemas s
    ON s.schema_id = t.schema_id
INNER JOIN sys.columns c
    ON c.object_id = t.object_id
INNER JOIN sys.types ty
    ON ty.user_type_id = c.user_type_id
-- Primary Key
LEFT JOIN (
    SELECT
        ic.object_id,
        ic.column_id
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic
        ON ic.object_id = i.object_id
       AND ic.index_id = i.index_id
    WHERE i.is_primary_key = 1
) pk
    ON pk.object_id = t.object_id
   AND pk.column_id = c.column_id
-- Foreign Key
LEFT JOIN sys.foreign_key_columns fk
    ON fk.parent_object_id = t.object_id
   AND fk.parent_column_id = c.column_id
-- Referenced table
LEFT JOIN sys.tables rt
    ON rt.object_id = fk.referenced_object_id
LEFT JOIN sys.schemas rs
    ON rs.schema_id = rt.schema_id
-- Referenced column
LEFT JOIN sys.columns rc
    ON rc.object_id = fk.referenced_object_id
   AND rc.column_id = fk.referenced_column_id
WHERE s.name IN (
    'GlobalData',
    'masterdata',
    'Security',
    'Inventory',
    'Purchase',
    'Sales'
)
ORDER BY
    s.name,
    t.name,
    c.column_id;

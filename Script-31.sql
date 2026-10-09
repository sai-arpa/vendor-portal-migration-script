SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'security.user_master';
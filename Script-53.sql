DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'sqlserver_fdw'
          AND table_type = 'FOREIGN'
        ORDER BY table_name
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'migration'
              AND table_name = r.table_name
        ) THEN
            EXECUTE format(
                'SELECT * INTO migration.%I FROM sqlserver_fdw.%I',
                r.table_name,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;
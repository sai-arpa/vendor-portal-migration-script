DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT
            table_schema,
            table_name,
            column_name,
            pg_get_serial_sequence(
                quote_ident(table_schema) || '.' || quote_ident(table_name),
                column_name
            ) AS seq
        FROM information_schema.columns
        WHERE table_schema = 'config'
    LOOP
        IF r.seq IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(%I) + 1 FROM %I.%I), 1), false)',
                r.seq,
                r.column_name,
                r.table_schema,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT
            table_schema,
            table_name,
            column_name,
            pg_get_serial_sequence(
                quote_ident(table_schema) || '.' || quote_ident(table_name),
                column_name
            ) AS seq
        FROM information_schema.columns
        WHERE table_schema = 'masterdata'
    LOOP
        IF r.seq IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(%I) + 1 FROM %I.%I), 1), false)',
                r.seq,
                r.column_name,
                r.table_schema,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT
            table_schema,
            table_name,
            column_name,
            pg_get_serial_sequence(
                quote_ident(table_schema) || '.' || quote_ident(table_name),
                column_name
            ) AS seq
        FROM information_schema.columns
        WHERE table_schema = 'utility'
    LOOP
        IF r.seq IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(%I) + 1 FROM %I.%I), 1), false)',
                r.seq,
                r.column_name,
                r.table_schema,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT
            table_schema,
            table_name,
            column_name,
            pg_get_serial_sequence(
                quote_ident(table_schema) || '.' || quote_ident(table_name),
                column_name
            ) AS seq
        FROM information_schema.columns
        WHERE table_schema = 'security'
    LOOP
        IF r.seq IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(%I) + 1 FROM %I.%I), 1), false)',
                r.seq,
                r.column_name,
                r.table_schema,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT
            table_schema,
            table_name,
            column_name,
            pg_get_serial_sequence(
                quote_ident(table_schema) || '.' || quote_ident(table_name),
                column_name
            ) AS seq
        FROM information_schema.columns
        WHERE table_schema = 'purchase'
    LOOP
        IF r.seq IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(%I) + 1 FROM %I.%I), 1), false)',
                r.seq,
                r.column_name,
                r.table_schema,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT
            table_schema,
            table_name,
            column_name,
            pg_get_serial_sequence(
                quote_ident(table_schema) || '.' || quote_ident(table_name),
                column_name
            ) AS seq
        FROM information_schema.columns
        WHERE table_schema = 'inventory'
    LOOP
        IF r.seq IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(%I) + 1 FROM %I.%I), 1), false)',
                r.seq,
                r.column_name,
                r.table_schema,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT
            table_schema,
            table_name,
            column_name,
            pg_get_serial_sequence(
                quote_ident(table_schema) || '.' || quote_ident(table_name),
                column_name
            ) AS seq
        FROM information_schema.columns
        WHERE table_schema = 'erpmaster'
    LOOP
        IF r.seq IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(%I) + 1 FROM %I.%I), 1), false)',
                r.seq,
                r.column_name,
                r.table_schema,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT
            table_schema,
            table_name,
            column_name,
            pg_get_serial_sequence(
                quote_ident(table_schema) || '.' || quote_ident(table_name),
                column_name
            ) AS seq
        FROM information_schema.columns
        WHERE table_schema = 'erpinventory'
    LOOP
        IF r.seq IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(%I) + 1 FROM %I.%I), 1), false)',
                r.seq,
                r.column_name,
                r.table_schema,
                r.table_name
            );
        END IF;
    END LOOP;
END $$;
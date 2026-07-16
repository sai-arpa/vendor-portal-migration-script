-- DROP FUNCTION migration.parse_sqlserver_datetime(text);

create schema if not exists migration;

CREATE OR REPLACE FUNCTION migration.parse_sqlserver_datetime(p_value text)
 RETURNS timestamp with time zone
 LANGUAGE sql
 IMMUTABLE
AS $function$
    SELECT CASE
    WHEN p_value IS NULL OR trim(p_value) = '' THEN NULL

    -- Format 1: SQL Server style string
    WHEN p_value ~ '^[A-Za-z]{3}\s+\d{1,2}\s+\d{4}'
    THEN to_timestamp(
        p_value,
        'Mon DD YYYY HH12:MI:SS:MSPM'
    )

    -- Format 2: ISO timestamp with timezone
    ELSE p_value::timestamptz
END
$function$;
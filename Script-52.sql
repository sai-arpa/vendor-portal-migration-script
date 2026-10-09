SELECT
    pid,
    usename,
    application_name,
    client_addr,
    client_hostname,
    state,
    backend_start,
    query_start,
    query
FROM pg_stat_activity
WHERE datname = 'eProcurement_Reals_Staging_LH_Integrated';



SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'eProcurement_Reals_Staging_LH_Integrated';
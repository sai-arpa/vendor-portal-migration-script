SELECT
    s.srvname AS server_name,
    fdw.fdwname AS fdw_name,
    s.srvoptions
FROM pg_foreign_server s
JOIN pg_foreign_data_wrapper fdw
    ON s.srvfdw = fdw.oid;
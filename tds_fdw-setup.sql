CREATE EXTENSION tds_fdw;

SELECT * FROM pg_extension;

------------------------------------


CREATE SERVER sqlserver_fdw
FOREIGN DATA WRAPPER tds_fdw
OPTIONS (
    servername '192.168.2.181',
    port '1433',
    database 'RealDeals31082026' --RealDeals16062026
);

--ALTER SERVER sqlserver_fdw
--OPTIONS (
--    SET database 'RealDeals16062026'
--);


---check server------------
SELECT srvname, srvoptions
FROM pg_foreign_server;
---------------------------

--------------------------------------------------

CREATE USER MAPPING FOR CURRENT_USER
SERVER sqlserver_fdw
OPTIONS (
    username 'user01',
    password 'user01'
);

-- {servername=192.168.87.12,port=1433,database=Hfalportal03072026}
--------------------------------------------------------

SELECT
    srvname,
    srvowner::regrole AS owner,
    fdw.fdwname,
    srvoptions
FROM pg_foreign_server s
JOIN pg_foreign_data_wrapper fdw
ON s.srvfdw = fdw.oid;

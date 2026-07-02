CREATE EXTENSION tds_fdw;

SELECT * FROM pg_extension;


CREATE SERVER sqlserver_fdw
FOREIGN DATA WRAPPER tds_fdw
OPTIONS (
    servername '192.168.2.181',
    port '1433',
    database 'RealDeals16062026'
);


CREATE USER MAPPING FOR CURRENT_USER
SERVER sqlserver_fdw
OPTIONS (
    username 'user01',
    password 'user01'
);



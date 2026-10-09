CREATE EXTENSION IF NOT EXISTS oracle_fdw;


CREATE SERVER oracle_server
FOREIGN DATA WRAPPER oracle_fdw
OPTIONS (
    dbserver '//192.168.2.197:1521/ORCLRIPL'
);

CREATE USER MAPPING FOR postgres
SERVER oracle_server
OPTIONS (
    user 'ppuser',
    password 'pp#env$test'
);
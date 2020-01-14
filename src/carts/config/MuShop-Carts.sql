CREATE USER carts_user IDENTIFIED BY Default_Password123#;

CREATE ROLE carts_role;

GRANT
    CREATE SESSION
TO carts_user;
-- Do not use in production, can be exploited for SQL injection attacks.

GRANT
    CREATE TABLE,
    CREATE VIEW,
    CREATE PROCEDURE,
    CREATE SEQUENCE,
    SODA_APP
TO carts_role;

GRANT
    UNLIMITED TABLESPACE
TO carts_user;

GRANT carts_role TO carts_user;

ALTER USER carts_user
    ACCOUNT UNLOCK;
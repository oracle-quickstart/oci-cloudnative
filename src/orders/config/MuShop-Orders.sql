CREATE USER orders_user IDENTIFIED BY Default_Password123#;

CREATE ROLE orders_role;

GRANT dwrole TO orders_user;

GRANT
    CREATE SESSION
TO orders_user;
-- Do not use in production, can be exploited for SQL injection attacks.

GRANT
    CREATE TABLE,
    CREATE VIEW,
    CREATE PROCEDURE,
    CREATE SEQUENCE
TO orders_role;

GRANT
    UNLIMITED TABLESPACE
TO orders_user;

GRANT orders_role TO orders_user;

ALTER USER orders_user
    ACCOUNT UNLOCK;

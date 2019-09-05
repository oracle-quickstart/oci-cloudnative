CREATE USER musers_user IDENTIFIED BY default_MuPass1;

GRANT DWROLE TO musers_user;

GRANT CREATE SESSION TO musers_user;

CREATE ROLE musers_role;

GRANT
    CREATE TABLE,
    CREATE VIEW,
    CREATE PROCEDURE,
    CREATE SEQUENCE
TO musers_role;

GRANT UNLIMITED TABLESPACE TO musers_role;

GRANT musers_role TO musers_user;

ALTER USER musers_user ACCOUNT UNLOCK;

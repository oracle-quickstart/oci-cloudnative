#! /bin/sh

# This script prepares the OADB user schema statements by using
# env var subsitition for a configured OADB_SCHEMA_USER_PW value.
# This password, in combination with musers_user

cat <<EOF
CREATE USER musers_user IDENTIFIED BY ${OADB_SCHEMA_USER_PW};

GRANT CREATE SESSION TO musers_user;

GRANT UNLIMITED TABLESPACE TO musers_user;

CREATE ROLE musers_role;

GRANT
    CREATE TABLE,
    CREATE VIEW,
    CREATE PROCEDURE,
    CREATE SEQUENCE
TO musers_role;

GRANT musers_role TO musers_user;

ALTER USER musers_user ACCOUNT UNLOCK;
EOF
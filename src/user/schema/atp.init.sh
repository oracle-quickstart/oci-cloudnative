#! /bin/sh

# This script prepares the OADB user schema statements by using
# env var subsitition for configured values of ${OADB_USER} and ${OADB_PW}.

cat <<EOF
CREATE USER ${OADB_USER} IDENTIFIED BY ${OADB_PW};

GRANT CREATE SESSION TO ${OADB_USER};

GRANT UNLIMITED TABLESPACE TO ${OADB_USER};

CREATE ROLE ${OADB_USER}_role;

GRANT
    CREATE TABLE,
    CREATE VIEW,
    CREATE PROCEDURE,
    CREATE SEQUENCE
TO ${OADB_USER}_role;

GRANT ${OADB_USER}_role TO ${OADB_USER};

ALTER USER ${OADB_USER} ACCOUNT UNLOCK;
EOF
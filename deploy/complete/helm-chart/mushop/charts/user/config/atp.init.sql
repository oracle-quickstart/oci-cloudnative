-- Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
-- Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.

SET SERVEROUTPUT ON;
SET VERIFY OFF;
BEGIN
	-- Schema User Creation
	DECLARE
		schemaUserExists INTEGER;
	BEGIN
		SELECT COUNT(*) 
		INTO schemaUserExists 
		FROM ALL_USERS 
		WHERE username = '&1';
		DBMS_OUTPUT.PUT_LINE ('** Schema creationg steps - &_DATE');
		IF schemaUserExists = 0 THEN
			DBMS_OUTPUT.PUT_LINE ('Creating schema = &1 ...');
			EXECUTE IMMEDIATE 'CREATE USER &1 IDENTIFIED BY &2';
			EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO &1';
			EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO &1';
		ELSE
			DBMS_OUTPUT.PUT_LINE ('Schema User = &1 exists, steps ignored');
		END IF;
	END;

	-- Role Creation
	DECLARE
		roleExists INTEGER;
		roleName VARCHAR2 (100);
	BEGIN
		roleName := '&1' || '_ROLE';
		SELECT COUNT(*) 
		INTO roleExists 
		FROM DBA_ROLES 
		WHERE role = roleName;
		DBMS_OUTPUT.PUT_LINE ('** Role creationg steps - &_DATE');
		IF roleExists = 0 THEN
			DBMS_OUTPUT.PUT_LINE ('Creating Role ' || roleName || '...' );
			EXECUTE IMMEDIATE 'CREATE ROLE ' || roleName;
			EXECUTE IMMEDIATE 'GRANT ' || roleName || ' TO &1';
			EXECUTE IMMEDIATE 'GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO ' || roleName;
		ELSE
			DBMS_OUTPUT.PUT_LINE ('Role '|| roleName ||' exists, steps ignored');
		END IF;
	END;
END;
/

quit;
/
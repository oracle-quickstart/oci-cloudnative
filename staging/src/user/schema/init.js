/**
 * workaround for use of typeorm to initialize user schema with multi-line query
 */

const path = require('path');
const child = require('child_process');
const { createConnection } = require('typeorm');

const SCHEMA_FILE = 'atp.init.sh';

/**
 * load a file by executing script with environment variable interpolation
 * @param {string} file 
 */
async function getStatement(file) {
  return new Promise((resolve, reject) => {
    child.exec(file, (err, stdout, stderr) => {
      return err ? reject(new Error(stderr)) : resolve(stdout);
    });
  });
}

/**
 * execute single statement
 * @param {*} connection 
 * @param {string} sql 
 * @param {number} i 
 */
async function runStatement(connection, sql, i) {
  return connection
    .query(sql)
    .then(() => console.log(`${i}: ✔`, sql))
    .catch(e => console.warn(`${i}: ✘`, sql, '=>', e.message));
}

/**
 * process init statements though oracledb 
 */
async function init() {
  let connection;
  try {
    // get sql statements
    const sql = await getStatement(path.join(__dirname, SCHEMA_FILE));
    const statements = sql.split(';')
      .map(s => s.trim().replace(/[\n\s]+/g, ' '))
      .filter(s => !!s);

    // get connection

    console.log('-- CONNECT... --');
    connection = await createConnection();
    console.log('-- CONNECTED --');

    // process statements
    console.log('-- BEGIN TRANSACTIONS... --');
    for (let i=0; i<statements.length; i++) {
      await runStatement(connection, statements[i], i);
    }
    console.log('-- END TRANSACTIONS --');

    // close
    console.log('-- DISCONNECT... --');
    await connection.close();
    console.log('-- DISCONNECTED --');
  } catch (e) {
    // handle error
    console.error(e);
    if (connection) {
      await connection.close();
    }
    process.exit(1);
  }
}

init();
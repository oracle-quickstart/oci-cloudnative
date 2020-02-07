/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const config = require('./config');
const { OCIHttpClient } = require('./lib');

/**
 * List objects in the bucket given the ObjectRead visibility
 */
function listAllObjects(oci, bucket) {
  return oci.request(bucket)
    .then(({ data }) => data.objects.map(o => o.name));
}

/**
 * Delete an object by name in the bucket
 */
function deleteObject(oci, bucket, object) {
  return oci.request(bucket + object, {
    method: 'DELETE'
  }).then(() => console.log(`DELETE Success: ${object}`));
}

try {
  // setup oci http client
  const { TENANCY, USER_ID, PRIVATE_KEY, FINGERPRINT, PASSPHRASE } = config.env;
  const oci = new OCIHttpClient({
    tenancyId: TENANCY,
    userId: USER_ID,
    key: PRIVATE_KEY,
    fingerprint: FINGERPRINT,
    passphrase: PASSPHRASE,
  });

  const bucket = config.bucketUrl;
  listAllObjects(oci, bucket)
    .then(list => Promise.all(list.map(deleteObject.bind(null, oci, bucket))))
    .catch(e => console.error(e.toString()));

} catch (e) {
  console.error(`Unknown error`, e.toString());
}
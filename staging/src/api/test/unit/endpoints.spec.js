/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const endpoints = require('../../api/endpoints');

describe('Endpoints', () => {
  
  it('should get service endpoint', () => {
    expect(endpoints.catalogueUrl).toBeTruthy();
  });

  it('should error when service is undefined', () => {
    const bad = () => endpoints.getEnvVar('_FOO_', true);
    expect(bad).toThrow();
  });

});

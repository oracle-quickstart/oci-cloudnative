/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const mock = require('../../helpers/mock');

describe('Healthcheck', () => {

  it('should resolve healthcheck', done => {
    expect.assertions(1);
    mock.app()
      .get('/health')
      .expect(200)
      .expect(res => {
        expect(res.text).toContain('OK');
      }).end(done);
  });
});
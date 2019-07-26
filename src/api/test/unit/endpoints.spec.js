const endpoints = require('../../api/endpoints');

describe('Endpoints', () => {
  
  it('should get service endpoint', () => {
    expect(endpoints.catalogueUrl).toBeTruthy();
  });

  it('should error when service is undefined', () => {
    const bad = () => endpoints.getEnvVar('_FOO_');
    expect(bad).toThrow();
  });

});

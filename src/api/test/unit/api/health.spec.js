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
const mock = require('../../helpers/mock');

describe('Configuration', () => {

  it('should resolve configuration', done => {
    expect.assertions(2);
    mock.app()
      .get('/config')
      .expect(200)
      .expect(({body}) => {
        expect(body.staticAssetPrefix).toBeDefined();
        expect(body.mockMode).toBeDefined();
      }).end(done);
  });

});
/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const fs = require('fs');
const mock = require('../../helpers/mock');

describe('Catalog', () => {
  it('should list products', done => {
    expect.assertions(1);

    mock.service()
      .get('/catalogue')
      .reply(200, [{name: 'foo'}]);

    mock.app()
      .get(`/api/catalogue`)
      .expect(200)
      .expect(({ body }) => expect(body.length).toBe(1))
      .end(done);
  });

  it('should resolve categories', done => {
    expect.assertions(1);

    mock.service()
      .get('/categories')
      .reply(200, {
        categories: [
          "Cleaning Supplies",
          "Deodorizers"
        ]
      });

    mock.app()
      .get(`/api/categories`)
      .expect(200)
      .expect(({ body }) => expect(body.categories.length).toBe(2))
      .end(done);
  });

  it('should stream images', done => {
    expect.assertions(1);
    const req = '/catalogue/images/feeder.jpg';
    const file = __filename;
    const fileContent = fs.readFileSync(file).toString();
    
    mock.service()
      .get(req)
      .reply(200, () => fs.createReadStream(file));
      
    mock.app()
      .get(`/api${req}`)
      .expect(200)
      .expect(res => expect(res.text).toEqual(fileContent))
      .end(done);
  });
});

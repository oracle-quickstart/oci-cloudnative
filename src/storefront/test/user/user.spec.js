
import { MockMu, MockHttp } from '../helper/mock';
import { UserController } from '../helper/main';
import { MUSHOP } from '../../src/scripts/shop/constants';
import { MockUser } from '../helper/data';



describe('User', () => {
  let mocker;
  beforeAll(() => mocker = MockMu.mock());

  describe('Controller', () => {
    let ctrl;

    beforeAll(() => ctrl = mocker.mu[MUSHOP.MACRO.USER]);
    
    test(`should initialize as '${MUSHOP.MACRO.USER}' macro`, () => 
      expect(ctrl instanceof UserController).toBe(true));
    
    test('should fetch user on mu:ready', () => {
      mocker.silence(ctrl); // silence emits
      // MockHttp.mock(mocker.mu, 'get', MockHttp.response(MockUser)); // mock the http response
      const spy = jest.spyOn(ctrl, 'getUser').mockResolvedValue(MockUser);
      mocker.run();
      expect(spy).toHaveBeenCalled();
    });

  });

});

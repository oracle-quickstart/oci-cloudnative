
import { MockMu, MockHttp } from '../helper/mock';
import { UserController } from '../helper/main';
import { MUSHOP } from '../../src/scripts/shop/constants';
import { MockUser } from '../helper/data';



describe('User', () => {
  let mocker;
  beforeAll(() => mocker = MockMu.mock());

  describe('Controller', () => {
    
    test(`should initialize as '${MUSHOP.MACRO.USER}' macro`, () => {
      const { user } = mocker.mu;
      expect(user instanceof UserController).toBe(true);
    });
      
    
    test('should fetch user on mu:ready', () => {
      const { user } = mocker.mu;
      // MockHttp.mock(mocker.mu, 'get', MockHttp.response(MockUser)); // mock the http response
      const spy = jest.spyOn(user, 'getUser');
      mocker.silence(user).run();
      expect(spy).toHaveBeenCalled();
    });

    test('should update user on changes', async () => {
      const { user, http } = mocker.mu;
      const spy = jest.spyOn(user, 'getUser');
      mocker.silence(user);
      
      await user.register(MockUser);
      await user.login('test', 'foo');
      await user.logout();
      expect(spy).toHaveBeenCalledTimes(2);
    });

  });

});

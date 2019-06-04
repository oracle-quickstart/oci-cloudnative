import axios from 'axios';
import { Mu } from '../mu';
import { MUSHOP } from './constants';

export function ApiClient() {
  return axios.create({
    baseURL: '/api',
    withCredentials: true,
  });
}

export default Mu.macro(MUSHOP.MACRO.HTTP, ApiClient);

import axios from 'axios';
import { Mu } from '../mu';

export function ApiClient() {
  return axios.create({
    baseURL: '/api',
    withCredentials: true,
  });
}

export default Mu.macro('api', ApiClient);

// load deps
import { Mu } from './mu';

// load mushop
import './shop';

// Run Mu Shop
export default Mu.run(document.getElementById('app'), {
  root: '#app',
  baseViewUrl: 'views',
});

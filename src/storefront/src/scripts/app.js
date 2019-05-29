// load deps
import 'core-js/features/promise';

// load app modules
import { Mu } from './mu';
import './shop/ui'; // uikit adapter
import './shop/api'; // axios adapter
import './shop/router'; 
import './shop/page';
// shop specific
import './shop/user';
import './shop/catalog';
import './shop/cart';
import './shop/order';
import './shop/components/debug';
import './shop/components/form';

// Run Mu Shop
export default Mu.init(document.getElementById('app'), {
  root: '#app',
  baseViewUrl: 'views',
});

import Vue from 'vue';
import App from './App.vue';
import ViewUI from 'view-design';
import 'view-design/dist/styles/iview.css';
import './common/const'
import axios from 'axios'
import VueAxios from 'vue-axios'

Vue.config.productionTip = false;
Vue.use(ViewUI);
Vue.use(VueAxios, axios)

new Vue({
  render: h => h(App),
}).$mount('#app');

import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

import Index from 'components/Index'
import Uploader from 'components/Uploader'
import Faq from 'components/Faq'
import Dmca from 'components/Dmca'

export default new Router({
  mode: 'history',
  root: '/',
  routes: [
    {
      path: '/',
      name: 'Index',
      component: Index
    },
    {
      path: '/files',
      name: 'files',
      component: Uploader
    },
    {
      path: '/faq',
      name: 'faq',
      component: Faq
    },
    {
      path: '/dmca',
      name: 'dmca',
      component: Dmca
    }
  ]
})

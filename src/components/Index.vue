<template>
  <div>
    <Uploader class="center"/>
  </div>
</template>

<script>
import Uploader from './Uploader'
import Faq from './Faq'
import Dmca from './Dmca'
export default {
  name: 'hello',
  data () {
    return {
    }
  },
  components: {
    Uploader,
    Faq,
    Dmca
  }
}
</script>

<style scoped>
div {
  width: 100%;
}
</style>

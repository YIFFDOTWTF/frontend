<template>
  <div id="app">
    <h1>yiff.wtf</h1>
    <router-view></router-view>
  </div>
</template>

<script>
export default {
  name: 'app',
  methods: {
    root () {
      this.$router.push('/')
    }
  }
}
</script>

<style>
* {
  font-family: "Roboto Mono", monospace;
  color: #e8e8e8;
}

body {
  background-color: #1c1c1c;
}

.big-img {
  max-width: 70%;
  max-height: 15rem;
}

#app {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
}

h1 {
  margin-top: 0px;
  margin-bottom: 10px;
  font-family: sans-serif;
  font-size: 8rem;
  background: linear-gradient(to right, #ef5350, #f48fb1, #7e57c2, #2196f3, #26c6da, #43a047, #eeff41, #f9a825, #ff5722);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
</style>

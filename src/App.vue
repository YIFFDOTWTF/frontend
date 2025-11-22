<template>
  <div id="app">
    <h1>yiff.wtf</h1>
    <router-view></router-view>
  </div>
</template>

<script>
export default {
  name: "app",
  methods: {
    root() {
      this.$router.push("/");
    },
  },
};
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
  /* animated rainbow gradient */
  background: linear-gradient(
    90deg,
    #ef5350,
    #f48fb1,
    #7e57c2,
    #2196f3,
    #26c6da,
    #43a047,
    #eeff41,
    #f9a825,
    #ff5722
  );
  background-size: 200% 100%;
  background-clip: text;
  -webkit-background-clip: text;
  color: transparent;
  -webkit-text-fill-color: transparent;
  animation: rainbow 6s linear infinite;
}

/* animate the gradient so the colors appear to flow */
@keyframes rainbow {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}
</style>

<template>
  <v-app>
    <v-toolbar app>
      <v-toolbar-side-icon class="grey--text" @click="drawer = !drawer" />
      <v-toolbar-title class="headline text-uppercase">
        <span>Takenoko</span>
        <span class="font-weight-light">&nbsp;Vue.ts&nbsp;</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn flat href="https://takenokotech.github.io/portfolio/" target="_blank">
        <span class="mr-2">Portfolio</span>
      </v-btn>
    </v-toolbar>

    <v-navigation-drawer app v-model="drawer">
      <v-list>
        <v-list-tile v-for="link in links" :key="link.text" router :to="link.route">
          <v-list-tile-action>
            <v-icon>{{link.icon}}</v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title>{{link.text}}</v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer>

    <v-content>
      <!-- <HelloWorld/> -->
      <router-view />
    </v-content>

    <v-footer height="100px">
      <v-layout row wrap px-4 justify-space-between>
        <v-flex class="xs12" style="text-align: center; margin: 4px 4px 15px">
          <a href="https://developer.yahoo.co.jp/about">Web Services by Yahoo! JAPAN</a>
        </v-flex>
        <v-spacer></v-spacer>
        <v-flex class="xs12 grey--text text--darken-2" style="text-align: center;">
          &copy;{{ new Date().getFullYear() }}
          <strong>Takenoko Tech.</strong>
        </v-flex>
      </v-layout>
    </v-footer>
  </v-app>
</template>

<script>
import HelloWorld from './components/HelloWorld';

export default {
  name: 'App',
  components: {
    HelloWorld,
  },
  data() {
    return {
      drawer: false,
      links: [
        { icon: 'dashboard', text: 'Home', route: '/' },
        { icon: 'dashboard', text: 'About', route: '/about' },
        // { icon: 'dashboard', text: 'Map', route: '/map' },
      ],
    };
  },
};
</script>

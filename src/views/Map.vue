<template>
  <div class="map">
    <!-- <v-container class="elevation-2" style="padding:0px;"> -->
    <div id="map_view"/>
    <!-- </v-container> -->
    <v-container id="map_card" grid-list-md>
      <v-layout row wrap>
        <v-flex v-for="card in cards" :key="card.title" v-bind="{ [`xs${card.flex}`]: true }">
          <v-card>
            <v-img :src="card.image" aspect-ratio="2.75"></v-img>
            <v-card-title primary-title>
              <div>
                <!-- <h3 class="headline mb-0">{{card.title}}</h3> -->
                <div>{{ card.text }}</div>
              </div>
            </v-card-title>
          </v-card>
        </v-flex>
      </v-layout>
    </v-container>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';
import L from '@/plugins/leaflet';
import YolpRepository from '@/repository/yolp';

const onClick = (map: L.Map, p: any) => {
  map.addLayer(L.marker(p.latlng));
};

const didMount = async (self: any) => {
  const lat = 35.6825;
  const lon = 139.752778;
  const map: L.Map = L.map('map_view', {
    center: L.latLng(lat, lon),
    zoom: 15,
  })
    .addLayer(L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png'))
    .on('click', (p: any) => onClick(map, p));

  const result = await YolpRepository.localserch(lat, lon);
  const cards: any[] = [];

  for (const store of result) {
    const [storeLon, storeLat] = store.Geometry.Coordinates.split(',');
    const latlon = new L.LatLng(storeLat, storeLon);
    map.addLayer(L.marker(latlon));
    if (store.Property.LeadImage) {
      cards.push({
        image: store.Property.LeadImage,
        title: store.Gid,
        text: store.Name,
        flex: 6,
      });
    }
  }
  self.cards = cards;
};

export default Vue.extend({
  mounted() {
    didMount(this);
  },
  data() {
    return {
      cards: [
        // { image: '', title: 'title1', text: 'Home', flex: 4 },
        // { image: '', title: 'title2', text: 'About', flex: 4 },
        // { image: '', title: 'title3', text: 'Map', flex: 4 },
      ],
    };
  },
});
</script>

<style>
.map {
  position: relative;
  width: 100%;
  height: 100%;
}
#map_view {
  width: 100%;
  height: 400px;
  background-color: black;
}
#map_card {
  /* position: absolute; */
  /* right: 16px; */
  /* left: 16px; */
  /* top: 16px; */
  /* background-color: black; */
  /* z-index: 1000; */
}
</style>

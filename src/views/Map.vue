<template>
  <div class="map">
    <div id="map_view"/>
    <v-container id="map_card">
      <div></div>
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

const didMount = async () => {
  const lat = 35.6825;
  const lon = 139.752778;
  const map: L.Map = L.map('map_view', {
    center: L.latLng(lat, lon),
    zoom: 15,
  })
    .addLayer(L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png'))
    .on('click', (p: any) => onClick(map, p));

  const result = await YolpRepository.localserch(lat, lon);
  for (const store of result) {
    const [storeLon, storeLat] = store.Geometry.Coordinates.split(',');
    const latlon = new L.LatLng(storeLat, storeLon);
    map.addLayer(L.marker(latlon));
  }
};

export default Vue.extend({
  mounted() {
    didMount();
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
  height: 66%;
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

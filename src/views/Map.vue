<template>
  <div class="map">
    <v-layout class="elevation-4" v-bind="{ [`d-folding`]: !mapDisplay}" style="position: relative">
      <div id="map_view" style="z-index: 0;"/>
      <v-btn absolute dark fab bottom right color="primary" @click="mapDisplay = !mapDisplay">
        <v-icon>zoom_out_map</v-icon>
      </v-btn>
    </v-layout>
    <v-container id="map_card" grid-list-md>
      <div class="text-xs-center" v-if="loading">
        <v-progress-circular indeterminate color="primary"></v-progress-circular>
      </div>
      <v-layout row wrap style="position: relative">
        <v-flex v-for="card in cards" :key="card.title" v-bind="{ [`xs${card.flex}`]: true }">
          <v-card>
            <v-img :src="card.image" aspect-ratio="2.75">
              <v-container fill-height fluid pa-2 style="background: rgba(0,0,0,0.5);">
                <v-layout fill-height>
                  <v-flex xs12 align-end flexbox>
                    <span class="white--text" v-text="card.name"></span>
                  </v-flex>
                </v-layout>
              </v-container>
            </v-img>
            <!-- <v-card-title primary-title> -->
            <!-- <div> -->
            <!-- <h3 class="headline mb-0">{{card.title}}</h3> -->
            <!-- <div>{{ card.text }}</div> -->
            <!-- </div> -->
            <!-- </v-card-title> -->
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
        gid: store.Gid,
        name: store.Name,
        flex: 3,
      });
    }
  }
  self.loading = false;
  self.cards = cards;
};

export default Vue.extend({
  mounted() {
    didMount(this);
  },
  data() {
    return {
      mapDisplay: true,
      loading: true,
      cards: [],
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
  height: 720px;
  background-color: black;
}

.d-folding #map_view {
  height: 300px;
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

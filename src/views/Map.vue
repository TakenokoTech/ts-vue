<template>
  <div class="map">
    <v-layout class="elevation-4" v-bind="{ [`d-folding`]: !mapDisplay}" style="position: relative">
      <div id="map_view" style="z-index: 0;"/>
      <v-btn absolute dark fab bottom right color="primary" @click="mapDisplay = !mapDisplay">
        <v-icon>zoom_out_map</v-icon>
      </v-btn>
    </v-layout>
    <v-container id="map_card" grid-list-md v-scroll="handleScroll">
      <v-layout row wrap style="position: relative">
        <v-alert :value="true" type="success">
          <div>{{this.info.Start + this.info.Count -1}} / {{info.Total}}</div>
        </v-alert>
      </v-layout>
      <v-layout row wrap style="position: relative">
        <v-flex v-for="card in cards" :key="card.title" v-bind="{ [`xs${card.flex}`]: true }">
          <v-card @click="onClickToCard(card)">
            <v-img :src="card.image" aspect-ratio="2">
              <v-container fill-height fluid pa-2 style="background: rgba(0,0,0,0.5);">
                <v-layout fill-height>
                  <v-flex xs12 align-end flexbox>
                    <span class="white--text" v-text="card.name"></span>
                  </v-flex>
                </v-layout>
              </v-container>
            </v-img>
          </v-card>
        </v-flex>
      </v-layout>
      <div class="text-xs-center" v-if="loading">
        <v-progress-circular indeterminate color="primary"></v-progress-circular>
      </div>
    </v-container>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';
import L from '@/plugins/leaflet';
import YolpRepository from '@/repository/yolp';
import yolp from '@/repository/yolp';

const didMount = async (self: any) => {
  self.map = L.map('map_view', {
    center: L.latLng(self.lat, self.lon),
    zoom: 15,
  })
    .addLayer(L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png'))
    .on('click', (p: any) => onClickToMap(self, p));
  load(self, 1);
};

const load = async (self: any, start: number) => {
  self.loading = true;
  self.info = { Total: 0, Start: 1, Count: 0 };
  const [result, info] = await YolpRepository.localserch(
    self.lat,
    self.lon,
    start,
  );
  const cards: any[] = self.cards;
  for (const store of result || []) {
    const [storeLon, storeLat] = store.Geometry.Coordinates.split(',');
    const latlon = new L.LatLng(storeLat, storeLon);
    cards.push({
      image: store.Property.LeadImage,
      gid: store.Gid,
      name: store.Name,
      marker: L.marker(latlon),
      flex: 3,
    });
    self.map.addLayer(cards[cards.length - 1].marker);
  }
  self.loading = false;
  self.info = info;
  self.cards = cards;
};

const onClickToCard = (self: any, p: any) => {
  p.marker
    .addTo(self.map)
    .bindPopup(L.popup().setContent(p.name))
    .openPopup();
  self.map.setView([p.marker.getLatLng().lat, p.marker.getLatLng().lng]);
};

const onClickToMap = (self: any, p: any) => {
  self.lat = p.latlng.lat;
  self.lon = p.latlng.lng;
  for (const card of self.cards) {
    self.map.removeLayer(card.marker);
  }
  self.map.setView([self.lat, self.lon]);
  self.cards = [];
  load(self, 0);
};

const handleScroll = (self, event) => {
  const map = document.querySelector(`.map`);
  const scrollY = window.scrollY;
  const innerHeight = window.innerHeight;
  const clientHeight = map ? map.clientHeight : 0;
  if (!self.loading && scrollY + innerHeight > clientHeight) {
    const nextStart = self.info.Start + self.info.Count;
    if (nextStart < self.info.Total) {
      load(self, nextStart);
    }
  }
};

export default Vue.extend({
  mounted() {
    didMount(this);
  },
  data() {
    return {
      lat: 35.6825,
      lon: 139.752778,
      info: { Total: 0, Start: 1, Count: 0 },
      mapDisplay: true,
      loading: true,
      cards: [],
    };
  },
  methods: {
    handleScroll(event) {
      handleScroll(this, event);
    },
    onClickToCard(event) {
      onClickToCard(this, event);
    },
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
  height: 600px;
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

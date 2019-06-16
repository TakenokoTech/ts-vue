<template>
  <div class="map">
    <v-layout id="map_content" class="elevation-4" v-bind="{ [`d-folding`]: folding}">
      <div id="map_view" style="z-index: 0;"/>
      <v-btn absolute dark fab bottom right color="primary" @click="folding = !folding">
        <v-icon>zoom_out_map</v-icon>
      </v-btn>
    </v-layout>
    <v-container id="map_card" grid-list-md v-scroll="handleScroll">
      <v-layout row wrap style="position: relative" pb-5>
        <div class="text-xs-center" style="width: 100%;">
          <span v-for="station in stations" v-bind:key="station.name">
            <v-btn
              outline
              color="primary"
              @click="onClickToStation(station.marker)"
            >{{station.name}}</v-btn>
          </span>
        </div>
        <div class="text-xs-center" style="width: 100%;">
          <span v-for="genre in Object.keys(genres)" v-bind:key="genre.name">
            <v-btn
              round
              color="primary"
              @click="onClickToGenre(genre)"
              v-bind="{[`outline`]: !genres[genre].selected}"
            >{{genre}}</v-btn>
          </span>
          <v-menu offset-y v-if="genreStr()">
            <template v-slot:activator="{on}">
              <v-btn round color="primary" dark v-on="on" v-bind="{flat: true}">
                <u>詳細検索</u>
              </v-btn>
            </template>
            <v-list>
              <v-list-tile
                v-for="genre in Object.keys(otherGenre())"
                :key="genre"
                @click="onClickToGenre(genre)"
              >
                <v-list-tile-title>{{genre}}</v-list-tile-title>
              </v-list-tile>
            </v-list>
          </v-menu>
        </div>
      </v-layout>
      <v-layout row wrap style="position: relative">
        <v-alert :value="true" type="success">
          <div>{{genreStr()}}</div>
          <div>{{stations.length > 1 ? stations[0].name + " 周辺" : ""}}</div>
          <div>{{info.Start + info.Count -1}} / {{info.Total}}</div>
        </v-alert>
      </v-layout>
      <v-layout row wrap style="position: relative">
        <v-flex v-for="card in cards" :key="card.title" v-bind="card.flex">
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
import * as MapUtils from '@/utils/MapUtils';
import * as GenreJson from '@/utils/GenreJson';

const didMount = async (self: any) => {
  self.map = L.map('map_view', {
    center: L.latLng(self.lat, self.lon),
    zoom: 15,
  })
    .addLayer(L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png'))
    .on('click', (p: any) => onClickToMap(self, p.latlng.lat, p.latlng.lng));
  loadStore(self, 1);
  loadStation(self, 1);
};

const loadStore = async (self: any, start: number) => {
  self.loading = true;
  self.info = { Total: 0, Start: 1, Count: 0 };
  const [result, info] = await YolpRepository.localserch(
    self.lat,
    self.lon,
    start,
    {
      gc: GenreJson.transformCode(MapUtils.enable(self.genres) || '') || '',
    },
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
      flex: { xs6: true, sm6: true, md3: true },
    });
    self.map.addLayer(cards[cards.length - 1].marker);
  }
  self.loading = false;
  self.info = info;
  self.cards = cards;
};

const loadStation = async (self, start) => {
  const [result, info] = await YolpRepository.localserch(
    self.lat,
    self.lon,
    start,
    {
      image: false,
      gc: '0306006',
      dist: 1,
    },
  );
  self.stations = [];
  for (const store of result || []) {
    store.Name = store.Name.split('　').pop();
    if (!store.Name.endsWith('駅')) {
      continue;
    }
    const [storeLon, storeLat] = store.Geometry.Coordinates.split(',');
    const latlon = new L.LatLng(storeLat, storeLon);
    self.stations.push({
      gid: store.Gid,
      name: store.Name,
      marker: L.marker(latlon),
    });
  }
};

const onClickToCard = (self: any, p: any) => {
  p.marker
    .addTo(self.map)
    .bindPopup(L.popup().setContent(p.name))
    .openPopup();
  self.map.setView([p.marker.getLatLng().lat, p.marker.getLatLng().lng]);
};

const onClickToMap = (self: any, lat: number, lon: number) => {
  self.lat = lat;
  self.lon = lon;
  for (const card of self.cards) {
    self.map.removeLayer(card.marker);
  }
  self.map.setView([self.lat, self.lon], 15);
  self.cards = [];
  loadStore(self, 0);
  loadStation(self, 0);
};

const onClickToStation = (self: any, p: L.Marker) => {
  onClickToMap(self, p.getLatLng().lat, p.getLatLng().lng);
};

const onClickToGenre = (self: any, p: any) => {
  const enable = MapUtils.enableParent(self.genres) || '';
  self.genres = MapUtils.clear(self.genres);
  if (enable !== p) {
    for (const genre of Object.keys(self.genres)) {
      self.genres[genre].selected =
        p === genre ? !self.genres[genre].selected : false;
    }
    if (self.genres[enable]) {
      const g = self.genres[enable];
      for (const genre of Object.keys(g.children)) {
        g.children[genre].selected =
          p === genre ? !g.children[genre].selected : false;
        if (g.children[genre].selected) {
          self.genres[enable].selected = true;
        }
      }
    }
  }
  onClickToMap(self, self.lat, self.lon);
};

const handleScroll = (self, event) => {
  const map = document.querySelector(`.map`);
  const scrollY = window.scrollY;
  const innerHeight = window.innerHeight;
  const clientHeight = map ? map.clientHeight : 0;
  if (!self.loading && scrollY + innerHeight > clientHeight) {
    const nextStart = self.info.Start + self.info.Count;
    if (nextStart < self.info.Total) {
      loadStore(self, nextStart);
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
      folding: false,
      loading: true,
      cards: [],
      stations: [],
      genres: GenreJson.nameList(),
    };
  },
  methods: {
    handleScroll(event) {
      handleScroll(this, event);
    },
    onClickToCard(event) {
      onClickToCard(this, event);
    },
    onClickToStation(event) {
      onClickToStation(this, event);
    },
    onClickToGenre(event) {
      onClickToGenre(this, event);
    },
    genreStr() {
      return MapUtils.enable(this.genres);
    },
    otherGenre() {
      const g = MapUtils.enableParent(this.genres) || '';
      return (this.genres[g] || {}).children || {};
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

#map_content {
  position: relative;
  z-index: 0;
}

#map_view {
  width: 100%;
  height: 600px;
  background-color: black;
}

.d-folding #map_view {
  height: 300px;
}
</style>

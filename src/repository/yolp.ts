import axios from 'axios';
import axiosJsonpAdapter from 'axios-jsonp';

async function localserch(lat: number, lon: number): Promise<any> {
    return new Promise(async resolve => {
        const url = `https://map.yahooapis.jp/search/local/V1/localSearch`;
        const params = {
            appid: 'dj0zaiZpPWhVNU1IbkVNTVN1ViZzPWNvbnN1bWVyc2VjcmV0Jng9NWQ-',
            lat,
            lon,
            results: 100,
            dist: 3,
            output: 'json',
        };
        const json = await axios.get(url, {
            adapter: axiosJsonpAdapter,
            params,
        });
        resolve(json.data.Feature);
    });
}

export default {
    localserch,
};

import axios from 'axios';
import axiosJsonpAdapter from 'axios-jsonp';

interface LocalSearchResultInfo {
    Total: number;
    Start: number;
    Count: number;
}

async function localserch(lat: number, lon: number, start: number): Promise<[any, LocalSearchResultInfo]> {
    return new Promise(async resolve => {
        const url = `https://map.yahooapis.jp/search/local/V1/localSearch`;
        const params = {
            appid: 'dj0zaiZpPWhVNU1IbkVNTVN1ViZzPWNvbnN1bWVyc2VjcmV0Jng9NWQ-',
            lat,
            lon,
            results: 100,
            dist: 5,
            output: 'json',
            start,
            group: 'gid',
            image: true,
        };
        // tslint:disable-next-line:no-console
        console.log(`lat: ${lat}, lon: ${lon}, start: ${start}`);
        const json = await axios.get(url, {
            adapter: axiosJsonpAdapter,
            params,
        });
        resolve([json.data.Feature, {
            Total: json.data.ResultInfo.Total,
            Start: json.data.ResultInfo.Start,
            Count: json.data.ResultInfo.Count,
        }]);
    });
}

export default {
    localserch,
};

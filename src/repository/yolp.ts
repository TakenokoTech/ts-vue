/* tslint:disable:no-console */

import axios from 'axios';
import axiosJsonpAdapter from 'axios-jsonp';

interface LocalSearchResultInfo {
    Total: number;
    Start: number;
    Count: number;
}

interface LocalSearchOption {
    dist?: number;
    image?: boolean;
    gc?: string;
}

async function localserch(
    lat: number,
    lon: number,
    start: number,
    option: LocalSearchOption = {},
): Promise<[any, LocalSearchResultInfo]> {
    return new Promise(async resolve => {
        const url = `https://map.yahooapis.jp/search/local/V1/localSearch`;
        const params = {
            appid: 'dj0zaiZpPWhVNU1IbkVNTVN1ViZzPWNvbnN1bWVyc2VjcmV0Jng9NWQ-',
            lat,
            lon,
            results: 100,
            sort: 'dist',
            output: 'json',
            start,
            group: 'gid',
            dist: option.dist || 1,
            image: option.image === undefined ? true : option.image,
            gc: option.gc || '',
        };
        console.log(`---> API CALL`);
        console.log(`lat: ${lat}, lon: ${lon}, start: ${start}`);
        console.log(option);
        console.log(`<---`);
        const json = await axios.get(url, {
            adapter: axiosJsonpAdapter,
            params,
        });
        resolve([
            json.data.Feature,
            {
                Total: json.data.ResultInfo.Total,
                Start: json.data.ResultInfo.Start,
                Count: json.data.ResultInfo.Count,
            },
        ]);
    });
}

export default {
    localserch,
};

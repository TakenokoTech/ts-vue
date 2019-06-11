export function enable(map: {}): string {
    for (const key of Object.keys(map)) {
        if (map[key]) {
            return key;
        }
    }
    return '';
}

export function clear(map: {}): {} {
    for (const key of Object.keys(map || {})) {
        map[key].selected = false;
        if (!map[key].children) {
            map = clear(map[key].children);
        }
    }
    return map;
}

export function enable(map: {}): string | null {
    for (const key of Object.keys(map || {})) {
        if (map[key].selected) {
            return enable(map[key].children) || key;
        }
    }
    return null;
}

export function enableParent(map: {}): string | null {
    for (const key of Object.keys(map || {})) {
        if (map[key].selected) {
            return key;
        }
    }
    return null;
}

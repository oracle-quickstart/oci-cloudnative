export function addGlobal(prop, val) {
  return window && (() => window[prop] = val)();
}

export function getGlobal(prop) {
  return window && window[prop];
}

export function getWindow() {
  return window || {};
}

export function getDocument() {
  return getGlobal('document');
}

// Loaded by Cordova before deviceready, so cold-start URLs survive asset loading.
(function () {
  'use strict';
  if (window.snackAttackDeepLinks) return;
  var pending = null;
  var serial = 0;
  function valid(url) {
    if (typeof url !== 'string' || url.length > 512) return false;
    try {
      var value = new URL(url);
      if (value.protocol !== 'com.games433.snackattack:' || value.hostname !== 'shop' || value.pathname !== '/outfits' || value.username || value.password || value.port || value.hash) return false;
      var keys = Array.from(value.searchParams.keys());
      return keys.length <= 1 && keys.every(function (key) { return key === 'event'; }) && (!value.search || value.searchParams.get('event') === 'halloween_2026');
    } catch (_) { return false; }
  }
  function receive(url) {
    if (!valid(url)) return false;
    pending = { id: ++serial, url: url };
    return true;
  }
  var previous = window.handleOpenURL;
  window.handleOpenURL = function (url) {
    if (!receive(url) && typeof previous === 'function') previous(url);
  };
  window.snackAttackDeepLinks = {
    receive: receive,
    peek: function () { return pending; },
    consume: function (id) { if (pending && pending.id === id) pending = null; }
  };
})();

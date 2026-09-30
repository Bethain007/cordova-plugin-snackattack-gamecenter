var exec = require('cordova/exec');
exports.auth = function (ok, fail) { exec(ok, fail, 'SnackAttackGameCenter', 'auth', []); };
exports.status = function (ok, fail) { exec(ok, fail, 'SnackAttackGameCenter', 'status', []); };
exports.completeImpulsePurchase = function (playerId, ok, fail) {
  exec(ok, fail, 'SnackAttackGameCenter', 'completeImpulsePurchase', [playerId]);
};

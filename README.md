# Snack Attack Game Center test plugin

Native Cordova iOS bridge for one achievement: `com.games433.snackattack.impulse_purchase` (Impulse Purchase).

**Status: experimental; not compiled, signed, or tested on an iPhone yet.** Local Cordova installation and JavaScript mock tests do not prove native functionality or GDevelop cloud-build compatibility.

The plugin links GameKit and declares `com.apple.developer.game-center = true` in both Debug and Release entitlements. A matching explicit Apple App ID with Game Center enabled and a regenerated provisioning profile are still required.

API after Cordova device readiness:

```js
snackAttackGameCenter.auth(success, failure);
snackAttackGameCenter.status(success, failure);
snackAttackGameCenter.completeImpulsePurchase(expectedGamePlayerId, success, failure);
```

Authentication uses Apple's native UI. Completion checks Apple's existing achievements, reports 100 percent only when incomplete, and sets `GKAchievement.showsCompletionBanner = YES`. There is no custom banner, achievement screen, backend, or reset API. Call completion only after a qualifying purchase succeeds. The GDevelop extension owns the persistent retry queue; this bridge alone does not queue failed reports.

Pin the Cordova dependency to an immutable Git commit. Keep the GitHub repository public so a cloud builder can download it without credentials. This repository contains only the plugin, not the game or signing credentials.

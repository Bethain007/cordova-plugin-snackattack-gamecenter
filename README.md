# Snack Attack Game Center plugin — version 2.1

Native Cordova iOS bridge for Snack Attack's 96-achievement catalog. The original `com.games433.snackattack.impulse_purchase` identifier and API remain supported.

**Version 1's Impulse Purchase automatic-export pipeline was reported working on device by the project owner. Version 2's expanded catalog still needs a new automatic iOS build and iPhone validation.** Local Cordova packaging and JavaScript simulation tests do not prove native functionality.

The plugin links GameKit and declares `com.apple.developer.game-center = true` in both Debug and Release entitlements. A matching explicit Apple App ID with Game Center enabled and a regenerated provisioning profile are still required.

API after Cordova device readiness:

```js
snackAttackGameCenter.auth(success, failure);
snackAttackGameCenter.status(success, failure);
snackAttackGameCenter.completeImpulsePurchase(expectedGamePlayerId, success, failure);
snackAttackGameCenter.completeAchievement(achievementId, expectedGamePlayerId, success, failure);
```

Authentication uses Apple's native UI. Completion accepts only catalog IDs, checks Apple's existing achievements, reports 100 percent only when incomplete, and sets `GKAchievement.showsCompletionBanner = YES`. There is no custom banner, achievement screen, backend, or reset API. Call completion only after a qualifying achievement condition succeeds. The GDevelop extension owns lifetime counters, unlock state and the persistent retry queue; this bridge alone does not queue failed reports. Reports verify the expected Game Center player before and after asynchronous work.

Pin the Cordova dependency to an immutable Git commit. Keep the GitHub repository public so a cloud builder can download it without credentials. This repository contains only the plugin, not the game or signing credentials.

Version 2.1 adds four reach-round achievements: reach_round_5_10, reach_round_10_10, reach_round_15_10 and reach_round_20_10, under the existing com.games433.snackattack. prefix. These count distinct runs reaching each round and unlock optional starting rounds in the GDevelop project. Native validation is still required.

## Native event URL (v2.2.0)

Registers `com.games433.snackattack://shop/outfits?event=halloween_2026` on iOS. The Cordova module captures valid cold/warm-start URLs before `deviceready`; the GDevelop project selects Shop tab 4 after normal startup/account loading. Only this display route is accepted; URLs cannot purchase or grant content. Game Center native source and entitlements are unchanged. Local packaging/routing tests are available; signed iPhone deep-link testing is still required.

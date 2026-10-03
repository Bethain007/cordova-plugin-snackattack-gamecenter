#import "SnackAttackGameCenter.h"

static NSString * const SAImpulseID = @"com.games433.snackattack.impulse_purchase";

@implementation SnackAttackGameCenter
- (void)pluginInitialize {
    self.authCallbacks = [NSMutableArray array];
    self.reporting = NO;
}
- (NSString *)playerID {
    GKLocalPlayer *player = GKLocalPlayer.localPlayer;
    if (!player.isAuthenticated) return @"";
    if (@available(iOS 12.4, *)) return player.gamePlayerID ?: @"";
    return player.playerID ?: @"";
}
- (void)fail:(NSString *)callback code:(NSString *)code message:(NSString *)message {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
        messageAsDictionary:@{@"code":code, @"message":message ?: @"Game Center error"}] callbackId:callback];
}
- (void)sendStatus:(NSString *)callback {
    NSString *pid = [self playerID];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
        messageAsDictionary:@{@"authenticated":@(pid.length > 0), @"playerId":pid,
                              @"pluginVersion":@"2.1.0"}] callbackId:callback];
}
- (void)status:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{ [self sendStatus:command.callbackId]; });
}
- (void)auth:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (GKLocalPlayer.localPlayer.isAuthenticated) { [self sendStatus:command.callbackId]; return; }
        [self.authCallbacks addObject:command.callbackId];
        if (self.authCallbacks.count > 1) return;
        __weak SnackAttackGameCenter *weakSelf = self;
        GKLocalPlayer.localPlayer.authenticateHandler = ^(UIViewController *controller, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SnackAttackGameCenter *strongSelf = weakSelf;
                if (!strongSelf) return;
                if (controller) {
                    UIViewController *presenter = strongSelf.viewController;
                    while (presenter.presentedViewController) presenter = presenter.presentedViewController;
                    [presenter presentViewController:controller animated:YES completion:nil];
                    return;
                }
                NSArray<NSString *> *callbacks = [strongSelf.authCallbacks copy];
                [strongSelf.authCallbacks removeAllObjects];
                for (NSString *callback in callbacks) {
                    if (GKLocalPlayer.localPlayer.isAuthenticated) [strongSelf sendStatus:callback];
                    else [strongSelf fail:callback code:@"AUTHENTICATION_REQUIRED" message:error.localizedDescription];
                }
            });
        };
    });
}
- (BOOL)matchesPlayer:(NSString *)expected {
    return expected.length > 0 && [[self playerID] isEqualToString:expected];
}
- (void)completeImpulsePurchase:(CDVInvokedUrlCommand *)command {
    [self reportCommand:command achievementID:SAImpulseID];
}
- (void)completeAchievement:(CDVInvokedUrlCommand *)command {
    id value = command.arguments.count > 1 ? command.arguments[1] : nil;
    NSSet *allowed = [NSSet setWithArray:@[@"com.games433.snackattack.reach_round_5_10",@"com.games433.snackattack.reach_round_10_10",@"com.games433.snackattack.reach_round_15_10",@"com.games433.snackattack.reach_round_20_10",@"com.games433.snackattack.catch_brock_500",@"com.games433.snackattack.catch_brock_1000",@"com.games433.snackattack.gold_brock_100",@"com.games433.snackattack.catch_cherp_500",@"com.games433.snackattack.catch_cherp_1000",@"com.games433.snackattack.gold_cherp_100",@"com.games433.snackattack.catch_monut_500",@"com.games433.snackattack.catch_monut_1000",@"com.games433.snackattack.gold_monut_100",@"com.games433.snackattack.catch_saltlet_500",@"com.games433.snackattack.catch_saltlet_1000",@"com.games433.snackattack.gold_saltlet_100",@"com.games433.snackattack.catch_spizza_500",@"com.games433.snackattack.catch_spizza_1000",@"com.games433.snackattack.gold_spizza_100",@"com.games433.snackattack.catch_pickle_pup_500",@"com.games433.snackattack.catch_pickle_pup_1000",@"com.games433.snackattack.gold_pickle_pup_100",@"com.games433.snackattack.catch_sprink_500",@"com.games433.snackattack.catch_sprink_1000",@"com.games433.snackattack.gold_sprink_100",@"com.games433.snackattack.catch_bubble_toad_500",@"com.games433.snackattack.catch_bubble_toad_1000",@"com.games433.snackattack.gold_bubble_toad_100",@"com.games433.snackattack.catch_cocow_500",@"com.games433.snackattack.catch_cocow_1000",@"com.games433.snackattack.gold_cocow_100",@"com.games433.snackattack.catch_crabbage_500",@"com.games433.snackattack.catch_crabbage_1000",@"com.games433.snackattack.gold_crabbage_100",@"com.games433.snackattack.catch_knarrot_500",@"com.games433.snackattack.catch_knarrot_1000",@"com.games433.snackattack.gold_knarrot_100",@"com.games433.snackattack.catch_avocodile_500",@"com.games433.snackattack.catch_avocodile_1000",@"com.games433.snackattack.gold_avocodile_100",@"com.games433.snackattack.catch_gookie_500",@"com.games433.snackattack.catch_gookie_1000",@"com.games433.snackattack.gold_gookie_100",@"com.games433.snackattack.catch_nutter_500",@"com.games433.snackattack.catch_nutter_1000",@"com.games433.snackattack.gold_nutter_100",@"com.games433.snackattack.catch_brurtle_500",@"com.games433.snackattack.catch_brurtle_1000",@"com.games433.snackattack.gold_brurtle_100",@"com.games433.snackattack.catch_marshmeow_500",@"com.games433.snackattack.catch_marshmeow_1000",@"com.games433.snackattack.gold_marshmeow_100",@"com.games433.snackattack.catch_berry_bat_500",@"com.games433.snackattack.catch_berry_bat_1000",@"com.games433.snackattack.gold_berry_bat_100",@"com.games433.snackattack.catch_gummy_boar_500",@"com.games433.snackattack.catch_gummy_boar_1000",@"com.games433.snackattack.gold_gummy_boar_100",@"com.games433.snackattack.catch_ogrion_500",@"com.games433.snackattack.catch_ogrion_1000",@"com.games433.snackattack.gold_ogrion_100",@"com.games433.snackattack.catch_sloda_500",@"com.games433.snackattack.catch_sloda_1000",@"com.games433.snackattack.gold_sloda_100",@"com.games433.snackattack.catch_macaconda_500",@"com.games433.snackattack.catch_macaconda_1000",@"com.games433.snackattack.gold_macaconda_100",@"com.games433.snackattack.catch_ghost_pepper_500",@"com.games433.snackattack.catch_ghost_pepper_1000",@"com.games433.snackattack.gold_ghost_pepper_100",@"com.games433.snackattack.catch_butterfly_500",@"com.games433.snackattack.catch_butterfly_1000",@"com.games433.snackattack.gold_butterfly_100",@"com.games433.snackattack.catch_strawbee_500",@"com.games433.snackattack.catch_strawbee_1000",@"com.games433.snackattack.gold_strawbee_100",@"com.games433.snackattack.acquire_brurtle",@"com.games433.snackattack.acquire_marshmeow",@"com.games433.snackattack.acquire_berry_bat",@"com.games433.snackattack.acquire_gummy_boar",@"com.games433.snackattack.acquire_ogrion",@"com.games433.snackattack.acquire_sloda",@"com.games433.snackattack.acquire_macaconda",@"com.games433.snackattack.acquire_ghost_pepper",@"com.games433.snackattack.acquire_butterfly",@"com.games433.snackattack.acquire_strawbee",@"com.games433.snackattack.tutorial_complete",@"com.games433.snackattack.roster_all_24",@"com.games433.snackattack.roster_all_rare",@"com.games433.snackattack.roster_all_legendary",@"com.games433.snackattack.wild_common_first",@"com.games433.snackattack.wild_rare_first",@"com.games433.snackattack.wild_legendary_first",@"com.games433.snackattack.impulse_purchase",@"com.games433.snackattack.purchase_rare_first",@"com.games433.snackattack.purchase_legendary_first"]];
    if (![value isKindOfClass:NSString.class] || ![allowed containsObject:value]) {
        [self fail:command.callbackId code:@"INVALID_ACHIEVEMENT" message:@"Unknown Snack Attack achievement ID."];
        return;
    }
    [self reportCommand:command achievementID:value];
}
- (void)reportCommand:(CDVInvokedUrlCommand *)command achievementID:(NSString *)achievementID {
    dispatch_async(dispatch_get_main_queue(), ^{
        id value = command.arguments.count ? command.arguments[0] : nil;
        NSString *expected = [value isKindOfClass:NSString.class] ? value : @"";
        if (![self matchesPlayer:expected]) {
            [self fail:command.callbackId code:@"PLAYER_CHANGED" message:@"The pending achievement belongs to another or signed-out player."];
            return;
        }
        if (self.reporting) { [self fail:command.callbackId code:@"BUSY" message:@"A report is already pending."]; return; }
        self.reporting = YES;
        // Check Apple's state first: a retry/reinstall must not request a second completion banner.
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray<GKAchievement *> *achievements, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error || ![self matchesPlayer:expected]) {
                    self.reporting = NO;
                    [self fail:command.callbackId code:@"LOAD_FAILED" message:error.localizedDescription ?: @"Player changed."];
                    return;
                }
                for (GKAchievement *existing in achievements) {
                    if ([existing.identifier isEqualToString:achievementID] && existing.percentComplete >= 100.0) {
                        self.reporting = NO;
                        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                            messageAsDictionary:@{@"playerId":expected, @"alreadyComplete":@YES}] callbackId:command.callbackId];
                        return;
                    }
                }
                GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementID];
                achievement.percentComplete = 100.0;
                achievement.showsCompletionBanner = YES;
                [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *reportError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.reporting = NO;
                        if (![self matchesPlayer:expected]) [self fail:command.callbackId code:@"PLAYER_CHANGED" message:@"Player changed during reporting; retry required."];
                        else if (reportError) [self fail:command.callbackId code:@"REPORT_FAILED" message:reportError.localizedDescription];
                        else [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                            messageAsDictionary:@{@"playerId":expected, @"alreadyComplete":@NO}] callbackId:command.callbackId];
                    });
                }];
            });
        }];
    });
}
@end

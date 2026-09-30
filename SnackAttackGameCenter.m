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
                              @"pluginVersion":@"1.0.0"}] callbackId:callback];
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
                    if ([existing.identifier isEqualToString:SAImpulseID] && existing.percentComplete >= 100.0) {
                        self.reporting = NO;
                        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                            messageAsDictionary:@{@"playerId":expected, @"alreadyComplete":@YES}] callbackId:command.callbackId];
                        return;
                    }
                }
                GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:SAImpulseID];
                achievement.percentComplete = 100.0;
                achievement.showsCompletionBanner = YES;
                [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *reportError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.reporting = NO;
                        if (reportError) [self fail:command.callbackId code:@"REPORT_FAILED" message:reportError.localizedDescription];
                        else [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                            messageAsDictionary:@{@"playerId":expected, @"alreadyComplete":@NO}] callbackId:command.callbackId];
                    });
                }];
            });
        }];
    });
}
@end

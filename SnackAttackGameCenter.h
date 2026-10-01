#import <Cordova/CDVPlugin.h>
#import <GameKit/GameKit.h>

@interface SnackAttackGameCenter : CDVPlugin
@property(nonatomic, strong) NSMutableArray<NSString *> *authCallbacks;
@property(nonatomic, assign) BOOL reporting;
- (void)auth:(CDVInvokedUrlCommand *)command;
- (void)status:(CDVInvokedUrlCommand *)command;
- (void)completeImpulsePurchase:(CDVInvokedUrlCommand *)command;
- (void)completeAchievement:(CDVInvokedUrlCommand *)command;
- (void)reportCommand:(CDVInvokedUrlCommand *)command achievementID:(NSString *)achievementID;
@end

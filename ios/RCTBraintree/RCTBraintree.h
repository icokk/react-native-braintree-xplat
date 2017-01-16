//
//  RCTBraintree.h
//  RCTBraintree
//
//  Created by Rickard Ekman on 18/06/16.
//  Copyright © 2016 Rickard Ekman. All rights reserved.
//

#import "RCTBridgeModule.h"
#import "BraintreeCore.h"
#import "BraintreePayPal.h"
#import "BraintreeCard.h"
#import "BraintreeUI.h"
#import "Braintree3DSecure.h"

typedef void (^Callback_block)(NSString *callbackNonce);

@interface RCTBraintree : UIViewController <RCTBridgeModule, BTDropInViewControllerDelegate, BTViewControllerPresentingDelegate>

@property (nonatomic, strong) BTAPIClient *braintreeClient;
@property (nonatomic, strong) UIViewController *reactRoot;
@property NSString *clientToken;
@property (copy, nonatomic) Callback_block callbackNonce;
@property (nonatomic, strong) RCTResponseSenderBlock callback;

+ (instancetype)sharedInstance;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
-(void)tokenizeAndVerifyNat:(NSString *)cardNumber expirationMonth:(NSString *)expirationMonth expirationYear:(NSString *)expirationYear cvv:(NSString *)cvv amountNumber:(NSNumber * _Nonnull)amountNumber verify:(BOOL)verify clientToken:(NSString *)clientToken callback:(void (^)(NSString *result))completionHandler;

@end

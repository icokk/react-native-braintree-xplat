//
//  RCTBraintree.m
//  RCTBraintree
//
//  Created by Rickard Ekman on 18/06/16.
//  Copyright © 2016 Rickard Ekman. All rights reserved.
//

#import "RCTBraintree.h"
#import "RCTUtils.h"
#import "RCTConvert.h"

@implementation RCTBraintree

static NSString *URLScheme;

+ (instancetype)sharedInstance {
    static RCTBraintree *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RCTBraintree alloc] init];
    });
    return _sharedInstance;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setupWithURLScheme:(NSString *)clientToken urlscheme:(NSString*)urlscheme callback:(RCTResponseSenderBlock)callback)
{
    URLScheme = urlscheme;
    [BTAppSwitch setReturnURLScheme:urlscheme];
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
    if (self.braintreeClient == nil) {
        callback(@[@false]);
    }
    else {
        callback(@[@true]);
    }
}

RCT_EXPORT_METHOD(setup:(NSString *)clientToken callback:(RCTResponseSenderBlock)callback)
{
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
    if (self.braintreeClient == nil) {
        callback(@[@false]);
    }
    else {
        callback(@[@true]);
    }
}

RCT_EXPORT_METHOD(showPaymentViewController:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BTDropInViewController *dropInViewController = [[BTDropInViewController alloc] initWithAPIClient:self.braintreeClient];
        dropInViewController.delegate = self;
        
        NSLog(@"%@", options);
        
        UIColor *tintColor = options[@"tintColor"];
        UIColor *bgColor = options[@"bgColor"];
        UIColor *barBgColor = options[@"barBgColor"];
        UIColor *barTintColor = options[@"barTintColor"];
        
        if (tintColor) dropInViewController.view.tintColor = [RCTConvert UIColor:tintColor];
        if (bgColor) dropInViewController.view.backgroundColor = [RCTConvert UIColor:bgColor];
        
        dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(userDidCancelPayment)];
        
        self.callback = callback;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
        
        if (barBgColor) navigationController.navigationBar.barTintColor = [RCTConvert UIColor:barBgColor];
        if (barTintColor) navigationController.navigationBar.tintColor = [RCTConvert UIColor:barTintColor];
        
        self.reactRoot = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [self.reactRoot presentViewController:navigationController animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(showPayPalViewController:(RCTResponseSenderBlock)callback)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.braintreeClient];
        payPalDriver.viewControllerPresentingDelegate = self;
        
        [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
            NSArray *args = @[];
            if ( error == nil ) {
                args = @[[NSNull null], tokenizedPayPalAccount.nonce];
            } else {
                args = @[error.description, [NSNull null]];
            }
            callback(args);
        }];
    });
}

RCT_EXPORT_METHOD(getCardNonce: (NSString *)cardNumber
                  expirationMonth: (NSString *)expirationMonth
                  expirationYear: (NSString *)expirationYear
                  callback: (RCTResponseSenderBlock)callback
                  )
{
    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient: self.braintreeClient];
    BTCard *card = [[BTCard alloc] initWithNumber:cardNumber expirationMonth:expirationMonth expirationYear:expirationYear cvv:nil];
    
    [cardClient tokenizeCard:card
                  completion:^(BTCardNonce *tokenizedCard, NSError *error) {
                      
                      NSArray *args = @[];
                      if ( error == nil ) {
                          args = @[[NSNull null], tokenizedCard.nonce];
                      } else {
                          args = @[error.description, [NSNull null]];
                      }
                      callback(args);
                  }
    ];
}

RCT_EXPORT_METHOD(verify3DSecure: (NSString *)paymentNonce
                  amount: (NSString *)amount
                  callback: (RCTResponseSenderBlock)callback
                  )
{
    NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithString:amount];
    BTThreeDSecureDriver *threeDSecureDriver = [[BTThreeDSecureDriver alloc] init];
    [threeDSecureDriver verifyCardWithNonce:paymentNonce
                                     amount:amountNum
                                 completion:^(BTThreeDSecureCardNonce *card, NSError *error){

                                      NSArray *args = @[];
                                      if ( error == nil ) {
                                          if ( card ) {
                                              args = @[[NSNull null], card.nonce];
                                          } else {
                                              args = @[[NSNull null], [NSNull null]];
                                          }
                                      } else {
                                          args = @[error.description, [NSNull null]];
                                      }
                                      callback(args);
                                  }
    ];
}

RCT_EXPORT_METHOD(tokenizeCardAndVerify: (NSString *)cardNumber
                  expirationMonth: (NSString *)expirationMonth
                  expirationYear: (NSString *)expirationYear
                  cvv: (NSString *)cvv
                  amount: (NSString *)amount
                  verify: (bool)verify
                  callback: (RCTResponseSenderBlock)callback
                  )
{
    NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithString:amount];
    BTThreeDSecureDriver *threeDSecureDriver = [[BTThreeDSecureDriver alloc] init];
    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient: self.braintreeClient];
    BTCard *card = [[BTCard alloc] initWithNumber:cardNumber expirationMonth:expirationMonth expirationYear:expirationYear cvv:cvv];

    [cardClient tokenizeCard:card
                  completion:^(BTCardNonce *tokenizedCard, NSError *error) {
                      
                      NSArray *args = @[];
                      if ( error == nil ) {
                          if ( tokenizedCard ) {
                              [threeDSecureDriver verifyCardWithNonce:tokenizedCard.nonce
                                                               amount:amountNum
                                                           completion:^(BTThreeDSecureCardNonce *secureCard, NSError *error) {
                                                                    if ( error == nil ) {
                                                                        if ( secureCard ) {
                                                                            args = @[[NSNull null], secureCard.nonce];
                                                                        } else {
                                                                            args = @[[NSNull null], [NSNull null]];
                                                                        }
                                                                    } else {
                                                                        args = @[error.description, [NSNull null]];
                                                                    }
                              }];
                          } else {
                              args = @[[NSNull null], [NSNull null]]
                          }
                      } else {
                          args = @[error.description, [NSNull null]];
                      }
                      callback(args);
                  }
     ];
}

RCT_EXPORT_METHOD(payWithPayPal: (NSString *)amount
                  currency: (NSString *)currency
                  callback: (RCTResponseSenderBlock)callback
                  )
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.braintreeClient];
        BTPayPalRequest *request = [[BTPayPalRequest alloc] initWithAmount:amount];
        request.currencyCode = currency;
        
        [payPalDriver requestOneTimePayment:request
                                 completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError *error) {

                                  NSArray *args = @[];
                                  if ( error == nil ) {
                                      if ( tokenizedPayPalAccount ) {
                                          args = @[[NSNull null], tokenizedPayPalAccount.nonce];
                                      } else {
                                          args = @[[NSNull null], [NSNull null]];
                                      }
                                  } else {
                                      args = @[error.description, [NSNull null]];
                                  }
                                  callback(args);
                              }
        ];
    });
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.scheme localizedCaseInsensitiveCompare:URLScheme] == NSOrderedSame) {
        return [BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication];
    }
    return NO;
}

#pragma mark - BTViewControllerPresentingDelegate

- (void)paymentDriver:(id)paymentDriver requestsPresentationOfViewController:(UIViewController *)viewController {
    self.reactRoot = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [self.reactRoot presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(id)paymentDriver requestsDismissalOfViewController:(UIViewController *)viewController {
    self.reactRoot = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [self.reactRoot dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BTDropInViewControllerDelegate

- (void)userDidCancelPayment {
    [self.reactRoot dismissViewControllerAnimated:YES completion:nil];
    self.callback(@[@"User cancelled payment", [NSNull null]]);
}

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce {
    
    self.callback(@[[NSNull null],paymentMethodNonce.nonce]);
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.callback(@[@"Drop-In ViewController Closed", [NSNull null]]);
}

@end

#import "CreditCardUI.h"
#import "CreditCardUIView.h"
#import "RCTBraintree.h"
#import "CreditCardType.h"
#import "RCTBridgeModule.h"


@implementation CreditCardUI

RCT_EXPORT_MODULE(RCTCreditCardUI);

@synthesize bridge = _bridge;

-(UIView*) view {
    
    CreditCardUIView *v = [[CreditCardUIView alloc] init];
    [v initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    return v;
}




RCT_EXPORT_VIEW_PROPERTY(requiredCard, NSString);
RCT_EXPORT_VIEW_PROPERTY(require3dSecure, BOOL);
RCT_EXPORT_VIEW_PROPERTY(requireCVV, BOOL);
RCT_EXPORT_VIEW_PROPERTY(hidePayButton, BOOL);
RCT_EXPORT_VIEW_PROPERTY(amount, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(clientToken, NSString);
RCT_EXPORT_VIEW_PROPERTY(onNonceReceived, RCTBubblingEventBlock);




@end

#import "CreditCardUI.h"
#import "CreditCardUIView.h"
#import "RCTBraintree.h"
#import "CreditCardType.h"
#import "RCTBridgeModule.h"
#import "CreditCardUIView.h"

@implementation CreditCardUI{
    CreditCardUIView *rctView;

}

RCT_EXPORT_MODULE(RCTCreditCardUI);

@synthesize bridge = _bridge;

-(UIView*) view {
    rctView = [[CreditCardUIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    return rctView;
}

RCT_EXPORT_VIEW_PROPERTY(requiredCard, NSString);
RCT_EXPORT_VIEW_PROPERTY(require3dSecure, BOOL);
RCT_EXPORT_VIEW_PROPERTY(requireCVV, BOOL);
RCT_EXPORT_VIEW_PROPERTY(hidePayButton, BOOL);
RCT_EXPORT_VIEW_PROPERTY(amount, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(clientToken, NSString);
RCT_EXPORT_VIEW_PROPERTY(onNonceReceived, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(iconFont, NSString);
RCT_EXPORT_VIEW_PROPERTY(iconGlyph, NSString);
RCT_EXPORT_VIEW_PROPERTY(showIcon, BOOL);

RCT_EXPORT_VIEW_PROPERTY(focusColor, NSInteger);
RCT_EXPORT_VIEW_PROPERTY(blurColor, NSInteger);
RCT_EXPORT_VIEW_PROPERTY(errorColor, NSInteger);

RCT_EXPORT_VIEW_PROPERTY(translations, NSDictionary);

RCT_EXPORT_METHOD(submitCardData:(nonnull NSNumber *)reactTag)
{
    [rctView executePayment];
}

@end

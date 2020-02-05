#import <UIKit/UIKit.h>
#import <React/RCTView.h>
#import "CreditCardType.h"
#import "CreditCardUI.h"
#import "IconTextField.h"
#import "RCTBraintree.h"

@interface CreditCardUIView : RCTView

@property (nonatomic, readonly) UIView *backgroundView;

@property IconTextField *ccNumberField;
@property IconTextField *cvvField;
@property IconTextField *monthField;
@property IconTextField *yearField;

@property UIButton *submitButton;
@property UIActivityIndicatorView *activityIndicator;

@property RCTBraintree *rctBraintree;

//props
@property BOOL requireCVV;
@property BOOL hidePayButton;
@property NSString *requiredCard;
@property RCTBubblingEventBlock onNonceReceived;
@property BOOL require3dSecure;
@property NSString *clientToken;
@property NSNumber* amount;

@property NSDictionary* translations;

@property NSString *iconFont;
@property NSString *iconGlyph;
@property BOOL showIcon;

// colors
@property NSInteger focusColor;
@property NSInteger blurColor;
@property NSInteger errorColor;


-(NSString *)getRequiredCard;
-(void)setRequiredCardName:(NSString*) requiredCard;

-(BOOL)isRequireCVV;
-(void)setRequireCVV:(BOOL)requireCVV;
-(void)setHidePayButton:(BOOL)hidePayButton;
-(BOOL)isHidePayButton;

-(NSNumber *)getAmount;
-(void)setAmount:(NSNumber*) amount;

-(BOOL)validateAndSubmit;
-(void)executePayment;



@end

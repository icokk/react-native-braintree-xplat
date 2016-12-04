#import <UIKit/UIKit.h>
#import "RCTView.h"
#import "CreditCardType.h"

#import "CreditCardUI.h"

#import "MDTextField.h"
#import "MDButton.h"

@interface CreditCardUIView : RCTView

@property (nonatomic, readonly) UIView *backgroundView;

@property MDTextField *ccNumber;
@property MDTextField *expMonth;
@property MDTextField *expYear;
@property MDTextField *cvvNumber;
@property MDButton *submitButton;

@property BOOL requireCVV;
@property BOOL hidePayButton;
@property CreditCardType *requiredCard;
@property NSString *requiredCardName;
@property RCTBubblingEventBlock onNonceReceived;
@property BOOL require3dSecure;

@property NSString *clientToken;

@property (nonatomic, readonly) NSLayoutConstraint *backgroundViewVerticalCenteringConstraint;


-(CreditCardType *)getRequiredCard;
-(void)setRequiredCard:(CreditCardType*) requiredCard;
-(BOOL)isRequireCVV;
-(void)setRequireCVV:(BOOL)requireCVV;
-(void)setHidePayButton:(BOOL)hidePayButton;
-(BOOL)isHidePayButton;

@property NSNumber* amount;
-(NSNumber *)getAmount;
-(void)setAmount:(NSNumber*) amount;

-(NSString*)getRequiredCardName;
-(void)setRequiredCardName:(NSString *)requiredCard;

-(BOOL)validateAndSubmit;
@end

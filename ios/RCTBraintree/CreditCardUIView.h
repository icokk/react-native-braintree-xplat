#import <UIKit/UIKit.h>
#import "RCTView.h"
#import "CreditCardType.h"

#import "CreditCardUI.h"


@interface CreditCardUIView : RCTView

@property (nonatomic, readonly) UIView *backgroundView;
@property UITextField *ccNumber;
@property UITextField *expMonth;
@property UITextField *expYear;
@property UITextField *cvvNumber;
@property UIButton *submitButton;
@property UIButton *fillButton;

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

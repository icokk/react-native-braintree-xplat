#import "CreditCardUIView.h"
#import "Validity.h"
#import "ValidatorUtils.h"
#import "CardNumberMatch.h"
#import "CreditCardValidator.h"
#import "DateValidity.h"
#import "DateValidator.h"

#import "CreditCardUI.h"

#import "RCTBraintree.h"
#import "MDTextField.h"

typedef enum
{
    Number,
    CVV,
    Month,
    Year
} ControlType;


@interface CreditCardUIView ()

@property (nonatomic, strong) BTAPIClient *braintreeClient;

@end

@implementation CreditCardUIView

// View and some property initialization
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.requireCVV = YES;
        self.hidePayButton = NO;
        self.requiredCard = NULL;
        self.require3dSecure = NO;
        
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.backgroundView.layer.cornerRadius = 6.0f;
        [self addSubview:_backgroundView];
        
        //        _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 250, 200, 30)];
        //        self.submitButton.backgroundColor = [UIColor darkGrayColor];
        //        [self.submitButton setTitle:@"Pay" forState:UIControlStateNormal];
        ////        [self.submitButton setTitle:@"Changed" forState:UIControlStateHighlighted];
        //        [self.submitButton addTarget:self action:@selector(payButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.submitButton setHidden:(self.hidePayButton) ? YES : NO];
        //        [self.submitButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
        //        [self.submitButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.backgroundView addSubview:self.submitButton];
        //
        
        //
        
        _ccNumber = [[MDTextField alloc] init];
        [self.ccNumber setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.ccNumber.label = @"Credit card number";
        self.ccNumber.floatingLabel = YES;
        self.ccNumber.textColor = [UIColor blackColor];
        self.ccNumber.highlightColor = [UIColor colorWithRed:0.93 green:0.17 blue:0.45 alpha:1.0];//#ee2b74;
        self.ccNumber.keyboardType = UIKeyboardTypeNumberPad;
        self.ccNumber.hasError = NO;
        self.ccNumber.errorMessage = @"Invalid credit card number";
        self.ccNumber.errorColor = [UIColor redColor];
        [self.backgroundView addSubview:self.ccNumber];
        
        _expMonth = [[MDTextField alloc] init];
        [self.expMonth setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.expMonth.label = @"Month(MM)";
        self.expMonth.floatingLabel = YES;
        self.expMonth.textColor = [UIColor blackColor];
        self.expMonth.highlightColor = [UIColor colorWithRed:0.93 green:0.17 blue:0.45 alpha:1.0];//#ee2b74;
        self.expMonth.keyboardType = UIKeyboardTypeNumberPad;
        self.expMonth.hasError = NO;
        self.expMonth.errorMessage = @"Invalid date or expired card";
        self.expMonth.errorColor = [UIColor redColor];
        [self.backgroundView addSubview:self.expMonth];
        
        _expYear = [[MDTextField alloc] init];
        [self.expYear setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.expYear.label = @"Year(YYYY)";
        self.expYear.floatingLabel = YES;
        self.expYear.textColor = [UIColor blackColor];
        self.expYear.highlightColor = [UIColor colorWithRed:0.93 green:0.17 blue:0.45 alpha:1.0];//#ee2b74;
        self.expYear.keyboardType = UIKeyboardTypeNumberPad;
        self.expYear.hasError = NO;
        self.expYear.errorMessage = @"Invalid date or expired card";
        self.expYear.errorColor = [UIColor redColor];
        [self.backgroundView addSubview:self.expYear];
        
        _cvvNumber = [[MDTextField alloc] init];
        [self.cvvNumber setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.cvvNumber.label = @"CVV";
        self.cvvNumber.floatingLabel = YES;
        self.cvvNumber.textColor = [UIColor blackColor];
        self.cvvNumber.highlightColor = [UIColor colorWithRed:0.93 green:0.17 blue:0.45 alpha:1.0];//#ee2b74;
        self.cvvNumber.keyboardType = UIKeyboardTypeNumberPad;
        self.cvvNumber.hasError = NO;
        self.cvvNumber.errorMessage = @"Invalid control code, it must contain 3 or 4 digits";
        self.cvvNumber.errorColor = [UIColor redColor];
        [self.backgroundView addSubview:self.cvvNumber];
        
        _submitButton = [[MDButton alloc] init];
        [self.submitButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.submitButton.backgroundColor = [UIColor colorWithRed:0.93 green:0.17 blue:0.45 alpha:1.0];//#ee2b74;
        //        self.submitButton.type = 1;
        [self.submitButton setTitle:@"Pay" forState:UIControlStateNormal];
        [self.submitButton addTarget:self action:@selector(payButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.submitButton setHidden:(self.hidePayButton) ? YES : NO];
        [self.backgroundView addSubview:self.submitButton];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_ccNumber, _expMonth, _expYear, _cvvNumber, _submitButton);
        
        //        NSArray *submitButton_Height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_submitButton(redHeight)]"
        //                                                                            options:0
        //                                                                            metrics:nil
        //                                                                              views:viewsDictionary];
        //
        //        [self.submitButton addConstraint:submitButton_Height];
        
        NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_ccNumber]-[_expMonth]-[_expYear]-[_cvvNumber]-(40)-[_submitButton]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        
        NSArray *cc_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_ccNumber]-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
        
        NSArray *month_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_expMonth]-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];
        
        NSArray *monthYear_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_expMonth]-(10)-[_expYear]-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsDictionary];
        
        NSArray *year_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_expYear]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary];
        
        NSArray *cvv_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cvvNumber]-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:viewsDictionary];
        
        NSArray *submit_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_submitButton]-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
        
        [self.backgroundView addConstraints:constraint_POS_V];
        [self.backgroundView addConstraints:cc_POS_H];
        [self.backgroundView addConstraints:month_POS_H];
        [self.backgroundView addConstraints:year_POS_H];
        [self.backgroundView addConstraints:cvv_POS_H];
        [self.backgroundView addConstraints:submit_POS_H];
        
        
    }
    return self;
}



// Pay button is clicked
-(void)buttonHighlight:(UIButton *)sender
{
    self.submitButton.backgroundColor = [UIColor lightGrayColor];
}
// Pay button is clicked
-(void)buttonNormal:(UIButton *)sender
{
    self.submitButton.backgroundColor = [UIColor darkGrayColor];
}

-(void)payButtonSelected:(UIButton *)sender
{
    //TODO - try->catch->exception
    if([self validateAndSubmit])
        [[RCTBraintree alloc] tokenizeAndVerifyNat:self.ccNumber.text expirationMonth:self.expMonth.text expirationYear:self.expYear.text cvv:self.cvvNumber.text amountNumber:self.amount verify:self.require3dSecure clientToken:self.clientToken callback:^(NSString *nonce){
            NSLog(@" %@ ", nonce);
            self.onNonceReceived(@{@"nonce":  nonce});
        }];
}

// Editing changed
-(void) cvvEditingChanged:(id)sender {
    self.cvvNumber.textColor = [UIColor darkGrayColor];
}
-(void) ccEditingChanged:(id)sender {
    self.ccNumber.textColor = [UIColor darkGrayColor];
}
-(void) monthEditingChanged:(id)sender {
    self.expMonth.textColor = [UIColor darkGrayColor];
}
-(void) yearEditingChanged:(id)sender {
    self.expYear.textColor = [UIColor darkGrayColor];
}


//-(void)submit
//{
//    NSString *number = self.ccNumber.text;
//    NSString *cvv = self.requireCVV ? self.cvvNumber.text : NULL;
//    DateValidity *dv = [[DateValidator alloc] validateDate:self.expMonth.text withYear:self.expYear.text];
//    NSString *month = [NSString stringWithFormat: @"%02d", dv.getMonth];
//    NSString *year = [NSString stringWithFormat: @"%02d", dv.getYear];
//}

-(BOOL)validateAndSubmit
{
    Validity validity = [self validate:YES];
    if(validity == Complete)
    {
        //        [self submit];
        return YES;
    } else {
        return NO;
    }
}

-(Validity)validate:(BOOL)submit
{
    Validity validity = Complete;
    validity = MIN(validity, [self validateNumber:submit]);
    validity = MIN(validity, [self validateCCV:submit]);
    validity = MIN(validity, [self validateDate:submit]);
    return validity;
}

-(Validity)validateNumber:(BOOL)submit
{
    CardNumberMatch *ccmatch = [[CreditCardValidator alloc] detectCard:self.ccNumber.text];
    Validity validity = ccmatch.getValidity;
    if( self.requiredCard != NULL && self.requiredCard != ccmatch.getCardType)
        validity = Invalid;
    [self markField:Number withValidity:validity with:submit];
    return validity;
}

-(Validity)validateCCV:(BOOL)submit
{
    CreditCardType *cardType = _requiredCard;
    if(_requiredCard == NULL)
        cardType = [[CreditCardValidator alloc] detectCard:self.ccNumber.text].getCardType;
    
    Validity validity = [[CreditCardValidator alloc] validateCVC:self.cvvNumber.text withCreditCardType:cardType];
    
    [self markField:CVV withValidity:validity with:submit];
    return validity;
}

-(Validity)validateDate:(BOOL)submit
{
    DateValidity *dv = [[DateValidator alloc] validateDate:self.expMonth.text withYear:self.expYear.text];
    
    [self markField:Month withValidity:dv.validity with:submit];
    [self markField:Year withValidity:dv.validity with:submit];
    
    return dv.validity;
}

-(void)markField:(ControlType)control withValidity:(Validity)validity with:(BOOL)submit
{
    if(validity == Invalid || (submit && validity == Partial))
    {
        [self setError:control with:[self getErrorMessage: control with:validity]];
    }
    //    else {
    //        [self setError:control with:NULL];
    //    }
}

-(void)setError:(ControlType*)control with:(NSString*)message
{
    if(control == Number)
        self.ccNumber.textColor = [UIColor redColor];
    if(control == CVV)
        self.cvvNumber.textColor = [UIColor redColor];
    if(control == Month)
        self.expMonth.textColor = [UIColor redColor];
    if(control == Year)
        self.expYear.textColor = [UIColor redColor];
}

-(NSString*)getErrorMessage:(ControlType*)control with:(Validity)validity
{
    if(control == Number)
        return @"Invalid credit card number";
    if(control == CVV)
        return @"Invalid control code, it must contain 3 or 4 digits";
    if(control == Month)
        return @"Invalid date or expired card";
    return @" ";
}


-(CreditCardType *)getRequiredCard
{
    return _requiredCard;
}

-(void)setRequiredCard:(CreditCardType*) requiredCard
{
    _requiredCard = requiredCard;
}

-(BOOL)isRequireCVV
{
    return _requireCVV;
}

-(void)setRequireCVV:(BOOL)requireCVV
{
    _requireCVV = requireCVV;
    if (self.cvvNumber != NULL)
        [self.cvvNumber setHidden:(self.requireCVV) ? NO : YES];
}

-(void)setHidePayButton:(BOOL)hidePayButton
{
    _hidePayButton = hidePayButton;
    if ( self.submitButton != NULL )
        [self.submitButton setHidden:(self.hidePayButton) ? YES : NO];
}

-(BOOL)isHidePayButton
{
    return _hidePayButton;
}


-(NSNumber *)getAmount
{
    return _amount;
}

-(void)setAmount:(NSNumber*) amount
{
    _amount = amount;
}


-(NSString*)getRequiredCardName
{
    CreditCardType *card = [[CreditCardUIView alloc] getRequiredCard];
    return card == NULL ? NULL : card.getName;
}

-(void)setRequiredCardName:(NSString *)requiredCardName
{
    return [self setRequiredCard:[[CreditCardType alloc] byName:requiredCardName]];
}


-(NSString *)getClientToken
{
    return _clientToken;
}

-(void)setClientToken:(NSString *)clientToken
{
    _clientToken = clientToken;
}

-(BOOL)isRequire3dSecure
{
    return _require3dSecure;
}

-(void)setRequire3dSecure:(BOOL)require3dSecure
{
    _require3dSecure = require3dSecure;
}

@end

#import "CreditCardUIView.h"
#import "Validity.h"
#import "ValidatorUtils.h"
#import "CardNumberMatch.h"
#import "CreditCardValidator.h"
#import "DateValidity.h"
#import "DateValidator.h"

#import "CreditCardUI.h"

#import "RCTBraintree.h"

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
        
//        self.maximumWidth = 480.0f;
        
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        [self.backgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
        self.backgroundView.layer.cornerRadius = 6.0f;
        [self addSubview:_backgroundView];
        
        _ccNumber = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 30)];
        self.ccNumber.borderStyle = UITextBorderStyleRoundedRect;
        self.ccNumber.textColor = [UIColor darkGrayColor];
        self.ccNumber.keyboardType = UIKeyboardTypeNumberPad;
        self.ccNumber.placeholder = @"Credit Card Number";
        [self.ccNumber addTarget:self action:@selector(ccEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.backgroundView addSubview:self.ccNumber];

        _expMonth = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, 90, 30)];
        self.expMonth.borderStyle = UITextBorderStyleRoundedRect;
        self.expMonth.textColor = [UIColor darkGrayColor];
        self.expMonth.keyboardType = UIKeyboardTypeNumberPad;
        self.expMonth.placeholder = @"Month";
        [self.expMonth addTarget:self action:@selector(monthEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.backgroundView addSubview:self.expMonth];
        
        _expYear = [[UITextField alloc] initWithFrame:CGRectMake(150, 150, 90, 30)];
        self.expYear.borderStyle = UITextBorderStyleRoundedRect;
        self.expYear.textColor = [UIColor darkGrayColor];
        self.expYear.keyboardType = UIKeyboardTypeNumberPad;
        self.expYear.placeholder = @"Year";
        [self.expYear addTarget:self action:@selector(yearEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.backgroundView addSubview:self.expYear];
        
        _cvvNumber = [[UITextField alloc] initWithFrame:CGRectMake(50, 200, 90, 30)];
        self.cvvNumber.borderStyle = UITextBorderStyleRoundedRect;
        self.cvvNumber.textColor = [UIColor darkGrayColor];
        self.cvvNumber.keyboardType = UIKeyboardTypeNumberPad;
        self.cvvNumber.placeholder = @"CVV";
        [self.cvvNumber addTarget:self action:@selector(cvvEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.cvvNumber setHidden:(self.requireCVV) ? NO : YES];
        [self.backgroundView addSubview:self.cvvNumber];

        _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 250, 200, 30)];
        self.submitButton.backgroundColor = [UIColor darkGrayColor];
        [self.submitButton setTitle:@"Pay" forState:UIControlStateNormal];
//        [self.submitButton setTitle:@"Changed" forState:UIControlStateHighlighted];
        [self.submitButton addTarget:self action:@selector(payButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.submitButton setHidden:(self.hidePayButton) ? YES : NO];
        [self.submitButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
        [self.submitButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundView addSubview:self.submitButton];
        
        _fillButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 300, 200, 30)];
        self.fillButton.backgroundColor = [UIColor grayColor];
        [self.fillButton setTitle:@"Fill" forState:UIControlStateNormal];
//        [self.fillButton setTitle:@"Changed" forState:UIControlStateHighlighted];
        [self.fillButton addTarget:self action:@selector(fillform:) forControlEvents:UIControlEventTouchUpInside];
        [self.fillButton setHidden:YES];
        [self.backgroundView addSubview:self.fillButton];
    }

    return self;
}

// Fill button is clicked
-(void)fillform:(UIButton *)sender
{
    self.ccNumber.text = @"5555555555554444";
    self.expMonth.text = @"12";
    self.expYear.text = @"2038";
    self.cvvNumber.text = @"123";
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

#import "CreditCardUIView.h"
#import "Validity.h"
#import "ValidatorUtils.h"
#import "CardNumberMatch.h"
#import "CreditCardValidator.h"
#import "DateValidity.h"
#import "DateValidator.h"
#import "CreditCardUI.h"
#import "RCTBraintree.h"
#import "IconTextField.h"
#import "CreditCardType.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];

typedef enum
{
    Number,
    CVV,
    Month,
    Year
} ControlType;

#define MONTH_MAX_LENGTH 2;
#define YEAR_MAX_LENGTH 4;
#define CARD_MAX_LENGTH 19;
#define CVV_MAX_LENGTH 4;

@interface CreditCardUIView (){
    CreditCardType *ccType;
    NSString *numberString;
    NSString *cvvString;
    NSString *monthString;
    NSString *yearString;
    NSString *invalidString;
}

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
        numberString = @"Credit card number";
        cvvString = @"CVV/CVC";
        monthString = @"Month(MM)";
        yearString = @"Year(YYYY)";
        invalidString = @"Invalid";
        
        self.iconFont = @"";
        self.iconGlyph = @"";
        self.showIcon = YES;
        
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        [self addSubview:_backgroundView];
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _ccNumberField = [[IconTextField alloc] init:width];
        self.ccNumberField.placeholderText = [self getNumberString];
        self.ccNumberField.textField.delegate = self;
        self.ccNumberField.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.ccNumberField.hasIcon = self.showIcon;
        self.ccNumberField.errorMessageLabelText = [self getInvalidString];
        self.ccNumberField.hasError = NO;
        self.ccNumberField.iconLabelFontString = [self getIconFont];
        self.ccNumberField.iconLabelText = [self getIconGlyph];
        
        [self.ccNumberField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.ccNumberField.textField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [self.backgroundView addSubview:self.ccNumberField];

        
        _cvvField = [[IconTextField alloc] init:width];
        self.cvvField.placeholderText = [self getCvvString];
        self.cvvField.textField.delegate = self;
        self.cvvField.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.cvvField.hasIcon = NO;

        self.cvvField.hideComponent = !self.requireCVV;
        
        self.cvvField.errorMessageLabelText = [self getInvalidString];
        self.cvvField.hasError = NO;
        [self.cvvField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.cvvField.textField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [self.backgroundView addSubview:self.cvvField];
        
        
        CGFloat widthH = width/2;
        _monthField = [[IconTextField alloc] init:widthH];
        self.monthField.placeholderText = [self getMonthString];
        self.monthField.textField.delegate = self;
        self.monthField.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.monthField.hasIcon = NO;
        self.monthField.errorMessageLabelText = [self getInvalidString];
        self.monthField.hasError = NO;
        self.monthField.textField.text = @"";
        [self.monthField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.monthField.textField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [self.monthField.textField addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [self.backgroundView addSubview:self.monthField];
        
        
        _yearField = [[IconTextField alloc] init:widthH];
        self.yearField.placeholderText = [self getYearString];
        self.yearField.textField.delegate = self;
        self.yearField.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.yearField.hasIcon = NO;
        self.yearField.errorMessageLabelText = [self getInvalidString];
        self.yearField.hasError = NO;
        self.yearField.textField.text = @"";
        [self.yearField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.yearField.textField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [self.yearField.textField addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [self.backgroundView addSubview:self.yearField];

        _submitButton = [[UIButton alloc] init];
        [self.submitButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.submitButton.backgroundColor = [UIColor colorWithRed:0.93 green:0.17 blue:0.45 alpha:1.0];//#ee2b74;
        [self.submitButton setTitle: @"Pay" forState:UIControlStateNormal];
        [self.submitButton addTarget:self action:@selector(payButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundView addSubview:self.submitButton];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.activityIndicator.alpha = 1.0;
        self.activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.backgroundView addSubview:self.activityIndicator];
        
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_ccNumberField, _cvvField, _monthField, _yearField, _submitButton, _activityIndicator);
        NSDictionary *metrics = @{@"vSpacing":@(widthH)};

        NSArray *pos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[_ccNumberField]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        NSArray *pos_v2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(128)-[_cvvField]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary];
        NSArray *submit_pos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(193)-[_submitButton]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewsDictionary];
        NSArray *pos_v3 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(64)-[_monthField]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewsDictionary];

        NSArray *pos_v4 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(64)-[_yearField]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewsDictionary];
        NSArray *spinnerView_pos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(128)-[_activityIndicator]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary];
        NSArray *pos_h_cc = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_ccNumberField]-(0)-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary];
        NSArray *pos_h_ccv = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_cvvField]-(0)-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary];
        NSArray *pos_h_month = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_monthField]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:viewsDictionary];
        NSArray *pos_h_year = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_yearField]-(vSpacing)-|"
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:viewsDictionary];
        NSArray *submit_pos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_submitButton]-(0)-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
        NSArray *spinnerView_pos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_activityIndicator]-|"
                                                                            options:0
                                                                            metrics:nil
                                                                               views:viewsDictionary];
    
        [self.backgroundView addConstraints:pos_v];
        [self.backgroundView addConstraints:pos_v2];
        [self.backgroundView addConstraints:pos_v3];
        [self.backgroundView addConstraints:pos_v4];
        [self.backgroundView addConstraints:pos_h_cc];
        [self.backgroundView addConstraints:pos_h_ccv];
        [self.backgroundView addConstraints:pos_h_month];
        [self.backgroundView addConstraints:pos_h_year];
        [self.backgroundView addConstraints:submit_pos_h];
        [self.backgroundView addConstraints:submit_pos_v];
        [self.backgroundView addConstraints:spinnerView_pos_h];
        [self.backgroundView addConstraints:spinnerView_pos_v];

    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.backgroundView endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
//    if(textField == self.monthField.textField || textField == self.yearField.textField)
//    {
//        self.monthField.hasError = NO;
//        self.yearField.hasError = NO;
//        self.monthField.dividerLine.backgroundColor = self.monthField.dividerLineHighlightColor;
//        self.yearField.dividerLine.backgroundColor = self.yearField.dividerLineHighlightColor;
//    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.ccNumberField.textField)
         [self validateNumber:YES];
    if(textField == self.monthField.textField)
    {
        if(self.yearField.textField.text.length == 0)
            [self validateMonth:YES];
        else
            [self validateDate:YES];
            
//        self.monthField.dividerLine.backgroundColor = self.monthField.dividerLineColor;
//        self.yearField.dividerLine.backgroundColor = self.yearField.dividerLineColor;
//        [self validateDate:YES];
    }
    if(textField == self.yearField.textField)
        [self validateDate:YES];
    if(textField == self.cvvField.textField)
        [self validateCCV:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.ccNumberField.textField)
    {
        NSInteger maxFieldLength = (ccType != NULL) ? ccType.maxLength : CARD_MAX_LENGTH;
        return textField.text.length + (string.length - range.length) <= maxFieldLength;
    }
    if(textField == self.monthField.textField)
    {
        return textField.text.length + (string.length - range.length) <= MONTH_MAX_LENGTH;
    }
    if(textField == self.yearField.textField)
    {
        return textField.text.length + (string.length - range.length) <= YEAR_MAX_LENGTH;
    }
    if(textField == self.cvvField.textField)
    {
        NSInteger maxFieldLength = (ccType != NULL) ? ccType.getCvcLength : CVV_MAX_LENGTH;
        return textField.text.length + (string.length - range.length) <= maxFieldLength;
    }
    return NO;
}

-(void)payButtonSelected:(UIButton *)sender
{
    [self executePayment];
}

-(void)executePayment
{
    if([self validateAndSubmit]) {
        //TODO
        self.rctBraintree = [RCTBraintree alloc];
        [self.rctBraintree tokenizeAndVerifyNat:self.ccNumberField.textField.text expirationMonth:self.monthField.textField.text expirationYear:self.yearField.textField.text cvv:self.cvvField.textField.text amountNumber:self.amount verify:self.require3dSecure clientToken:self.clientToken callback:^(NSString *nonce){
            if(nonce) {
                self.onNonceReceived(@{@"nonce":  nonce});
//                [self showSubmitMode:NO];
            } else {
                self.onNonceReceived(@{@"nonce":  nonce});
//                [self showSubmitMode:NO];
            }
        }];
//        self.onNonceReceived(@{@"nonce":  @[]});
    }
    else {
        //validation error
        NSArray *args = @[];
        args = @[[NSNull null], @"Validation error"];
        self.onNonceReceived(@{@"nonce":  args});
    }
}

-(BOOL)validateAndSubmit
{
    Validity validity = [self validate:YES];
    if(validity == Complete)
    {
//        [self showSubmitMode:YES];
        return YES;
    } else {
//        [self showSubmitMode:NO];
        return NO;
    }
}

-(Validity)validate:(BOOL)submit
{
    Validity validity = Complete;
    validity = MIN(validity, [self validateNumber:submit]);
    if ([self isRequireCVV]) {
        validity = MIN(validity, [self validateCCV:submit]);
    }
    validity = MIN(validity, [self validateDate:submit]);
    return validity;
}

-(Validity)validateNumber:(BOOL)submit
{
    CardNumberMatch *ccmatch = [[CreditCardValidator alloc] detectCard:self.ccNumberField.textField.text];
    Validity validity = ccmatch.getValidity;
    if( ccType != NULL && ![ccType isEqualToCreditCardType:ccmatch.getCardType] )
        validity = Invalid;
    [self markField:Number withValidity:validity with:submit];
    return validity;
}

-(Validity)validateCCV:(BOOL)submit
{
    CreditCardType *cardType = ccType;
    if(ccType == NULL)
        cardType = [[CreditCardValidator alloc] detectCard:self.ccNumberField.textField.text].getCardType;
    
    Validity validity = [[CreditCardValidator alloc] validateCVC:self.cvvField.textField.text withCreditCardType:cardType];

    [self markField:CVV withValidity:validity with:submit];
    return validity;
}

-(Validity)validateDate:(BOOL)submit
{
    DateValidity *dv = [[DateValidator alloc] validateDate:self.monthField.textField.text withYear:self.yearField.textField.text];
    //if Invalid and year == currentYear -> month error
    //else year Error
    
        [self markField:Month withValidity:dv.month.validity with:submit];
        [self markField:Year withValidity:dv.year.validity with:submit];

    return dv.validity;
}

-(Validity)validateMonth:(BOOL)submit
{
    PartValidity *monthV = [[DateValidator alloc] validateMonth:self.monthField.textField.text];
    [self markField:Month withValidity:monthV.validity with:submit];
    
    return monthV.validity;
}

-(void)markField:(ControlType)control withValidity:(Validity)validity with:(BOOL)submit
{
    if(validity == Invalid || (submit && validity == Partial))
    {
        [self setError:control with:invalidString];//[self getErrorMessage: control with:validity]];
    }
    else {
        [self removeError:control];
    }
}
-(void)removeError:(ControlType*)control
{
    if(control == Number)
        self.ccNumberField.hasError = NO;
    if(control == CVV)
        self.cvvField.hasError = NO;
    if(control == Month)
        self.monthField.hasError = NO;
    if(control == Year)
        self.yearField.hasError = NO;
}

-(void)setError:(ControlType*)control with:(NSString*)message
{
    if(control == Number) {
        self.ccNumberField.hasError = YES;
        self.ccNumberField.errorMessageLabelText = message;
    }
    if(control == CVV) {
        self.cvvField.hasError = YES;
        self.cvvField.errorMessageLabelText = message;
    }
    if(control == Month) {
        self.monthField.hasError = YES;
        self.monthField.errorMessageLabelText = message;
    }
    if(control == Year) {
        self.yearField.hasError = YES;
        self.yearField.errorMessageLabelText = message;

    }
}

//-(NSString*)getErrorMessage:(ControlType*)control with:(Validity)validity
//{
//    if(control == Number)
//        return (_ccErrorMessage != NULL) ? _cvvErrorMessage : @"Invalid";//@"Invalid credit card number";
//    if(control == CVV)
//        return (_cvvErrorMessage != NULL) ? _cvvErrorMessage : @"Invalid";//@"Invalid control code, it must contain 3 or 4 digits";
//    if(control == Year || control == Month)
//        return (_yearErrorMessage != NULL) ? _yearErrorMessage : @"Invalid";//@"Invalid date or expired card";
//    return @"";
//}

-(void)showSubmitMode:(BOOL)submitting
{
    if(submitting) {
        [self.activityIndicator startAnimating];
        _submitButton.enabled = NO;
        self.submitButton.alpha = 0.1;
    }
    else {
        [self.activityIndicator stopAnimating];
        _submitButton.enabled = YES;
        self.submitButton.alpha = 1;

    }
}
//TODO
-(BOOL)isRequireCVV
{
    return _requireCVV;
}
-(void)setRequireCVV:(BOOL)requireCVV
{
    _requireCVV = requireCVV;
    if (self.cvvField != NULL && !self.requireCVV)
    {
        self.cvvField.hideComponent = YES;
        [self.cvvField removeFromSuperview];
    }
}

-(BOOL)isHidePayButton
{
    return _hidePayButton;
}
-(void)setHidePayButton:(BOOL)hidePayButton
{
    _hidePayButton = hidePayButton;
    if (self.submitButton != NULL && hidePayButton)
    {
        [_submitButton setHidden:YES];
        [self.submitButton removeFromSuperview];
    }
}

-(NSNumber *)getAmount
{
    return _amount;
}

-(void)setAmount:(NSNumber*) amount
{
    _amount = amount;
}

-(NSString*)getRequiredCard
{
    return _requiredCard;
}

-(void)setRequiredCard:(NSString *)requiredCard
{
    _requiredCard = requiredCard;
    if (requiredCard != NULL) [self setCcType:requiredCard];
}

-(CreditCardType *)setCcType:(NSString*)ccName;
{
    ccType = [[CreditCardType alloc] byName:ccName];
    return ccType;
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

// FieldText
-(NSString *)getNumberString
{
    return numberString;
}

-(void)setNumberString:(NSString *)numberString
{
    self.numberString = numberString;
    if(_ccNumberField != NULL) self.ccNumberField.placeholderText = numberString;
}

-(NSString *)getMonthString
{
    return monthString;
}

-(void)setMonthString:(NSString *)monthString
{
    self.monthString = monthString;
    if(_monthField != NULL) self.monthField.placeholderText = monthString;
}

-(NSString *)getYearString
{
    return yearString;
}

-(void)setYearString:(NSString *)yearString
{
    self.yearString = yearString;
    if (_yearField != NULL) self.yearField.placeholderText = yearString;
}

-(NSString *)getCvvString
{
    return cvvString;
}

-(void)setCvvString:(NSString *)cvvString
{
    self.cvvString = cvvString;
    if(_cvvField != NULL) self.cvvField.placeholderText = cvvString;
}


-(NSString *)getInvalidString
{
    return invalidString;
}

-(void)setInvalidString:(NSString *)invalidString
{
    self.invalidString = invalidString;
    if(self.ccNumberField != NULL) self.ccNumberField.errorMessageLabelText = invalidString;
    if(self.cvvField != NULL) self.cvvField.errorMessageLabelText = invalidString;
    if(self.monthField != NULL) self.monthField.errorMessageLabelText = invalidString;
    if(self.yearField != NULL) self.yearField.errorMessageLabelText = invalidString;
}

-(NSString *)getIconFont
{
    return _iconFont;
}
-(void)setIconFont:(NSString *)iconFont
{
    _iconFont = iconFont;
    if(_ccNumberField != NULL) self.ccNumberField.iconLabelFontString = iconFont;
}

-(NSString *)getIconGlyph
{
    return _iconGlyph;
}
-(void)setIconGlyph:(NSString *)iconGlyph
{
    _iconGlyph = iconGlyph;
    if(_ccNumberField != NULL) self.ccNumberField.iconLabelText = iconGlyph;
}

-(BOOL)getShowIcon
{
    return _showIcon;
}
-(void)setShowIcon:(BOOL)showIcon
{
    _showIcon = showIcon;
    if(_ccNumberField != NULL) {
        self.ccNumberField.hasIcon = showIcon;
        self.ccNumberField.iconLabelFontString = [self getIconFont];
        self.ccNumberField.iconLabelText = [self getIconGlyph];
    }
}

-(NSInteger)getErrorColor
{
    return _errorColor;
}

-(void)setErrorColor:(NSInteger)errorColor
{
    _errorColor = errorColor;
    if(_ccNumberField != NULL)
    {
        _ccNumberField.dividerLineErrorColor = UIColorFromRGB(errorColor);
        _ccNumberField.errorMessageLabelColor = UIColorFromRGB(errorColor);
    }
    if(_cvvField != NULL)
    {
        _cvvField.dividerLineErrorColor = UIColorFromRGB(errorColor);
        _cvvField.errorMessageLabelColor = UIColorFromRGB(errorColor);
    }
    if(_monthField != NULL)
    {
        _monthField.dividerLineErrorColor = UIColorFromRGB(errorColor);
        _monthField.errorMessageLabelColor = UIColorFromRGB(errorColor);
    }
    if(_yearField != NULL)
    {
        _yearField.dividerLineErrorColor = UIColorFromRGB(errorColor);
        _yearField.errorMessageLabelColor = UIColorFromRGB(errorColor);
    }
}

-(NSInteger)getBlurColor
{
    return _blurColor;
}

-(void)setBlurColor:(NSInteger)blurColor
{
    _blurColor = blurColor;
    if(_ccNumberField != NULL)
    {
        _ccNumberField.dividerLineColor = UIColorFromRGB(blurColor);
        _ccNumberField.placeholderColor = UIColorFromRGB(blurColor);
        _ccNumberField.upperPlaceholderColor = UIColorFromRGB(blurColor);
        _ccNumberField.iconLabelColor = UIColorFromRGB(blurColor);
    }
    if(_cvvField != NULL)
    {
        _cvvField.dividerLineColor = UIColorFromRGB(blurColor);
        _cvvField.placeholderColor = UIColorFromRGB(blurColor);
        _cvvField.upperPlaceholderColor = UIColorFromRGB(blurColor);
    }
    if(_monthField != NULL)
    {
        _monthField.dividerLineColor = UIColorFromRGB(blurColor);
        _monthField.placeholderColor = UIColorFromRGB(blurColor);
        _monthField.upperPlaceholderColor = UIColorFromRGB(blurColor);
    }
    if(_yearField != NULL)
    {
        _yearField.dividerLineColor = UIColorFromRGB(blurColor);
        _yearField.placeholderColor = UIColorFromRGB(blurColor);
        _yearField.upperPlaceholderColor = UIColorFromRGB(blurColor);
    }
}
-(NSInteger)getFocusColor
{
    return _focusColor;
}

-(void)setFocusColor:(NSInteger)focusColor
{
    _focusColor = focusColor;
    if(_ccNumberField != NULL) _ccNumberField.dividerLineHighlightColor = UIColorFromRGB(focusColor);
    if(_cvvField != NULL) _cvvField.dividerLineHighlightColor = UIColorFromRGB(focusColor);
    if(_monthField != NULL) _monthField.dividerLineHighlightColor = UIColorFromRGB(focusColor);
    if(_yearField != NULL) _yearField.dividerLineHighlightColor = UIColorFromRGB(focusColor);
}

-(NSDictionary*)getTranslations
{
    return _translations;
}
-(void)setTranslations:(NSDictionary *)translations
{
    _translations = translations;
    numberString = [translations valueForKey:@"cardNumber"];
    cvvString = [translations valueForKey:@"cvv"];
    monthString = [translations valueForKey:@"month"];
    yearString = [translations valueForKey:@"year"];
    invalidString = [translations valueForKey:@"invalid"];
    if(_ccNumberField != NULL && !_ccNumberField.hideComponent)
        _ccNumberField.placeholderText = [self getNumberString];
    if(_cvvField != NULL && !_cvvField.hideComponent)
    {
       if([cvvString isEqual:[NSNull null]])
           cvvString = @"CVV";
        _cvvField.placeholderText = [self getCvvString];
    }
    if(_monthField != NULL && !_monthField.hideComponent)
        _monthField.placeholderText = [self getMonthString];
    if(_yearField != NULL && !_yearField.hideComponent)
        _yearField.placeholderText = [self getYearString];
//    [self setInvalidString:invalidString];
}

//TODO
//-(NSString *)getCcIconLabelIcon
//{
//    return _ccIconLabelText;
//}
//-(void)setCcIconLabelText:(NSString *)ccIconLabelText
//{
//    _ccIconLabelText = ccIconLabelText;
//    NSString *test = @"\ue90b";
//    const char * cstr2 = [ ccIconLabelText UTF8String ];
//    self.ccNumberField.iconLabelText = [NSString stringWithUTF8String:[ccIconLabelText UTF8String]];
//}

@end


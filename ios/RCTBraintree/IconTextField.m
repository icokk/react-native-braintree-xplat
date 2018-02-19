#import "IconTextField.h"
#import "Constants_helper.h"
#import <React/UIView+React.h>

#define FIELD_HEIGHT 64
#define TEXT_FIELD_HEIGHT 42 //20
#define ERROR_MESSAGE_HEIGHT 20
#define ICON_SIZE 26
#define SIDE_MARGIN 60
#define ICON_TOP_MARGIN 19
#define ICON_LEFT_MARGIN 0 //17
#define ICON_SIDE_LEFT_MARGIN 43 // using with ICON_LEFT_MARGIN = 0
#define TEXT_FIELD_TOP_MARGIN 11 //22 because of extending TEXT_FIELD_HEIGHT to 42
#define ERROR_TOP_MARGIN 32
#define DIVIDER_LINE_HEIGHT 1
#define DIVIDER_LINE_SIDE_MARGIN 20
#define NO_ICON_TEXT_FIELD_MARGIN 20
#define UPPER_PLACEHOLDER_TOP_MARGIN 14
#define UPPER_PLACEHOLDER_TOP_HEIGHT 14
#define TEXT_FIELD_FULL_TOP_MARGIN 32
#define CHEAT_MARGIN_FOR_REACT 40

@implementation IconTextField

- (instancetype)init:(CGFloat) width {
    if (self = [super init])
        [self initContent:width];
    return self;
}

-(void) initContent:(CGFloat)width
{
    self.iconLabelFontString = @"";
    self.iconLabelText = @"";
    self.iconLabelColor = ICON_LABEL_COLOR;
    
    self.errorMessageLabelFont = ERROR_MESSAGE_LABEL_FONT;
    self.errorMessageLabelText = @"";
    self.errorMessageLabelColor = ERROR_MESSAGE_LABEL_COLOR;
    
    self.placeholderFont = PLACEHOLDER_FONT;
    self.placeholderText = @"";
    self.placeholderColor = PLACEHOLDER_COLOR;
    
    self.upperPlaceholderFont = UPPER_PLACEHOLDER_FONT;
    self.upperPlaceholderText = @"";
    self.upperPlaceholderColor = UPPER_PLACEHOLDER_COLOR
    
    self.inputTextFont = INPUT_TEXT_FONT
    self.inputTextColor = INPUT_TEXT_COLOR
    
    self.dividerLineColor = DIVIDER_LINE_COLOR
    self.dividerLineHighlightColor = DIVIDER_LINE_HIGHLIGHT_COLOR
    self.dividerLineErrorColor = DIVIDER_LINE_ERROR_COLOR
    
    self.hasError = NO;
    self.hasIcon = YES;
    self.textFieldFull = NO;
    self.hideComponent = NO;
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width - CHEAT_MARGIN_FOR_REACT, FIELD_HEIGHT)];
    
    _iconLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

    _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.iconLabel setText:_iconLabelText];
    [self.iconLabel setTextColor:self.iconLabelColor];
    [self.iconLabel setFont:[UIFont fontWithName:[self getIconLabelFontString] size:ICON_LABEL_SIZE]];

    _textFieldView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

    _upperPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.upperPlaceholder setText:_placeholderText];
    [self.upperPlaceholder setTextColor:self.upperPlaceholderColor];
    [self.upperPlaceholder setFont:self.upperPlaceholderFont];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.textField.delegate = self;
    [self.textField setPlaceholder:_placeholderText];
    [self.textField setTextColor:self.inputTextColor];
    [self.textField setFont:self.inputTextFont];
    if(self.textField.placeholder && self.placeholderFont)
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor, NSFontAttributeName : self.placeholderFont}];
    else if(self.textField.placeholder)
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [self.textField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    
    _errorMessageLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    _errorMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.errorMessageLabel setText:self.errorMessageLabelText];
    [self.errorMessageLabel setTextColor:self.errorMessageLabelColor];
    [self.errorMessageLabel setFont:self.errorMessageLabelFont];
    
    _dividerLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.dividerLine.backgroundColor = self.dividerLineColor;
    
    _iconLabelView.translatesAutoresizingMaskIntoConstraints = NO;
    _iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textFieldView.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _errorMessageLabelView.translatesAutoresizingMaskIntoConstraints = NO;
    _errorMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dividerLine.translatesAutoresizingMaskIntoConstraints = NO;
    _upperPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;

    [_iconLabelView addSubview:_iconLabel];
    [_textFieldView addSubview:_textField];
    [_textFieldView addSubview:_upperPlaceholder];
    [_errorMessageLabelView addSubview:_errorMessageLabel];
    [_textFieldView bringSubviewToFront:_textField];
    
    [_backgroundView addSubview:_iconLabelView];
    [_backgroundView addSubview:_textFieldView];
    [_backgroundView addSubview:_errorMessageLabelView];
    [_backgroundView addSubview:_dividerLine];
    [_backgroundView bringSubviewToFront:_textFieldView];
    
    [self addSubview:_backgroundView];
    [self reload];
}

-(void)reload
{
    NSDictionary *viewsDictionary = [self getDictionary];
    NSDictionary *metrics = [self getMetrics];
    //iconLabelSize
    NSArray *iconLabel_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[iconLabel(iconSize)]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    NSArray *iconLabel_width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[iconLabel(iconSize)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:viewsDictionary];
    [self.iconLabel addConstraints:iconLabel_height];
    [self.iconLabel addConstraints:iconLabel_width];
    
    //textFieldSize
    NSArray *textField_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[textField(textFieldHeight)]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    [self.textField addConstraints:textField_height];
    
    //errorMessageLabelSize
    NSArray *errorMessageLabel_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[errorMessageLabel(errorMessageHeight)]"
                                                                                options:0
                                                                                metrics:metrics
                                                                                  views:viewsDictionary];
    NSArray *errorMessageLabel_width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[errorMessageLabel(sideMargin)]"
                                                                               options:0
                                                                               metrics:metrics
                                                                                 views:viewsDictionary];
    [self.errorMessageLabel addConstraints:errorMessageLabel_height];
    [self.errorMessageLabel addConstraints:errorMessageLabel_width];
    
    //set iconLabelView size
    NSArray *iconLabelView_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[iconLabelView(fieldHeight)]"
                                                                            options:0
                                                                            metrics:metrics
                                                                              views:viewsDictionary];
    NSArray *iconLabelView_width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[iconLabelView(iconSideLeftMargin)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:viewsDictionary];
    [self.iconLabelView addConstraints:iconLabelView_height];
    [self.iconLabelView addConstraints:iconLabelView_width];
    
    //set icon label in center
    NSArray *iconLabel_pos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(iconTopMargin)-[iconLabel]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:viewsDictionary];
    NSArray *iconLabel_pos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(iconLeftMargin)-[iconLabel]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:viewsDictionary];
    [self.iconLabelView addConstraints:iconLabel_pos_v];
    [self.iconLabelView addConstraints:iconLabel_pos_h];
    
    //upperplaceholder size
    NSArray *upperPlaceholder_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[upperPlaceholder(upperPlaceholderTopHeight)]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    [self.upperPlaceholder addConstraints:upperPlaceholder_height];

    //set textfield v1
    NSArray *textField_pos_v_v1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(textFieldTopMargin)-[textField]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:viewsDictionary];
    NSArray *textField_pos_h_v1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[textField]-(0)-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:viewsDictionary];
    [self.textFieldView addConstraints:textField_pos_v_v1];
    [self.textFieldView addConstraints:textField_pos_h_v1];
    
    //upperplaceholder position
    NSArray *upperPlaceholder_pos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(upperPlaceholderTopMargin)-[upperPlaceholder]"
                                                                              options:0
                                                                              metrics:metrics
                                                                                views:viewsDictionary];
    NSArray *upperPlaceholder_pos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[upperPlaceholder]-(0)-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    [self.textFieldView addConstraints:upperPlaceholder_pos_v];
    [self.textFieldView addConstraints:upperPlaceholder_pos_h];
    
    //set textFieldView size
    NSArray *textFieldView_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldView(fieldHeight)]"
                                                                            options:0
                                                                            metrics:metrics
                                                                              views:viewsDictionary];
    [self.textFieldView addConstraints:textFieldView_height];
    
    //set errorMessageLabelView size
    NSArray *errorMessageLabelView_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[errorMessageLabelView(fieldHeight)]"
                                                                                options:0
                                                                                metrics:metrics
                                                                                  views:viewsDictionary];
    NSArray *errorMessageLabelView_width = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[errorMessageLabelView(sideMargin)]"
                                                                                   options:0
                                                                                   metrics:metrics
                                                                                     views:viewsDictionary];
    
    [self.errorMessageLabelView addConstraints:errorMessageLabelView_height];
    [self.errorMessageLabelView addConstraints:errorMessageLabelView_width];
    
    //set error message label
    NSArray *errorMessageLabel_pos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(errorTopMargin)-[errorMessageLabel]"
                                                                               options:0
                                                                               metrics:metrics
                                                                                 views:viewsDictionary];
    NSArray *errorMessageLabel_pos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[errorMessageLabel]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary];
    [self.errorMessageLabelView addConstraints:errorMessageLabel_pos_v];
    [self.errorMessageLabelView addConstraints:errorMessageLabel_pos_h];
        
    //Divider line
    NSArray *dividerLine_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dividerLine(dividerLineHeight)]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:viewsDictionary];
    [self.dividerLine addConstraints:dividerLine_height];
    
    //backgroundView
    NSArray *Ipos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[iconLabelView]"
                                                             options:0
                                                             metrics:nil
                                                               views:viewsDictionary];
    NSArray *Fpos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[textFieldView]"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    NSArray *Epos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[errorMessageLabelView]"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    NSArray *Dpos_v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dividerLine]-(0)-|"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    NSArray *pos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[iconLabelView]-(0)-[textFieldView]-(0)-[errorMessageLabelView]-(0)-|"
                                                             options:0
                                                             metrics:nil
                                                               views:viewsDictionary];
    NSArray *Epos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[errorMessageLabelView]-(0)-|"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    
    NSArray *Dpos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[dividerLine]-(0)-|"
                                                              options:0
                                                              metrics:metrics
                                                                views:viewsDictionary];
    
    
    [self.backgroundView addConstraints:Ipos_v];
    [self.backgroundView addConstraints:pos_h];
    [self.backgroundView addConstraints:Epos_v];
    [self.backgroundView addConstraints:Fpos_v];
    [self.backgroundView addConstraints:Dpos_v];
    [self.backgroundView addConstraints:Dpos_h];
    
}

-(NSDictionary*)getMetrics
{
    return @{
            @"iconSize" : @(ICON_SIZE),
            @"textFieldHeight" : @(TEXT_FIELD_HEIGHT),
            @"errorMessageHeight" : @(ERROR_MESSAGE_HEIGHT),
            @"sideMargin" : @(SIDE_MARGIN),
            @"fieldHeight" : @(FIELD_HEIGHT),
            @"iconTopMargin" : @(ICON_TOP_MARGIN),
            @"iconLeftMargin" : @(ICON_LEFT_MARGIN),
            @"iconSideLeftMargin" : @(ICON_SIDE_LEFT_MARGIN),
            @"textFieldTopMargin" : @(TEXT_FIELD_TOP_MARGIN),
            @"dividerLineHeight" : @(DIVIDER_LINE_HEIGHT),
            @"errorTopMargin" : @(ERROR_TOP_MARGIN),
            @"dividerSideMargin" : @(DIVIDER_LINE_SIDE_MARGIN),
            @"noIconTextFieldMargin" : @(NO_ICON_TEXT_FIELD_MARGIN),
            @"upperPlaceholderTopMargin" : @(UPPER_PLACEHOLDER_TOP_MARGIN),
            @"upperPlaceholderTopHeight" : @(UPPER_PLACEHOLDER_TOP_HEIGHT),
            @"textFieldFullTopMargin" : @(TEXT_FIELD_FULL_TOP_MARGIN)
            };
}
-(NSDictionary*)getDictionary
{
    return @{
            @"iconLabelView" : self.iconLabelView,
            @"iconLabel" : self.iconLabel,
            @"errorMessageLabelView" : self.errorMessageLabelView,
            @"errorMessageLabel" : self.errorMessageLabel,
            @"textFieldView" : self.textFieldView,
            @"textField" : self.textField,
            @"dividerLine": self.dividerLine,
            @"upperPlaceholder": self.upperPlaceholder
            };
}
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) { // If one of our subviews wants it, return YES
        CGPoint pointInSubview = [subview convertPoint:point fromView:self];
        if ([subview pointInside:pointInSubview withEvent:event]) {
            return YES;
        }
    }
    return NO; // otherwise return NO, as if userInteractionEnabled were NO
}

-(void)textFieldDidChange:(UITextField *)theTextField{
    self.dividerLine.backgroundColor = self.dividerLineHighlightColor;
    self.iconLabel.textColor = self.dividerLineHighlightColor;
    if([theTextField.text isEqualToString:@""])
    {
        
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if(!self.textField.hasText)
    {
        [self.upperPlaceholder setText:_placeholderText];
        [UIView animateWithDuration:0.0 animations:^{ //version 2
            CGRect frame;
            frame = self.textField.frame;
            frame.origin.y = 21; //32; because of extending TEXT_FIELD_HEIGHT to 42
            self.textField.frame = frame;
        }];
    }
    if(_hasError) [self setHasError:NO];
    [self.textField setPlaceholder:nil];
    self.dividerLine.backgroundColor = self.dividerLineHighlightColor;
    self.iconLabel.textColor = self.dividerLineHighlightColor;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if(!self.textField.hasText)
    {
        [self.upperPlaceholder setText:nil];
        [UIView animateWithDuration:0.0 animations:^{ //version 1
            CGRect frame;
            frame = self.textField.frame;
            frame.origin.y = 11; //22; because of extending TEXT_FIELD_HEIGHT to 42
            self.textField.frame = frame;
        }];
    }
    [self.textField setPlaceholder:_placeholderText];
    if(self.textField.placeholder && self.placeholderFont != NULL)
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor, NSFontAttributeName : self.placeholderFont}];
    else if(self.textField.placeholder)
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];

    self.dividerLine.backgroundColor = self.dividerLineColor;
    self.iconLabel.textColor = self.dividerLineColor;
}

//icon label settings
-(NSString*)getIconLabelFontString
{
    return _iconLabelFontString;
}
-(void)setIconLabelFontString:(NSString*)iconLabelFontString
{
    _iconLabelFontString = iconLabelFontString;
    if(_iconLabel != NULL)  [self.iconLabel setFont:[UIFont fontWithName:iconLabelFontString size:ICON_LABEL_SIZE]];
}
-(NSString*)getIconLabelText
{
    return _iconLabelText;
}
//TODO
-(void)setIconLabelText:(NSString*)iconLabelText
{
    NSString const* name= iconLabelText;
    const char *iconText = [iconLabelText cStringUsingEncoding:NSUTF8StringEncoding];
//    &iconText[1];
//    NSLog(@"*** %d", [@"\ue90b" isEqualToString:iconLabelText]);
    if(_iconLabel != NULL)  [self.iconLabel setText:@"\ue924"];
}
-(UIColor*)getIconLabelColor
{
    return _iconLabelColor;
}
-(void)setIconLabelColor:(UIColor*)iconLabelColor
{
    _iconLabelColor = iconLabelColor;
    if(_iconLabel != NULL)  [self.iconLabel setTextColor:_iconLabelColor];
}
//message label settings
-(UIFont*)getErrorMessageLabelFont
{
    return _errorMessageLabelFont;
}
-(void)setErrorMessageLabelFont:(UIFont*)errorMessageFont
{
    _errorMessageLabelFont = errorMessageFont;
    if(_errorMessageLabel != NULL) [self.errorMessageLabel setFont:_errorMessageLabelFont];
}
-(NSString*)getErrorMessageLabelText
{
    return _errorMessageLabelText;
}
-(void)setErrorMessageLabelText:(NSString*)errorMessageLabelText
{
    _errorMessageLabelText = errorMessageLabelText;
    if(_errorMessageLabel != NULL) [self.errorMessageLabel setText:_errorMessageLabelText];
}
-(UIColor*)getErrorMessageLabelColor
{
    return _errorMessageLabelColor;
}
-(void)setErrorMessageLabelColor:(UIColor*)errorMessageLabelColor
{
    _errorMessageLabelColor = errorMessageLabelColor;
    if(_errorMessageLabel != NULL) [self.errorMessageLabel setTextColor:_errorMessageLabelColor];
}
//placeholder settings
-(UIFont*)getPlaceholderFont
{
    return _placeholderFont;
}
-(void)setPlaceholderFont:(UIFont*)placeholderFont
{
    _placeholderFont = placeholderFont;
    if(_textField != NULL && _placeholderFont != NULL) self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor,
                    NSFontAttributeName : _placeholderFont}];
}
-(NSString*)getPlaceholderText
{
    return _placeholderText;
}
-(void)setPlaceholderText:(NSString*)placeholderText
{
    _placeholderText = placeholderText;
    if(_textField != NULL)
    {
        [self.textField setPlaceholder:_placeholderText];
        if(self.textField.placeholder && self.placeholderFont != NULL)
            self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor, NSFontAttributeName : self.placeholderFont}];
        else if(self.textField.placeholder)
             self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
    }
}
-(UIColor*)getPlaceholderColor
{
    return _placeholderColor;
}
-(void)setPlaceholderColor:(UIColor*)placeholderColor
{
    _placeholderColor = placeholderColor;
    if(_textField != NULL && self.placeholderFont != NULL) self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: _placeholderColor,
                    NSFontAttributeName : self.placeholderFont}];
    else if(_textField != NULL) self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: _placeholderColor}];
}
//upper placeholder settings
-(UIFont*)getUpperPlaceholderFont
{
    return _upperPlaceholderFont;
}
-(void)setUpperPlaceholderFont:(UIFont*)upperPlaceholderFont
{
    _upperPlaceholderFont = upperPlaceholderFont;
    if(_upperPlaceholder != NULL) [self.upperPlaceholder setFont:_upperPlaceholderFont];
}
-(NSString*)getUpperPlaceholderText
{
    return _upperPlaceholderText;
}
-(void)setUpperPlaceholderText:(NSString*)upperPlaceholderText
{
    _upperPlaceholderText = upperPlaceholderText;
    if(_upperPlaceholder != NULL) [self.upperPlaceholder setText:_upperPlaceholderText];
}
-(UIColor*)getUpperPlaceholderColor
{
    return _upperPlaceholderColor;
}
-(void)setUpperPlaceholderColor:(UIColor*)upperPlaceholderColor
{
    _upperPlaceholderColor = upperPlaceholderColor;
    if(_upperPlaceholder != NULL) [self.upperPlaceholder setTextColor:_upperPlaceholderColor];
}
//textfiled text settings
-(UIColor*)getInputTextColor
{
    return _inputTextColor;
}
-(void)setInputTextColor:(UIColor*)inputTextColor
{
    _inputTextColor = inputTextColor;
    if(_textField != NULL) [self.textField setTextColor:_inputTextColor];
}
-(UIFont*)getInputTextFont
{
    return _inputTextFont;
}
-(void)setInputTextFont:(UIFont *)inputTextFont
{
    _inputTextFont = inputTextFont;
    [self.textField setFont:_inputTextFont];
}
//hasError settings
-(BOOL)isHasError
{
    return _hasError;
}
-(void)setHasError:(BOOL*)hasError
{
    _hasError = hasError;
    if(_errorMessageLabelView != NULL)
    {
        if(_hasError) {
            [self setErrorMessageLabelText:self.errorMessageLabelText];
            [self.dividerLine setBackgroundColor:self.dividerLineErrorColor];
            [self.iconLabel setTextColor:self.dividerLineErrorColor];
        }
        else {
            [_errorMessageLabel setText: @""];
            [self.dividerLine setBackgroundColor:self.dividerLineColor];
            [self.iconLabel setTextColor:self.dividerLineColor];
        }
    }
}
//hasIconSettings
-(BOOL)isHasIcon
{
    return _hasIcon;
}
-(void)setHasIcon:(BOOL*)hasIcon
{
    _hasIcon = hasIcon;
    if(_iconLabelView != NULL)
    {
        if(_hasIcon) {
            [self.iconLabel setText:self.iconLabelText];
        }
        else {
            [self.iconLabel removeFromSuperview];
            [self.iconLabelView removeFromSuperview];
            NSDictionary *viewsDictionary = [self getDictionary];
            NSDictionary *metrics = [self getMetrics];
            NSArray *pos_h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[textFieldView]-(0)-[errorMessageLabelView]-(0)-|"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:viewsDictionary];
            [self.backgroundView addConstraints:pos_h];
        }
    }
}
//dividerLineSettings
-(UIColor*)getDividerLineColor
{
    return _dividerLineColor;
}
-(void)setDividerLineColor:(UIColor*)dividerLineColor
{
    _dividerLineColor = dividerLineColor;
    if(_dividerLine != NULL) self.dividerLine.backgroundColor = _dividerLineColor;
}
-(UIColor*)getDividerLineHighlightlColor
{
    return _dividerLineHighlightColor;
}
-(void)setDividerLineHighlightColor:(UIColor*)dividerLineHighlightColor
{
    _dividerLineHighlightColor = dividerLineHighlightColor;
//    if(_dividerLine != NULL) self.dividerLine.backgroundColor = _dividerLineHighlightColor;
}
-(UIColor*)getDividerLineErrorColor
{
    return _dividerLineErrorColor;
}
-(void)setDividerLineErrorColor:(UIColor*)dividerLineErrorColor
{
    _dividerLineErrorColor = dividerLineErrorColor;
//    if(_dividerLine != NULL) self.dividerLine.backgroundColor = _dividerLineErrorColor;
}

-(BOOL)getHideComponent
{
    return _hideComponent;
}
-(void)setHideComponent:(BOOL)hideComponent
{
    _hideComponent = hideComponent;
    if(_backgroundView != NULL && hideComponent)
        [_backgroundView removeFromSuperview];
}

@end

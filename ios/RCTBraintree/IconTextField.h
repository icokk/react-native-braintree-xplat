//
//  IconTextField.h
//  RCTBraintree
//
//  Created by Urska Pangerc on 06/12/2016.
//  Copyright © 2016 Rickard Ekman. All rights reserved.
//

#import <UIKit/UIKit.h>


@class IconTextField;

@interface IconTextField : UIControl


@property UILabel *backgroundView;
@property UIView *iconLabelView;
@property UIView *textFieldView;
@property UIView *errorMessageLabelView;
@property UILabel *iconLabel;
@property UITextField *textField;
@property UILabel *upperPlaceholder;
@property UILabel *errorMessageLabel;
@property UILabel *dividerLine;

@property NSString *iconLabelFontString;
@property NSString *iconLabelText;
@property UIColor *iconLabelColor;

@property UIFont *errorMessageLabelFont;
@property NSString *errorMessageLabelText;
@property UIColor *errorMessageLabelColor;

@property UIFont *placeholderFont;
@property NSString *placeholderText;
@property UIColor *placeholderColor;

@property UIFont *upperPlaceholderFont;
@property NSString *upperPlaceholderText;
@property UIColor *upperPlaceholderColor;

@property UIFont *inputTextFont;
@property UIColor *inputTextColor;

@property BOOL hasError;
@property BOOL hasIcon;
@property BOOL textFieldFull;
@property BOOL hideComponent;

@property UIColor *dividerLineColor;
@property UIColor *dividerLineHighlightColor;
@property UIColor *dividerLineErrorColor;

-(instancetype)init:(CGFloat)width;

@end

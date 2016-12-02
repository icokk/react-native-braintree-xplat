//
//  CreditCardValidator.m
//  RCTBraintree
//
//  Created by Urska Pangerc on 28/11/2016.
//  Copyright © 2016 Rickard Ekman. All rights reserved.
//

#import "CreditCardValidator.h"
#import "Validity.h"
#import "ValidatorUtils.h"
#import "CreditCardType.h"

@implementation CreditCardValidator

-(NSInteger)luhnChecksum:(NSString *)number
{
    NSInteger sum = 0;
    NSInteger length = number.length;
    for(int i=1; i<=length; i++)
    {
        NSInteger digit = [number characterAtIndex:(length-i)] - '0';
        if (digit < 0 || digit > 9)
            return -1; // invalid character
        if ( (i & 1) == 0 ) {
            digit = 2 * digit;
            if ( digit > 9 )
                digit = digit - 9;
        }
        sum += digit;
    }
    return sum % 10;
}

-(BOOL)luhnValid:(NSString *)number
{
    return ([self luhnChecksum:number] == 0);
}

-(NSString *)cleanupNumber:(NSString *)number
{
    NSInteger length = number.length;
    NSString *stringBuilder = [[NSString alloc] init];
    for(int i=0; i<length; i++)
    {
        char ch = [number characterAtIndex:i];
        if ( '0' <= ch && ch <= '9' )
            stringBuilder = [stringBuilder stringByAppendingString:[NSString stringWithFormat:@"%c", ch]];
        else if(!(ch == '-' || ch == ' ')) // else if ( !(Character.isSpaceChar(ch) || ch == '-') ) TODO
            return nil;
    }
    return stringBuilder;
    
}

-(CardNumberMatch *)detectCard:(NSString *)cardNumber with:(NSArray *)cardTypes
{
    NSString *number = [self cleanupNumber:cardNumber];
    if(number == NULL)
        return [[CardNumberMatch alloc] initWithCreditCardType:nil withValidity:Invalid]; // NO_MATCH
    if([number length] == 0)
        return [[CardNumberMatch alloc] initWithCreditCardType:nil withValidity:Partial]; //EMPTY
    
    CardNumberMatch *match = [self getCreditCardType:number with:cardTypes];
    // require luhn validity for full matches
    if(match.getValidity == Complete)
    {
        if(![self luhnValid:number])
        {
            if ( [match.getCardType isLengthMaximal:number] )
                return [[CardNumberMatch alloc] initWithCreditCardType:nil withValidity:Invalid]; // NO_MATCH
            // it may still be extended to valid match
            return [[CardNumberMatch alloc] initWithCreditCardType:match.getCardType withValidity:Partial];
        }

    }
    return match;
}


-(CardNumberMatch *)getCreditCardType:(NSString *)number with:(NSArray *)cardTypes
{
    for(int i = 0; i < [cardTypes count]; i++)
    {
        CreditCardType *card = [cardTypes objectAtIndex:i];
        Validity match = [card match:number];
        if(match != Invalid)
            return [[CardNumberMatch alloc] initWithCreditCardType:card withValidity:match];
    }
    return [[CardNumberMatch alloc] initWithCreditCardType:nil withValidity:Invalid]; // NO_MATCH
}

-(CardNumberMatch *)detectCard:(NSString *)cardNumber
{
    return [self detectCard:cardNumber with:[[CreditCardType alloc] createCardList]];
}

-(Validity)validateCardNumber:(NSString *) cardNumber with:(CreditCardType *)cardTypes
{
    return [self detectCard:cardNumber with:cardTypes].getValidity;
}


NSInteger * const MAX_CONTROL_LENGTH = 4;

-(Validity)validateCVC:(NSString*)cvc withCreditCardType:(CreditCardType *)cardType
{
    if(![[ValidatorUtils alloc] isDigitsOnly:cvc])
        return Invalid;
    NSInteger maxCvcLength = (cardType != nil) ? [cardType getCvcLength] : MAX_CONTROL_LENGTH;
    if ( cvc.length > maxCvcLength )
        return Invalid;
    if ( cvc.length < maxCvcLength )
        return Partial;
    return cardType != nil ? Complete : Partial;
}


@end


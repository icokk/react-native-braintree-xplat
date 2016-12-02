//
//  CardNumberMatch.m
//  RCTBraintree
//
//  Created by Urska Pangerc on 28/11/2016.
//  Copyright © 2016 Rickard Ekman. All rights reserved.
//

#import "CardNumberMatch.h"
#import "Validity.h"

@implementation CardNumberMatch

//CardNumberMatch * const NO_MATCH = [[CardNumberMatch alloc] initWithCreditCardType:nil withValidity:Invalid];
//CardNumberMatch * const EMPTY =[[CardNumberMatch alloc] initWithCreditCardType:nil withValidity:Partial];

-(id)initWithCreditCardType:(CreditCardType *)cardType withValidity:(Validity *) match
{
    self = [super init];
    if(self)
    {
        self.cardType = cardType;
        self.validity = match;
    }
    return self;
}

-(CreditCardType *)getCardType
{
    return _cardType;
}

-(Validity)getValidity
{
    return _validity;
}


@end


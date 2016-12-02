#import <Foundation/Foundation.h>
#import "Validity.h"
#import "CreditCardType.h"

@interface CardNumberMatch : NSObject

@property CreditCardType* cardType;
@property Validity validity;

//extern CardNumberMatch * const NO_MATCH;
//extern CardNumberMatch * const EMPTY;
//#define NO_MATCH = [[CardNumberMatch alloc] initWithCreditCardType:nil withValidity:Invalid];
//#define EMPTY =[[CardNumberMatch alloc] initWithCreditCardType:nil withValidity:Partial];

-(id)initWithCreditCardType:(CreditCardType *)cardType withValidity:(Validity *) match;
-(CreditCardType *)getCardType;
-(Validity)getValidity;

@end


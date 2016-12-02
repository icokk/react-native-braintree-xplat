#import <Foundation/Foundation.h>
#import "Validity.h"
#import "CreditCardType.h"
#import "CardNumberMatch.h"

@interface CreditCardValidator : NSObject

-(NSInteger)luhnChecksum:(NSString *)number;
-(BOOL)luhnValid:(NSString *)number;
-(NSString *)cleanupNumber:(NSString *)number;

-(CardNumberMatch *)detectCard:(NSString *)cardNumber with:(NSArray *)cardTypes;
-(CardNumberMatch *)getCreditCardType:(NSString *)number with:(NSArray *)cardTypes;

-(CardNumberMatch *)detectCard:(NSString *)cardNumber;

-(Validity)validateCardNumber:(NSString *) cardNumber with:(CreditCardType *)cardTypes;

-(Validity)validateCVC:(NSString*)cvc withCreditCardType:(CreditCardType *)cardType;

@end

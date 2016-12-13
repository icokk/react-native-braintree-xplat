#import <Foundation/Foundation.h>
#import "Validity.h"

//
//typedef enum CreditCardType
//{
//    Visa = [[CreditCardType alloc ] initWithCreditCardType:@"visa" withNiceName:@"Visa" withPattern:@"^4\\d*$" withLength:[NSArray arrayWithObjects: 16] withCvcName:"CVV" withCvcLength:3],
//    
//
//} CreditCardType;

//Visa("visa", "Visa",
//     "^4\\d*$",
//     new int[] { 16 }, "CVV", 3),

@interface CreditCardType : NSObject

@property NSString *name;
@property NSString *niceName;
@property NSRegularExpression *pattern;
@property NSArray *lengths;
@property NSInteger *maxLength;
@property NSString *cvcName;
@property NSInteger *cvcLength;


-(id)initWithCreditCardType:(NSString *)name withNiceName:(NSString *)niceName withPattern:(NSRegularExpression *)pattern withLength:(NSArray *)lengths withCvcName:(NSString *)cvcName withCvcLength:(NSInteger *)cvcLength;
-(Validity)match:(NSString *)number;
-(CreditCardType *)byName:(NSString *)name;
-(BOOL)isLengthMaximal:(NSString *)number;
-(NSString *)getName;
-(NSString *)getNiceName;
-(NSString *)getCvcName;
-(NSInteger)getCvcLength;
-(NSArray *)createCardList;
-(BOOL)isEqualToCreditCardType:(CreditCardType *)creditCardType;

@end


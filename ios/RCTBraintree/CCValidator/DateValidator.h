#import <Foundation/Foundation.h>
#import "PartValidity.h"
#import "DateValidity.h"


@interface DateValidator : NSObject

extern NSString * const CENTURY;
extern NSInteger * const MAX_VALIDITY_YEARS;

-(PartValidity*)validateMonth:(NSString *)month;
-(PartValidity*)validateYear:(NSString *)year;
-(DateValidity*)validateDate:(NSString *)month withYear:(NSString *)year;

@end

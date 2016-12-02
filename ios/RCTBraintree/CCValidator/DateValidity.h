#import <Foundation/Foundation.h>

#import "Validity.h"
#import "PartValidity.h"

@interface DateValidity : NSObject

@property PartValidity* month;
@property PartValidity* year;

-(id)initDateValidity:(PartValidity *)month withPartValidity:(PartValidity *)year;
-(NSInteger*)getMonth;
-(NSInteger*)getYear;
-(Validity)monthValidity;
-(Validity)yearValidity;
-(Validity)validity;
-(NSString *)description;
@end

#import <Foundation/Foundation.h>

#import "Validity.h"
#import "DateValidity.h"
#import "ValidatorUtils.h"

@implementation DateValidity

-(id)initDateValidity:(PartValidity *)month withPartValidity:(PartValidity *)year
{
    self = [super init];
    if(self)
    {
        self.month = month;
        self.year = year;
    }
    return self;
}

-(NSInteger*)getMonth
{
    return _month.value;
}

-(NSInteger*)getYear
{
    return _year.value;
}

-(Validity)monthValidity
{
    return _month.validity;
}

-(Validity)yearValidity
{
    return _year.validity;
}

-(Validity)validity
{
    return MIN(_month.validity, _year.validity);
}


-(NSString *)description
{
return [NSString stringWithFormat: @"%@ (month=%@, year=%@)", self.validity, _month.validity, _year.validity];
}


@end

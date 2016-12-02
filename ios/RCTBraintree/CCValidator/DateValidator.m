#import "DateValidator.h"
#import "ValidatorUtils.h"
#import "PartValidity.h"
#import "Validity.h"
#import "DateValidity.h"

@implementation DateValidator

NSString * const CENTURY = @"20";
NSInteger * const MAX_VALIDITY_YEARS = 30;


-(PartValidity*)validateMonth:(NSString *)month
{
    if(![[ValidatorUtils alloc] isDigitsOnly:month] && month.length > 2)
    {
        return [[PartValidity alloc] invalid:0];
    }
    if(month.length == 0)
    {
        return [[PartValidity alloc] partial:0];
    }
    NSInteger monthInt = [month intValue];
    if(monthInt < 1 || monthInt > 12)
    {
        return [[PartValidity alloc] invalid:0];
    }
    return [[PartValidity alloc] full:monthInt];
}

-(PartValidity*)validateYear:(NSString *)year
{
    if (![[ValidatorUtils alloc] isDigitsOnly:year] && year.length > 4)
        return [[PartValidity alloc] invalid:0];
    if (year.length < 2)
        return [[PartValidity alloc] partial:0];
    if (year.length == 3)
        return ([year hasPrefix:CENTURY]) ? [[PartValidity alloc] partial:0] : [[PartValidity alloc] invalid:0];
    
    NSInteger yearInt = [((year.length == 2) ? [CENTURY stringByAppendingString:year]: year) intValue];
    
    NSDate *now = [NSDate date];
    // Specify which units we would like to use
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:units fromDate:now];
    
    NSInteger currentYear = [components year];

    if ( yearInt < currentYear || yearInt > currentYear + MAX_VALIDITY_YEARS ) {
        if ([year isEqualToString:CENTURY])    // special case - may be completed
            return [[PartValidity alloc] partial:yearInt];
        return [[PartValidity alloc] invalid:yearInt];
    }
    return [[PartValidity alloc] full:yearInt];
    
}

-(DateValidity*)validateDate:(NSString *)month withYear:(NSString *)year
{
    PartValidity *monthV = [self validateMonth:month];
    PartValidity *yearV = [self validateYear:year];
    if (monthV.validity != Complete || yearV.validity != Complete)
        return [[DateValidity alloc] initDateValidity:monthV withPartValidity:yearV];
    
    NSDate *now = [NSDate date];
    // Specify which units we would like to use
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:units fromDate:now];
    
    NSInteger currentMonth = [components month]; //TODO int currentMonth = date.get(Calendar.MONTH) - Calendar.JANUARY + 1;

    NSInteger currentYear = [components year];
    // check date to be at least current date
    if(yearV.value > currentYear)
        return [[DateValidity alloc] initDateValidity:monthV withPartValidity:yearV]; //valid
    if(yearV.value == currentYear && monthV.value >= currentMonth)
        return [[DateValidity alloc] initDateValidity:monthV withPartValidity:yearV]; //valid
    
    // year must be valid if it passed year validation, so month is wrong
    // (month 1 can still be completed to valid 11 or 12)
    PartValidity *monthValidity = monthV.value == 1 ? [[PartValidity alloc] partial:monthV.value] : [[PartValidity alloc] invalid:monthV.value];
    return [[DateValidity alloc] initDateValidity:monthValidity withPartValidity:yearV];

    
}
@end

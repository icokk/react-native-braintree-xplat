#import "CreditCardType.h"
#import "Validity.h"

@implementation CreditCardType

-(id)initWithCreditCardType:(NSString *)name withNiceName:(NSString *)niceName withPattern:(NSRegularExpression *)pattern withLength:(NSArray *)lengths withCvcName:(NSString *)cvcName withCvcLength:(NSInteger *)cvcLength
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.niceName = niceName;
        self.pattern = pattern;
        self.lengths = lengths;
        self.maxLength = 0;
        for (int i = 0; i < [self.lengths count]; i++)
        {
            self.maxLength = MAX(self.maxLength, [[self.lengths objectAtIndex:i] integerValue]);
        }
        self.cvcName = cvcName;
        self.cvcLength = cvcLength;
    }
    return self;
}

-(Validity)match:(NSString *)number
{
    // check pattern match
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:number options:0 range:NSMakeRange(0, [number length])];
    if (![matches count])
        return Invalid;
    
    // check length match
    int length = number.length;
    if (length > self.maxLength)
        return Invalid;
    
    for (int i = 0; i < [self.lengths count]; i++)
        if([[self.lengths objectAtIndex:i] integerValue] == length)
            return Complete;
    return Partial;
}


-(CreditCardType *)byName:(NSString *)name
{
    for (int i=0; i < [[self createCardList] count]; i++)
    {
        CreditCardType *card = [[self createCardList] objectAtIndex:i];
        if([card.name isEqualToString:name] || [card.niceName isEqualToString:name])
            return card;
    }
    return NULL;
}


-(BOOL)isLengthMaximal:(NSString *)number
{
    return number.length == _maxLength;
}

-(NSString *)getName
{
    return _name;
}

- (NSString *)getNiceName
{
    return _niceName;
}

- (NSString *)getCvcName
{
    return _cvcName;
}

- (NSInteger)getCvcLength
{
    return _cvcLength;
}

-(NSArray *)createCardList
{
return [NSArray arrayWithObjects:
        [[CreditCardType alloc ] initWithCreditCardType:@"visa" withNiceName:@"Visa" withPattern:@"^4\\d*$" withLength:[NSArray arrayWithObjects: @16, nil] withCvcName:@"CVV" withCvcLength:3],
        [[CreditCardType alloc ] initWithCreditCardType:@"master-card" withNiceName:@"MasterCard" withPattern:@"^(5|5[1-5]\\d*|2|22|222|222[1-9]\\d*|2[3-6]\\d*|27[0-1]\\d*|2720\\d*)$" withLength:[NSArray arrayWithObjects: @16, nil] withCvcName:@"CVC" withCvcLength:3],
        [[CreditCardType alloc ] initWithCreditCardType:@"american-express" withNiceName:@"American Express" withPattern:@"^3([47]\\d*)?$" withLength:[NSArray arrayWithObjects: @15, nil] withCvcName:@"CID" withCvcLength:4],
        [[CreditCardType alloc ] initWithCreditCardType:@"diners-club" withNiceName:@"Diners Club" withPattern:@"^3((0([0-5]\\d*)?)|[689]\\d*)?$" withLength:[NSArray arrayWithObjects: @14, nil] withCvcName:@"CVV" withCvcLength:3],
        [[CreditCardType alloc ] initWithCreditCardType:@"maestro" withNiceName:@"Maestro" withPattern:@"^((5((0|[6-9])\\d*)?)|(6|6[37]\\d*))$" withLength:[NSArray arrayWithObjects: @12, @13, @14, @15, @16, @17, @18, @19, nil] withCvcName:@"CVC" withCvcLength:3],
        [[CreditCardType alloc ] initWithCreditCardType:@"discover" withNiceName:@"Discover" withPattern:@"^6(0|01|011\\d*|5\\d*|4|4[4-9]\\d*)?$" withLength:[NSArray arrayWithObjects: @16, @19, nil] withCvcName:@"CID" withCvcLength:3],
        [[CreditCardType alloc ] initWithCreditCardType:@"jcb" withNiceName:@"JCB" withPattern:@"^((2|21|213|2131\\d*)|(1|18|180|1800\\d*)|(3|35\\d*))$" withLength:[NSArray arrayWithObjects: @16, nil] withCvcName:@"CVV" withCvcLength:3]];
}

- (BOOL)isEqualToCreditCardType:(CreditCardType *)creditCardType {
    return [self.name isEqualToString:creditCardType.name] &&
    [self.niceName isEqualToString:creditCardType.niceName] &&
    [self.cvcName isEqualToString:creditCardType.cvcName] &&
    (self.maxLength == creditCardType.maxLength) &&
    (self.cvcLength == creditCardType.cvcLength) &&
    [self.lengths isEqual:creditCardType.lengths] &&
    [self.pattern isEqual:creditCardType.pattern];
}

@end

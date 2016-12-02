#import "PartValidity.h";
#import "Validity.h";

@implementation PartValidity

-(id)initPartValidity:(NSInteger *)value withValidity:(Validity)validity
{
    self = [super init];
    if(self)
    {
        self.value = value;
        self.validity = validity;
    }
    return self;
}

-(PartValidity*)invalid:(NSInteger *)value
{
    return [[PartValidity alloc] initPartValidity:value withValidity:Invalid];
}

-(PartValidity*)partial:(NSInteger *)value
{
    return [[PartValidity alloc] initPartValidity:value withValidity:Partial];
}

-(PartValidity*)full:(NSInteger *)value
{
    return [[PartValidity alloc] initPartValidity:value withValidity:Complete];
}

-(NSString *)description
{
    return [NSString stringWithFormat: @"%@: %@", _value, _validity];
}


@end

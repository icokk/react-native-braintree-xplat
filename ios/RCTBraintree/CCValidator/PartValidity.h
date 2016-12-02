#import <Foundation/Foundation.h>

#import "Validity.h"

@interface PartValidity : NSObject

@property NSInteger value;
@property Validity validity;

-(id)initPartValidity:(NSInteger *)value withValidity:(Validity)validity;
-(PartValidity*)invalid:(NSInteger *)value;
-(PartValidity*)partial:(NSInteger *)value;
-(PartValidity*)full:(NSInteger *)value;
-(NSString *)description;
@end

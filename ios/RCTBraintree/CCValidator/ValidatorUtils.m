//
//  ValidatorUtils.m
//  RCTBraintree
//
//  Created by Urska Pangerc on 28/11/2016.
//  Copyright © 2016 Rickard Ekman. All rights reserved.
//

#import "ValidatorUtils.h"


@implementation ValidatorUtils

-(BOOL)isDigitsOnly:(NSString *)number
{
    NSInteger length = number.length;
    for(int i=0; i<length; i++)
    {
        char ch = [number characterAtIndex:i];
        if ( ch < '0' || ch > '9' )
            return NO;
    }
    return YES;
}

@end

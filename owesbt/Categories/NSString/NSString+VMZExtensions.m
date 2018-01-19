//
//  NSString+VMZExtensions.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "NSString+VMZExtensions.h"

@implementation NSString (VMZExtensions)

- (NSString *)VMZUppercaseFirstLetter
{
    return [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
}

- (NSString *)VMZPhoneNumberDigits
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\+7"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSString *temp = [regex stringByReplacingMatchesInString:self
                                                     options:0
                                                       range:NSMakeRange(0, [self length])
                                                withTemplate:@"8"];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\d\\+]"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    temp = [regex stringByReplacingMatchesInString:temp
                                           options:0
                                             range:NSMakeRange(0, [temp length])
                                      withTemplate:@""];
    
    return temp;
}

@end

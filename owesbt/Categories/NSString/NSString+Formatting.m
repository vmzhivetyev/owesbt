//
//  NSString+Formatting.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "NSString+Formatting.h"

@implementation NSString (Formatting)

- (NSString *)ft_uppercaseFirstLetter
{
    switch ([self length]) {
        case 0:
            return self.copy;
        
        case 1:
            return [self uppercaseString];
            
        default:
            return [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
    }
}

- (NSString *)ft_phoneNumberDigits
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

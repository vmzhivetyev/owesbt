//
//  NSString+VMZExtensions.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "NSString+VMZExtensions.h"

@implementation NSString (VMZExtensions)

- (NSString *)uppercaseFirstLetter
{
    return [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
}

@end

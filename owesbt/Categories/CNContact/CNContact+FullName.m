//
//  CNContact+FullName.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 13.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "CNContact+FullName.h"

@implementation CNContact (FullName)

- (NSString *)fn_fullName
{
    return [self valueForKey:@"fullName"];
}

@end

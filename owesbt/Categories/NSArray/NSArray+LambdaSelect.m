//
//  NSArray+LambdaSelect.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 25.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "NSArray+LambdaSelect.h"

@implementation NSArray (LambdaSelect)

- (NSArray *)ls_arrayWithSelect:(id (^)(id, NSUInteger))predicate
{
    NSMutableArray *result = [NSMutableArray new];
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:predicate(obj, idx)];
    }];
    
    return [NSArray arrayWithArray:result];
}

@end

//
//  NSArray+LambdaSelect.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 25.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (LambdaSelect)

- (NSArray *)ls_arrayWithSelect:(id (^)(ObjectType obj, NSUInteger idx))predicate;

@end

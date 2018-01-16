//
//  VMZOweData+CoreDataProperties.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "VMZOweData+CoreDataProperties.h"


@implementation VMZOweData (CoreDataProperties)

+ (NSFetchRequest<VMZOweData *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Owe"];
}

@dynamic closed;
@dynamic created;
@dynamic creditor;
@dynamic debtor;
@dynamic descr;
@dynamic status;
@dynamic uid;
@dynamic sum;

@end

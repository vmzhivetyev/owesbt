//
//  VMZOweData+CoreDataProperties.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 19.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

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
@dynamic sum;
@dynamic uid;
@dynamic partnerName;

@end

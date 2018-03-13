//
//  VMZOweGroup+CoreDataProperties.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 13.03.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweGroup+CoreDataProperties.h"

@implementation VMZOweGroup (CoreDataProperties)

+ (NSFetchRequest<VMZOweGroup *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Group"];
}

@dynamic members;
@dynamic name;
@dynamic owes;
@dynamic uid;
@dynamic created;

@end

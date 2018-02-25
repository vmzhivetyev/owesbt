//
//  VMZOweGroup+CoreDataProperties.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 25.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweGroup+CoreDataProperties.h"

@implementation VMZOweGroup (CoreDataProperties)

+ (NSFetchRequest<VMZOweGroup *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Group"];
}

@dynamic uid;
@dynamic members;
@dynamic owes;

@end

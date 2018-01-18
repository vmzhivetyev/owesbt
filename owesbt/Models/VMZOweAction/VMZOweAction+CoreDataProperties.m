//
//  VMZOweAction+CoreDataProperties.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 16.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweAction+CoreDataProperties.h"

@implementation VMZOweAction (CoreDataProperties)

+ (NSFetchRequest<VMZOweAction *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"OweAction"];
}

@dynamic action;
@dynamic parameters;
@dynamic created;
@dynamic owe;

@end

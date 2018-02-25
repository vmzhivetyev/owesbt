//
//  VMZOweGroup+CoreDataClass.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 25.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweGroup+CoreDataClass.h"

@implementation VMZOweGroup

+ (instancetype)newInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self fetchRequest].entityName inManagedObjectContext:moc];
}

@end

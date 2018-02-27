//
//  VMZOweAction+CoreDataClass.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 16.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweAction+CoreDataClass.h"

@implementation VMZOweAction

+ (instancetype)createNewActionObject:(NSString*)action withParameters:(NSDictionary *)params forOwe:(VMZOweData *)owe managedObjectContext:(NSManagedObjectContext*)moc
{
    VMZOweAction *newAction = [NSEntityDescription insertNewObjectForEntityForName:[self class].entity.name inManagedObjectContext:moc];
    newAction.action = action;
    newAction.parameters = params;
    newAction.owe = owe;
    newAction.created = [NSDate date];
    return newAction;
}

@end

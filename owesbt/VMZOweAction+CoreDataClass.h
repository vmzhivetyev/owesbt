//
//  VMZOweAction+CoreDataClass.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 16.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSObject, VMZOweData;

NS_ASSUME_NONNULL_BEGIN

@interface VMZOweAction : NSManagedObject

+ (instancetype)newAction:(NSString*)action withParameters:(NSDictionary *)params forOwe:(VMZOweData *)owe managedObjectContext:(NSManagedObjectContext*)moc;

@end

NS_ASSUME_NONNULL_END

#import "VMZOweAction+CoreDataProperties.h"

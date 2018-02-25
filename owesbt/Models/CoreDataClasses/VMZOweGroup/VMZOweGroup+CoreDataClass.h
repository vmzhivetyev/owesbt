//
//  VMZOweGroup+CoreDataClass.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 25.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSObject;

NS_ASSUME_NONNULL_BEGIN

@interface VMZOweGroup : NSManagedObject

+ (instancetype)newInManagedObjectContext:(NSManagedObjectContext *)moc;

@end

NS_ASSUME_NONNULL_END

#import "VMZOweGroup+CoreDataProperties.h"

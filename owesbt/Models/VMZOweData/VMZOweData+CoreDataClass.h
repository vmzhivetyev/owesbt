//
//  VMZOweData+CoreDataClass.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class CNContact;


NS_ASSUME_NONNULL_BEGIN

@interface VMZOweData : NSManagedObject

- (NSString *)partner;

+ (instancetype)newOweInManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)loadFromDictionary:(NSDictionary *)dict;
- (BOOL)selfIsCreditor;

@end

NS_ASSUME_NONNULL_END

#import "VMZOweData+CoreDataProperties.h"

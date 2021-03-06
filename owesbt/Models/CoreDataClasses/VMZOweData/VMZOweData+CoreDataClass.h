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


typedef enum {
    VMZOweStatusUndefined,
    VMZOweStatusActive,
    VMZOweStatusRequested,
    VMZOweStatusClosed
} VMZOweStatus;


NS_ASSUME_NONNULL_BEGIN


@interface VMZOweData : NSManagedObject

+ (NSString *)stringFromStatus:(VMZOweStatus)status;
+ (VMZOweStatus)statusFromName:(NSString *)name;

- (NSString *)partner;
- (void)updatePartnerName;
- (VMZOweStatus)statusType;
- (void)setStatusType:(VMZOweStatus)status;

- (void)loadFromDictionary:(NSDictionary *)dict;
- (BOOL)selfIsCreditor;

- (void)log;

@end

NS_ASSUME_NONNULL_END

#import "VMZOweData+CoreDataProperties.h"

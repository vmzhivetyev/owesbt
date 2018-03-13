//
//  VMZOweGroup+CoreDataProperties.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 13.03.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweGroup+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface VMZOweGroup (CoreDataProperties)

+ (NSFetchRequest<VMZOweGroup *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *members;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSObject *owes;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, copy) NSDate *created;

@end

NS_ASSUME_NONNULL_END

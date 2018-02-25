//
//  VMZOweGroup+CoreDataProperties.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 25.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweGroup+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface VMZOweGroup (CoreDataProperties)

+ (NSFetchRequest<VMZOweGroup *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, retain) NSObject *members;
@property (nullable, nonatomic, retain) NSObject *owes;

@end

NS_ASSUME_NONNULL_END

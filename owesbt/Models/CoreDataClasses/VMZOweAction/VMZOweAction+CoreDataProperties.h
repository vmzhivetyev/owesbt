//
//  VMZOweAction+CoreDataProperties.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 16.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweAction+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface VMZOweAction (CoreDataProperties)

+ (NSFetchRequest<VMZOweAction *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *action;
@property (nullable, nonatomic, retain) NSObject *parameters;
@property (nullable, nonatomic, copy) NSDate *created;
@property (nullable, nonatomic, retain) VMZOweData *owe;

@end

NS_ASSUME_NONNULL_END

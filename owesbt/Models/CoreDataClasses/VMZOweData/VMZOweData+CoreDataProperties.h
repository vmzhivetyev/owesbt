//
//  VMZOweData+CoreDataProperties.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 19.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface VMZOweData (CoreDataProperties)

+ (NSFetchRequest<VMZOweData *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *closed;
@property (nullable, nonatomic, copy) NSDate *created;
@property (nullable, nonatomic, copy) NSString *creditor;
@property (nullable, nonatomic, copy) NSString *debtor;
@property (nullable, nonatomic, copy) NSString *descr;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *sum;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, copy) NSString *partnerName;

@end

NS_ASSUME_NONNULL_END

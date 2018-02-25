//
//  VMZCoreDataManager.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class VMZOweData;
@class VMZOweAction;
@class VMZOweGroup;
@class VMZContact;

NS_ASSUME_NONNULL_BEGIN

@interface VMZCoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSPersistentContainer *persistentContainer;
@property (nonatomic, weak, readonly) NSManagedObjectContext *managedObjectContext;

- (NSArray<VMZOweData *> *)owesForStatus:(NSString *)status
                            selfIsDebtor:(BOOL)selfIsDebtor;

- (void)updateOwes:(NSArray *)owesArray
            status:(NSString *)status;

- (void)addNewAction:(NSString *)action
          parameters:(NSDictionary *)params
                 owe:(VMZOweData *)owe;

- (void)addNewOweWithActionFor:(NSString *)partner
                 whichIsDebtor:(BOOL)partnerIsDebtor
                           sum:(NSString *)sum
                         descr:(NSString *)descr;

- (NSArray *)getActions;

- (void)removeAction:(VMZOweAction *)action;

- (NSArray<VMZOweGroup *> *)groups;
- (VMZOweGroup *)createGroupWithName:(NSString *)name members:(NSArray<VMZContact *> *)members;

- (void)clearCoreData;

@end

NS_ASSUME_NONNULL_END

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
@class VMZOweDataController;

NS_ASSUME_NONNULL_BEGIN

@interface VMZCoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSPersistentContainer *persistentContainer;
@property (nonatomic, weak, readonly) NSManagedObjectContext *managedObjectContext;

- (instancetype)init;
- (void)clearCoreData;

@end


@interface VMZCoreDataManager (Owes)

- (void)addNewOweWithActionFor:(NSString *)partner
                 whichIsDebtor:(BOOL)partnerIsDebtor
                           sum:(NSString *)sum
                         descr:(NSString *)descr;

- (NSArray<VMZOweData *> *)owesForStatus:(NSString *)status
                            selfIsDebtor:(BOOL)selfIsDebtor;

- (void)updateOwes:(NSArray *)owesArray
            status:(NSString *)status;


@end


@interface VMZCoreDataManager (Groups)

- (VMZOweGroup *)createGroupWithName:(NSString *)name
                             members:(NSArray<VMZContact *> *)members;

- (NSArray<VMZOweGroup *> *)groups;

- (void)updateGroups:(NSArray *)groupsArray;

@end


@interface VMZCoreDataManager (Actions)

- (void)addNewAction:(NSString *)action
          parameters:(NSDictionary *)params
                 owe:(VMZOweData *)owe;

- (NSArray *)actions;

- (void)removeAction:(VMZOweAction *)action;

@end


NS_ASSUME_NONNULL_END

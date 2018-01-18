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


@interface VMZCoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSPersistentContainer *persistentContainer;
@property (nonatomic, weak, readonly) NSManagedObjectContext *managedObjectContext;

- (void)saveManagedObjectContext;

- (NSArray *_Nonnull)owesForStatus:(NSString *_Nonnull)status selfIsDebtor:(BOOL)selfIsDebtor;
- (void)updateOwes:(NSArray * _Nonnull)owesArray;
- (void)addNewAction:(NSString *_Nonnull)action parameters:(NSDictionary *_Nonnull)params owe:(VMZOweData *_Nonnull)owe;
- (void)addNewOweWithActionFor:(NSString * _Nonnull)partner
                 whichIsDebtor:(BOOL)partnerIsDebtor
                           sum:(NSString * _Nonnull)sum
                         descr:(NSString * _Nonnull)descr;
- (NSArray * _Nullable)getActions;
- (void)removeAction:(VMZOweAction *_Nonnull)action;

@end

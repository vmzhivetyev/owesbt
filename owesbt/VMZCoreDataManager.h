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


@interface VMZCoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSPersistentContainer *persistentContainer;
@property (nonatomic, weak, readonly) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedInstance;

- (NSArray *)owesForStatus:(NSString *)status selfIsDebtor:(BOOL)selfIsDebtor;
- (void)updateOwes:(nonnull NSArray *)owesArray;
- (void)closeOwe:(nonnull VMZOweData *)owe;
- (void)confirmOwe:(nonnull VMZOweData *)owe;
- (void)cancelRequestForOwe:(nonnull VMZOweData *)owe;

@end

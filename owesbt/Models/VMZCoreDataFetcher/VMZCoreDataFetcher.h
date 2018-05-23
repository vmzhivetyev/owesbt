//
//  VMZCoreDataFetcher.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 26.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/*
@protocol VMZCoreDataObjectsFetcherDelegate <NSObject>

@required
- (void)contextChanged;

@end*/


@interface VMZCoreDataFetcher<__covariant ObjectType> : NSObject

@property (nonatomic, weak, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy, readonly) NSString *entityName;

//@property (nonatomic, weak) id<VMZCoreDataObjectsFetcherDelegate> delegate;

//- (void)contextChanged;



- (instancetype)initWithEntityName:(NSString *)entityName
              managedObjectContext:(NSManagedObjectContext *)moc;

- (ObjectType)createNewObject;

- (NSFetchRequest *)fetchRequest;
- (NSArray<ObjectType> *)fetchObjects;
- (ObjectType)fetchOrCreateUniqueObjectWithPredicate:(NSString *)predicate;
- (NSArray<ObjectType> *)executeSortedFetchRequestWithPredicate:(NSString *)predicate;
- (NSArray<ObjectType> *)executeFetchRequest:(NSFetchRequest *)request
                          withSortDescriptor:(NSSortDescriptor *)sort
                                       error:(NSError * __autoreleasing *)error;

- (void)deleteObjectsFromCoreData;

@end

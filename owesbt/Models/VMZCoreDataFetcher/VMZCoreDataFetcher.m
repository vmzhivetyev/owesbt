//
//  VMZCoreDataFetcher.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 26.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZCoreDataFetcher.h"


@implementation VMZCoreDataFetcher


//#pragma mark - delegate
//
//- (void)contextChanged
//{
//    if(self.delegate)
//    {
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self.delegate contextChanged];
//        });
//    }
//}


#pragma mark - Lifecycle

- (instancetype)initWithEntityName:(NSString *)entityName
              managedObjectContext:(NSManagedObjectContext *)moc
{
    self = [super init];
    if (self)
    {
        _entityName = entityName;
        _managedObjectContext = moc;
    }
    return self;
}


#pragma mark - Public Instantiating

- (id)createNewObject
{
    id obj = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                           inManagedObjectContext:self.managedObjectContext];
    return obj;
}


#pragma mark - Public Fetching

- (NSFetchRequest *)fetchRequest
{
    return [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
}

- (id)fetchOrCreateUniqueObjectWithPredicate:(NSString *)predicate;
{
    NSArray *results = [self executeSortedFetchRequestWithPredicate:predicate];
    
    for (NSInteger i = 1; i < results.count; i++)
    {
        [self.managedObjectContext deleteObject:results[i]];
    }
    
    return results.count == 0 ? [self createNewObject] : results[0];
}

- (NSArray *)fetchObjects
{
    NSArray *results = [self executeSortedFetchRequestWithPredicate:nil];
    
    return results;
}

- (NSArray *)executeFetchRequestWithSortDescriptor:(NSSortDescriptor *)sort
                                             error:(NSError * __autoreleasing *)error
{
    NSFetchRequest *request = [self fetchRequest];
    [request setSortDescriptors:@[sort]];
    
    __block NSArray *results = @[];
    [self.managedObjectContext performBlockAndWait:^{
        results = [self.managedObjectContext executeFetchRequest:request error:error];
    }];
    
    return results;
}

- (NSArray *)executeSortedFetchRequestWithPredicate:(NSString *)predicate
{
    NSFetchRequest *request = [self fetchRequest];
    if (predicate)
    {
        [request setPredicate:[NSPredicate predicateWithFormat:predicate]];
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES];
    
    NSError *error = nil;
    NSArray *results = [self executeFetchRequestWithSortDescriptor:sort
                                                             error:&error];
    
    NSLog(@"Fetching error: %@", error);
    
    return results;
}

- (void)deleteObjectsFromCoreData
{
    __block NSArray *results;
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error;
        results = [self.managedObjectContext executeFetchRequest:[self fetchRequest] error:&error];
    }];
    
    for(NSManagedObject *obj in results)
    {
        [self.managedObjectContext deleteObject:obj];
    }
}

@end

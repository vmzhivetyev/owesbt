//
//  VMZCoreDataManager.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZCoreDataManager.h"
#import "VMZOweData+CoreDataClass.h"
#import "VMZOweAction+CoreDataClass.h"
#import "VMZOweGroup+CoreDataClass.h"
#import "VMZOweController.h"
#import "NSString+Formatting.h"
#import "VMZOweNetworking.h"
#import "VMZContact.h"
#import "NSArray+LambdaSelect.h"

@implementation VMZCoreDataManager


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DataModel"];
        [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
            if (error != nil)
            {
                NSLog(@"Failed to load Core Data stack: %@", error);
                abort();
            }
            else
            {
                _managedObjectContext = _persistentContainer.viewContext;
            }
        }];
    }
    return self;
}

- (BOOL)saveManagedObjectContext
{
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError])
    {
        NSLog(@"CoreData save error: %@", saveError.localizedDescription);
        return NO;
    }
    else
    {
        return YES;
    }
}

- (VMZOweData *)createNewOweObject
{
    return [VMZOweData newOweInManagedObjectContext:self.managedObjectContext];
}

- (NSArray<VMZOweData *> *)getOwesWithPredicate:(NSString*)predicate
{
    NSFetchRequest *fetchRequest = [VMZOweData fetchRequest];
    if (predicate)
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate]];
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES];
    
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:fetchRequest
                              withSortDescriptor:sort
                                           error:&error];
    
    NSLog(@"Fetching error: %@", error);
    
    for (VMZOweData *owe in results)
    {
        if (!owe.partnerName)
        {
            [owe updatePartnerName];
        }
    }
    
    return results;
}


#pragma mark - Public

- (NSArray<VMZOweData *> *)owesForStatus:(NSString *)status selfIsDebtor:(BOOL)selfIsDebtor
{
    NSMutableString* predicate = [NSMutableString stringWithFormat:@"(status = '%@')", status];
    if (selfIsDebtor)
    {
        [predicate appendString:@" && (debtor = 'self')"];
    }
    else
    {
        [predicate appendString:@" && (debtor != 'self')"];
    }
    
    return [self getOwesWithPredicate:predicate];
}

- (void)updateOwes:(NSArray*)owesArray status:(NSString *)status
{
    NSMutableSet<VMZOweData *> *set = [NSMutableSet new];
    for (NSDictionary *oweDict in owesArray)
    {
        NSString *predicate = [NSString stringWithFormat:@"uid = '%@'", oweDict[@"id"]];
        NSArray *coreDataOwe = [self getOwesWithPredicate:predicate];
       
        for (NSInteger i = 1; i < coreDataOwe.count; i++)
        {
            [self.managedObjectContext deleteObject:coreDataOwe[i]];
        }
        
        VMZOweData *oweData = coreDataOwe.count == 0 ? [self createNewOweObject] : coreDataOwe[0];
        [oweData loadFromDictionary:oweDict];
        [set addObject:oweData];
    }
    
    NSString *predicate = [NSString stringWithFormat:@"status = '%@'", status];
    NSArray *owesWithStatus = [self getOwesWithPredicate:predicate];
    for (VMZOweData *owe in owesWithStatus)
    {
        if (![set containsObject:owe])
        {
            [self.managedObjectContext deleteObject:owe];
        }
    }
    
    [self saveManagedObjectContext];
    [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
}

- (void)addNewAction:(NSString *)action parameters:(NSDictionary *)params owe:(VMZOweData *)owe
{
    [VMZOweAction createNewActionObject:action withParameters:params forOwe:owe managedObjectContext:self.managedObjectContext];
    [[VMZOweController sharedInstance].networking doOweActionsAsync];
}

- (void)addNewOweWithActionFor:(NSString *)partner whichIsDebtor:(BOOL)partnerIsDebtor sum:(NSString*)sum descr:(NSString *)descr
{
    VMZOweData *owe = [self createNewOweObject];
    owe.created = [NSDate date];
    owe.closed = nil;
    owe.creditor = partnerIsDebtor ? @"self" : partner.copy;
    owe.debtor = !partnerIsDebtor ? @"self" : partner.copy;
    owe.descr = descr.copy;
    owe.statusType = partnerIsDebtor ? VMZOweStatusRequested : VMZOweStatusActive;
    owe.uid = nil;
    owe.sum = sum.copy;
    
    NSDictionary *params = @{@"who":owe.debtor.copy, @"to":owe.creditor.copy, @"sum":owe.sum.copy, @"descr":owe.descr.copy};
    [self addNewAction:@"addOwe" parameters:params owe:owe];
    
    [self saveManagedObjectContext];
    [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request
              withSortDescriptor:(NSSortDescriptor *)sort
                           error:(NSError * __autoreleasing *)error
{
    __block NSArray *results = @[];
    
    [request setSortDescriptors:@[sort]];
    
    [self.managedObjectContext performBlockAndWait:^{
        results = [self.managedObjectContext executeFetchRequest:request error:error];
    }];
    
    return results;
}

- (NSArray *)getActions
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES];
    
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:[VMZOweAction fetchRequest]
                              withSortDescriptor:sort
                                           error:&error];
    
    NSLog(@"Fetching error: %@", error);
    NSLog(@"ACTIONS: %ld", results.count);
    
    return results;
}

- (void)removeAction:(VMZOweAction *)action
{
    [self.managedObjectContext deleteObject:action];
    [self saveManagedObjectContext];
}

- (NSArray<VMZOweGroup *> *)groups
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:[VMZOweGroup fetchRequest]
                              withSortDescriptor:sort
                                           error:&error];
    
    NSLog(@"Fetching error: %@", error);
    
    return results;
}

- (VMZOweGroup *)createGroupWithName:(NSString *)name members:(NSArray<VMZContact *> *)members
{
    VMZOweGroup *group = [VMZOweGroup newInManagedObjectContext:self.managedObjectContext];
    
    group.name = name.copy;
    group.uid = [NSUUID UUID].UUIDString;
    group.members = [members ls_arrayWithSelect:^id(VMZContact *obj, NSUInteger idx) {
        return obj.phone.copy;
    }];
    
    [self saveManagedObjectContext];
    [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
    
    return group;
}

- (void)deleteObjectsFromCoreData:(NSFetchRequest *)request
{
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        for(NSManagedObject *obj in results)
        {
            [self.managedObjectContext deleteObject:obj];
        }
    }];
}

- (void)clearCoreData
{
    [self deleteObjectsFromCoreData:[VMZOweData fetchRequest]];
    [self deleteObjectsFromCoreData:[VMZOweAction fetchRequest]];
    [self deleteObjectsFromCoreData:[VMZOweGroup fetchRequest]];
    
    [self saveManagedObjectContext];
}

@end

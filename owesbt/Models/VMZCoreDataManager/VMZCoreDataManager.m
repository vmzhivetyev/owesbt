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
#import "VMZOweController.h"
#import "NSString+VMZExtensions.h"

@implementation VMZCoreDataManager

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

- (void)saveManagedObjectContext
{
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError])
    {
        NSLog(@"CoreData save error: %@", saveError.localizedDescription);
    }
    else
    {
        [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
    }
}

- (NSArray *)owesForStatus:(NSString *)status selfIsDebtor:(BOOL)selfIsDebtor
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

- (NSArray *)getOwesWithPredicate:(NSString*)predicate {
    __block NSArray *results = nil;
    
    NSFetchRequest *fetchRequest = [VMZOweData fetchRequest];
    if (predicate)
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate]];
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSLog(@"Fetching error: %@", error);
    }];
    
    return results;
}

- (void)updateOwes:(NSArray*)owesArray
{
    NSString *predicate = [NSString stringWithFormat:@"status = '%@'", [owesArray[0] valueForKey:@"status"]];
    
    [[self getOwesWithPredicate:predicate] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Deleting %@",((VMZOweData*)obj).uid);
        [self.managedObjectContext deleteObject:obj];
    }];
    
    [owesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VMZOweData *newManagedObject = [self createNewOweObject];
        [newManagedObject loadFromDictionary:obj];
        NSLog(@"Added %@", newManagedObject.uid);
    }];
    
    [self saveManagedObjectContext];
}

- (VMZOweData *)createNewOweObject
{
    return [VMZOweData newOweInManagedObjectContext:self.managedObjectContext];
}

- (void)addNewAction:(NSString *)action parameters:(NSDictionary *)params owe:(VMZOweData *)owe
{
    [VMZOweAction newAction:action withParameters:params forOwe:owe managedObjectContext:self.managedObjectContext];
}

- (void)addNewOweWithActionFor:(NSString *)partner whichIsDebtor:(BOOL)partnerIsDebtor sum:(NSString*)sum descr:(NSString *)descr
{
    VMZOweData *owe = [self createNewOweObject];
    owe.created = [NSDate date];
    owe.closed = nil;
    owe.creditor = partnerIsDebtor ? @"self" : partner.copy;//.phoneNumberDigits;
    owe.debtor = !partnerIsDebtor ? @"self" : partner.copy;//.phoneNumberDigits;
    owe.descr = descr.copy;
    owe.status = partnerIsDebtor ? @"requested" : @"active";
    owe.uid = nil;
    owe.sum = sum.copy;
    
    NSDictionary *params = @{@"who":owe.debtor.copy, @"to":owe.creditor.copy, @"sum":owe.sum.copy, @"descr":owe.descr.copy};
    [self addNewAction:@"addOwe" parameters:params owe:owe];
    
    [self saveManagedObjectContext];
}

- (NSArray *)getActions
{
    __block NSArray *results = nil;
    
    NSFetchRequest *fetchRequest = [VMZOweAction fetchRequest];
    //fetchRequest.fetchLimit = 1;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSLog(@"Fetching error: %@", error);
    }];
    
    NSLog(@"ACTIONS: %ld", [results count]);
    
    return results;//[results count] > 0 ? results[0] : nil;
}

- (void)removeAction:(VMZOweAction *)action
{
    [self.managedObjectContext deleteObject:action];
}

@end

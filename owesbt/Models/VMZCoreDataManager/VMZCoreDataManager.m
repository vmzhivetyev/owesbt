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
#import "VMZCoreDataFetcher.h"


@interface VMZCoreDataManager ()

@property (nonatomic, strong, readonly) VMZCoreDataFetcher<VMZOweData *> *oweDataFetcher;
@property (nonatomic, strong, readonly) VMZCoreDataFetcher<VMZOweGroup *> *oweGroupFetcher;
@property (nonatomic, strong, readonly) VMZCoreDataFetcher<VMZOweAction *> *oweActionsFetcher;

@end


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
                _oweDataFetcher = [[VMZCoreDataFetcher alloc]
                                      initWithEntityName:VMZOweData.entity.name
                                   managedObjectContext:self.managedObjectContext];
            }
        }];
    }
    return self;
}

- (BOOL)saveManagedObjectContext
{
    NSError *saveError = nil;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&saveError])
    {
        NSLog(@"CoreData save error: %@", saveError.localizedDescription);
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)clearCoreData
{
    [self.oweDataFetcher deleteObjectsFromCoreData];
    [self.oweGroupFetcher deleteObjectsFromCoreData];
    [self.oweActionsFetcher deleteObjectsFromCoreData];
    
    [self saveManagedObjectContext];
    [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
}

@end


@implementation VMZCoreDataManager (Owes)

//creating
- (void)addNewOweWithActionFor:(NSString *)partner
                 whichIsDebtor:(BOOL)partnerIsDebtor
                           sum:(NSString*)sum
                         descr:(NSString *)descr
{
    VMZOweData *owe = [self.oweDataFetcher createNewObject];
    owe.created = [NSDate date];
    owe.closed = nil;
    owe.creditor = partnerIsDebtor ? @"self" : partner.copy;
    owe.debtor = !partnerIsDebtor ? @"self" : partner.copy;
    owe.descr = descr.copy;
    owe.statusType = partnerIsDebtor ? VMZOweStatusRequested : VMZOweStatusActive;
    owe.uid = nil;
    owe.sum = sum.copy;
    
    NSDictionary *params = @{@"who":owe.debtor.copy,
                             @"to":owe.creditor.copy,
                             @"sum":owe.sum.copy,
                             @"descr":owe.descr.copy};
    
    [self addNewAction:@"addOwe" parameters:params owe:owe];
    
    [self saveManagedObjectContext];
    [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
}

//getting
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
    
    NSArray* results = [self.oweDataFetcher executeSortedFetchRequestWithPredicate:predicate];
    
    for (VMZOweData *owe in results)
    {
        if (!owe.partnerName)
        {
            [owe updatePartnerName];
        }
    }
    
    return results;
}

//updating
- (void)updateOwes:(NSArray*)owesArray
            status:(NSString *)status
{
    NSMutableSet<NSManagedObject *> *set = [NSMutableSet new];
    for (NSDictionary *oweDict in owesArray)
    {
        NSString *predicate = [NSString stringWithFormat:@"uid = '%@'", oweDict[@"id"]];
        VMZOweData *oweData = [self.oweDataFetcher
                               fetchOrCreateUniqueObjectWithPredicate:predicate];
        
        if (!oweData)
        {
            oweData = [self.oweDataFetcher createNewObject];
        }
        
        [oweData loadFromDictionary:oweDict];
        [set addObject:oweData];
    }
    
    NSString *predicateForStatus = [NSString stringWithFormat:@"status = '%@'", status];
    NSArray *owesWithStatus = [self.oweDataFetcher
                               executeSortedFetchRequestWithPredicate:predicateForStatus];
    for (NSManagedObject *owe in owesWithStatus)
    {
        if (![set containsObject:owe])
        {
            [self.managedObjectContext deleteObject:owe];
        }
    }
    
    [self saveManagedObjectContext];
    [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
}


@end


@implementation VMZCoreDataManager (Groups)

- (NSArray<VMZOweGroup *> *)getGroupsWithPredicate:(NSString *)predicate
{
    return [self.oweGroupFetcher executeSortedFetchRequestWithPredicate:predicate];
}

//creating
- (VMZOweGroup *)createGroupWithName:(NSString *)name
                             members:(NSArray<VMZContact *> *)members
{
    VMZOweGroup *group = [self.oweGroupFetcher createNewObject];
    
    group.name = name.copy;
    group.uid = [NSUUID UUID].UUIDString;
    group.members = [members ls_arrayWithSelect:^id(VMZContact *obj, NSUInteger idx) {
        return obj.phone.copy;
    }];
    
    [self saveManagedObjectContext];
    [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
    
    return group;
}

//getting
- (NSArray<VMZOweGroup *> *)groups
{
    return [self.oweGroupFetcher executeSortedFetchRequestWithPredicate:nil];
}

//updating
- (void)updateGroups:(NSArray*)newArray
{
    [self.oweGroupFetcher deleteObjectsFromCoreData];
    
    for (NSDictionary *dict in newArray)
    {
        VMZOweGroup *group = [self.oweGroupFetcher createNewObject];
        [group loadFromDictionary:dict];
    }
    
    [self saveManagedObjectContext];
    [[VMZOweController sharedInstance] VMZOwesCoreDataDidUpdate];
}

@end


@implementation VMZCoreDataManager (Actions)

//creating
- (void)addNewAction:(NSString *)action
          parameters:(NSDictionary *)params
                 owe:(VMZOweData *)owe
{
    [VMZOweAction createNewActionObject:action withParameters:params forOwe:owe managedObjectContext:self.managedObjectContext];
    [[VMZOweController sharedInstance].networking doOweActionsAsync];
}

//getting
- (NSArray<VMZOweAction *> *)actions
{
    return [self.oweActionsFetcher executeSortedFetchRequestWithPredicate:nil];
}

//updating
- (void)removeAction:(VMZOweAction *)action
{
    [self.managedObjectContext deleteObject:action];
    [self saveManagedObjectContext];
}

@end

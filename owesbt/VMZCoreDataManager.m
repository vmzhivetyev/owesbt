//
//  VMZCoreDataManager.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZCoreDataManager.h"
#import "VMZOweData+CoreDataClass.h"
#import "VMZOwe.h"

@implementation VMZCoreDataManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

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
    
    return [self managedObjectsForClass:@"Owe" predicateFormat:predicate];
}

- (NSArray *)managedObjectsForClass:(NSString *)className predicateFormat:(NSString*)predicate {
    __block NSArray *results = nil;
    
    NSManagedObjectContext *moc = self.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [VMZOweData fetchRequest];
    if (predicate)
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate]];
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    
    [moc performBlockAndWait:^{
        NSError *error = nil;
        results = [moc executeFetchRequest:fetchRequest error:&error];
        NSLog(@"Fetching error: %@", error);
    }];
    
    return results;
}

- (void)updateOwes:(NSArray*)owesArray
{
    NSManagedObjectContext *moc = self.persistentContainer.viewContext;
    
    NSString *predicate = [NSString stringWithFormat:@"status = '%@'", [owesArray[0] valueForKey:@"status"]];
    
    [[self managedObjectsForClass:@"Owe" predicateFormat:predicate] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Deleting %@",((VMZOweData*)obj).uid);
        [moc deleteObject:obj];
    }];
    
    [owesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VMZOweData *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Owe" inManagedObjectContext:moc];
        [newManagedObject loadFromDictionary:obj];
        NSLog(@"Added %@", newManagedObject.uid);
    }];
    
    NSError *saveError = nil;
    if (![moc save:&saveError])
    {
        NSLog(@"CoreData save error: %@", saveError.localizedDescription);
    }
    else
    {
        [[VMZOwe sharedInstance] VMZOwesDataDidUpdate];
    }
}

@end

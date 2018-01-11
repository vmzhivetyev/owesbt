//
//  VMZCoreDataManager.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZCoreDataManager.h"
#import "VMZOweData+CoreDataClass.h"

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

- (NSArray *)managedObjectsForClass:(NSString *)className withId:(NSString*)uid {
    __block NSArray *results = nil;
    
    NSManagedObjectContext *moc = self.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [VMZOweData fetchRequest];
    if (uid)
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uid = %s", uid]];
    }
    
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
    
    [[self managedObjectsForClass:@"Owe" withId:nil] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
}

@end

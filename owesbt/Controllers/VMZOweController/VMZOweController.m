//
//  VMZOweController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOweController.h"
#import "VMZCoreDataManager.h"
#import "VMZOweNetworking.h"
#import "VMZOweData+CoreDataClass.h"
#import "VMZOweAuth.h"
#import "VMZUIController.h"


@interface VMZOweController ()

@end


@implementation VMZOweController


#pragma mark - LifeCycle

+ (VMZOweController*)sharedInstance
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
        [self initInstances];
        [self subscribeForNotificationCenter];
    }
    return self;
}

- (void)dealloc
{
    [self unsubscribeFromNotificationCenter];
}

- (void)initInstances
{
    _coreDataManager = [[VMZCoreDataManager alloc] init];
    _networking = [[VMZOweNetworking alloc] initWithCoreDataManager:_coreDataManager];
    _auth = [[VMZOweAuth alloc] init];
    _uiController = [[VMZUIController alloc] init];
}

- (void)subscribeForNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signedOut)
                                                 name:VMZNotificationAuthSignedOut
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signedOut)
                                                 name:VMZNotificationAuthNilUser
                                               object:nil];
}

- (void)unsubscribeFromNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - NSNotificationCenter Selectors

- (void)signedOut
{
    [self.coreDataManager clearCoreData];
    [self.networking clearCachedPhoneNumber];
}


#pragma mark - VMZOweDelegate

- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success
{
    if ([self.delegate respondsToSelector:@selector(VMZPhoneNumberCheckedWithResult:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate VMZPhoneNumberCheckedWithResult:success];
        });
    }
}

- (void)VMZOwesCoreDataDidUpdate
{
    if ([self.delegate respondsToSelector:@selector(VMZOwesCoreDataDidUpdate)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate VMZOwesCoreDataDidUpdate];
        });
    }
}

- (void)VMZOweErrorOccured:(NSString *)error
{
    if ([self.delegate respondsToSelector:@selector(VMZOweErrorOccured:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate VMZOweErrorOccured:error];
        });
    }
}

#pragma mark - Public

- (void)loggedInViewControllerDidLoad
{
    [self.networking startActionsTimer];
}

- (void)setMyPhone:(NSString *)phone completion:(void(^)(NSString *errorText))completion
{
    [self.networking setMyPhone:phone completion:completion];
}

@end


@implementation VMZOweController (ActionsWithOwes)

- (void)refreshOwesWithStatus:(NSString *)status completion:(void(^)(NSError *error))completion
{
    [self.networking downloadOwes:status completion:completion];
}

- (void)closeOwe:(VMZOweData *)owe
{
    if (![owe selfIsCreditor])
    {
        NSLog(@"Error: trying to CLOSE owe by debtor");
        return;
    }

    if (owe.statusType == VMZOweStatusActive)
    {
        owe.statusType = VMZOweStatusClosed;
    }
    
    [self.coreDataManager addNewAction:@"changeOwe"
                                           parameters:@{@"id":owe.uid.copy, @"action":@"close"}
                                                  owe:owe];
}

- (void)confirmOwe:(VMZOweData *)owe
{
    if ([owe selfIsCreditor])
    {
        NSLog(@"Error: trying to CONFIRM owe by creditor");
        return;
    }
    
    if (owe.statusType == VMZOweStatusRequested)
    {
        owe.statusType = VMZOweStatusActive;
    }
    
    [self.coreDataManager addNewAction:@"changeOwe"
                                           parameters:@{@"id":owe.uid.copy, @"action":@"confirm"}
                                                  owe:owe];
}

- (void)cancelOwe:(VMZOweData *)owe
{
    if (owe.statusType == VMZOweStatusRequested)
    {
        owe.statusType = VMZOweStatusClosed;
    }
    
    [self.coreDataManager addNewAction:@"changeOwe"
                                           parameters:@{@"id":owe.uid.copy, @"action":@"cancel"}
                                                  owe:owe];
}

- (void)addNewOweFor:(NSString *)partner whichIsDebtor:(BOOL)partnerIsDebtor sum:(NSString*)sum descr:(NSString *)descr
{
    [self.coreDataManager addNewOweWithActionFor:partner whichIsDebtor:partnerIsDebtor sum:sum descr:descr];
}

@end


@implementation VMZOweController (ActionsWithGroups)

- (void)refreshGroupsWithCompletion:(void(^)(NSError *error))completion
{
    [self.networking downloadGroupsWithCompletion:completion];
}

- (void)createGroupWithName:(NSString *)name members:(NSArray<VMZContact *> *)members
{
    VMZOweGroup *group = [self.coreDataManager createGroupWithName:name members:members];
    
    [self.networking ];
}

- (void)deleteGroup:(VMZOweGroup *)group
{
    
}

@end

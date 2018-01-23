//
//  VMZOweController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Firebase.h>
#import <GoogleSignIn/GoogleSignIn.h>

#import "VMZOweController.h"
#import "VMZCoreDataManager.h"
#import "VMZOweNetworking.h"
#import "VMZOweData+CoreDataClass.h"

@interface VMZOweController ()

@property (nonatomic, strong) NSPointerArray * _Nonnull delegates;

@property (nonatomic, strong) id<NSObject> firebaseAuthStateDidChangeHandler;

@end


@implementation VMZOweController

- (void)checkPhoneNumberForFIRUser:(FIRUser *)user
{
    [self VMZAuthDidSignInForUser:user withError:nil];
    
    [self.networking getMyPhoneWithCompletion:^(NSString * _Nullable phone, NSError * error) {
        NSLog(@"Got my phone: %@",phone);
        
        [self VMZPhoneNumberCheckedWithResult: phone != nil];
        
        [self VMZOweErrorOccured:error.localizedDescription];
    }];
}

- (void)FIRAuthStateChangedForUser:(FIRUser *)user
{
    NSLog(@"Auth state changed %@", user);
    
    if(user)
    {
        [self checkPhoneNumberForFIRUser:user];
    }
    else
    {
        [self.networking clearCachedPhoneNumber];
        [self VMZAuthDidSignInForUser:nil withError:nil];
    }
}

- (void)createFirebaseAuthStateListener
{
    if (!self.firebaseAuthStateDidChangeHandler)
    {
        self.firebaseAuthStateDidChangeHandler =
        [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
            [self FIRAuthStateChangedForUser:user];
        }];
    }
}


#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error
{
    if (error == nil)
    {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        
        // и теперь авторизуемся в firebase с помощью гугловкого credential
        
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
            if (error)
            {
                [self VMZAuthDidSignInForUser:user withError:error];
            }
        }];
    }
    else
    {
        [self VMZAuthDidSignInForUser:nil withError:error];
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error
{
    
}


#pragma mark - VMZOweDelegate

- (void)VMZAuthDidSignInForUser:(FIRUser*)user withError:(NSError*)error
{
    for (NSObject<VMZOweDelegate> *delegate in self.delegates)
    {
        if ([delegate respondsToSelector:@selector(VMZAuthDidSignInForUser:withError:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate VMZAuthDidSignInForUser:user withError:error];
            });
        }
    }
}

- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success
{
    for (NSObject<VMZOweDelegate> *delegate in self.delegates)
    {
        if ([delegate respondsToSelector:@selector(VMZPhoneNumberCheckedWithResult:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate VMZPhoneNumberCheckedWithResult:success];
            });
        }
    }
}

- (void)VMZOwesCoreDataDidUpdate
{
    for (NSObject<VMZOweDelegate> *delegate in self.delegates)
    {
        if ([delegate respondsToSelector:@selector(VMZOwesCoreDataDidUpdate)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate VMZOwesCoreDataDidUpdate];
            });
        }
    }
}

- (void)VMZOweErrorOccured:(NSString *)error
{
    for (NSObject<VMZOweDelegate> *delegate in self.delegates)
    {
        if ([delegate respondsToSelector:@selector(VMZOweErrorOccured:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate VMZOweErrorOccured:error];
            });
        }
    }
}

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
        _delegates = [NSPointerArray new];
        _coreDataManager = [[VMZCoreDataManager alloc] init];
        _networking = [[VMZOweNetworking alloc] initWithCoreDataManager:_coreDataManager];
    }
    return self;
}

- (void)dealloc
{
    [[FIRAuth auth] removeAuthStateDidChangeListener:self.firebaseAuthStateDidChangeHandler];
}

#pragma mark - Public

- (void)addDelegate:(nonnull NSObject<VMZOweDelegate> *)delegate
{
    [self.delegates addPointer:(__bridge void * _Nullable)(delegate)];
    
    [self createFirebaseAuthStateListener];
}

- (void)removeDelegate:(nonnull NSObject<VMZOweDelegate> *)delegate
{
    for(int i = 0; i < self.delegates.count; i++)
    {
        if(delegate == [self.delegates pointerAtIndex:i])
        {
            [self.delegates removePointerAtIndex: i];
            return;
        }
    }
    //@throw @"Your are trying to delete unexisting pointer from delegates.";
}

- (void)loggedInViewControllerDidLoad
{
    [[self networking] startActionsTimer];
}

- (void)setMyPhone:(NSString *)phone completion:(void(^)(NSString *errorText))completion
{
    [[self networking] setMyPhone:phone completion:completion];
}

- (void)refreshOwesWithStatus:(NSString *)status completion:(void(^)(NSError *error))completion
{
    [[self networking] downloadOwes:status completion:completion];
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

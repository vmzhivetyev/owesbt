//
//  VMZOweAuth.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 28.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOweAuth.h"

#import <Firebase.h>
#import <GoogleSignIn/GoogleSignIn.h>

#import "VMZOweNetworking.h"
#import "VMZOweController.h"


@interface VMZOweAuth ()

@property (nonatomic, strong, readonly) id<NSObject> firebaseAuthStateDidChangeHandler;

@end


@implementation VMZOweAuth


- (void)setDelegate:(id<VMZOweAuthDelegate>)delegate
{
    _delegate = delegate;
    
    //[GIDSignIn sharedInstance].uiDelegate = delegate;
    
    [self createFirebaseAuthStateChangeListener];
}


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
        [GIDSignIn sharedInstance].delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [self removeFirebaseAuthStateListener];
}

- (void)createFirebaseAuthStateChangeListener
{
    if (!self.firebaseAuthStateDidChangeHandler)
    {
        _firebaseAuthStateDidChangeHandler =
        [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
            [self VMZAuthStateChangedForUser:user withError:nil];
        }];
    }
    else
    {
        [self VMZAuthStateChangedForUser:[FIRAuth auth].currentUser withError:nil];
    }
}

- (void)removeFirebaseAuthStateListener
{
    [[FIRAuth auth] removeAuthStateDidChangeListener:self.firebaseAuthStateDidChangeHandler];
}


#pragma mark - VMZOweAuthDelegate

- (void)VMZAuthStateChangedForUser:(FIRUser*)user withError:(NSError*)error
{
    if ([self.delegate respondsToSelector:@selector(VMZAuthStateChangedForUser:withError:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate VMZAuthStateChangedForUser:user withError:error];
        });
    }
    
    [[VMZOweController sharedInstance].networking VMZAuthStateChangedForUser:user withError:error];
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
                [self VMZAuthStateChangedForUser:user withError:error];
            }
        }];
    }
    else
    {
        [self VMZAuthStateChangedForUser:nil withError:error];
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error
{
    
}

@end

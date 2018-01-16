//
//  VMZOwe.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Firebase.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "VMZOwe.h"
#import "VMZOweData+CoreDataClass.h"
#import "UIViewController+Extension.h"
#import "VMZCoreDataManager.h"

@interface VMZOwe ()

@property (nonatomic, strong) id<NSObject> firebaseAuthStateDidChangeHandler;
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *actionsQueue;

@end


@implementation VMZOwe


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
    if ([self.uiDelegate respondsToSelector:@selector(VMZAuthDidSignInForUser:withError:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.uiDelegate VMZAuthDidSignInForUser:user withError:error];
        });
    }
}

- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success
{
    if ([self.uiDelegate respondsToSelector:@selector(VMZPhoneNumberCheckedWithResult:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.uiDelegate VMZPhoneNumberCheckedWithResult:success];
        });
    }
}

- (void)VMZOwesCoreDataDidUpdate
{
    if ([self.uiDelegate respondsToSelector:@selector(VMZOwesCoreDataDidUpdate)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.uiDelegate VMZOwesCoreDataDidUpdate];
        });
    }
}


#pragma mark - LifeCycle

+ (VMZOwe*)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)setUiDelegate:(UIViewController<VMZOweUIDelegate> *)uiDelegate
{
    _uiDelegate = uiDelegate;
    
    if (!self.firebaseAuthStateDidChangeHandler)
    {
        self.firebaseAuthStateDidChangeHandler =
        [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
            NSLog(@"Auth state changed %@", user);
            
            if(user)
            {
                [self VMZAuthDidSignInForUser:user withError:nil];
                
                [self getMyPhoneWithCompletion:^(NSString * _Nullable phone) {
                    NSLog(@"Got my phone: %@",phone);
                    
                    [self VMZPhoneNumberCheckedWithResult: phone != nil];
                }];
            }
            else
            {
                [self clearCachedPhoneNumber];
                [self VMZAuthDidSignInForUser:nil withError:nil];
            }
        }];
    }
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _actionsQueue = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
    [[FIRAuth auth] removeAuthStateDidChangeListener:self.firebaseAuthStateDidChangeHandler];
}

#pragma mark - FirebaseNetworking

- (NSString*)firebaseUrlForFunction:(NSString *_Nonnull)function withParameters:(NSDictionary *_Nullable)parameters
{
    if (parameters)
    {
        NSMutableString *resultUrl = [[NSMutableString alloc] initWithString:function];
        [resultUrl appendString:@"?"];
        for (NSString *param in parameters)
        {
            NSString *value = parameters[param];
            NSString *escapedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            [resultUrl appendString:[NSString stringWithFormat:@"%@=%@&", param, escapedValue]];
        }
        [resultUrl deleteCharactersInRange:NSMakeRange(resultUrl.length-1, 1)];
        return [NSString stringWithString:resultUrl];
    }
    return function;
}

- (void)callFirebaseCloudFunction:(NSString *_Nonnull)function
                       parameters:(NSDictionary *_Nullable)parameters
                       completion:(_Nullable FirebaseRequestCallback)completion
{
    NSString *functionWithEscapedParameters = [self firebaseUrlForFunction:function withParameters:parameters];
    NSString *url = [NSString stringWithFormat:@"https://us-central1-owe-ios.cloudfunctions.net/app/%@", functionWithEscapedParameters];
   
    [[FIRAuth auth].currentUser getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        
        [urlRequest setHTTPMethod:@"GET"];
        NSString* bearer = [NSString stringWithFormat:@"Bearer %@", token];
        [urlRequest setValue:bearer forHTTPHeaderField:@"Authorization"];
        
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:
                                          ^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
                                              if(error)
                                              {
                                                  if(completion)
                                                  {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          completion(nil, error);
                                                      });
                                                  }
                                                  return;
                                              }
                                              
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                              
                                              NSError *parseError = nil;
                                              NSDictionary *responseDictionary = [NSJSONSerialization
                                                                                  JSONObjectWithData:data
                                                                                  options:0
                                                                                  error:&parseError];
                                              NSLog(@"The response is - %@; parseError is - %@",responseDictionary, parseError);
                                              
                                              if(completion)
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      completion(responseDictionary, parseError);
                                                  });
                                              }
                                              
                                              if(httpResponse.statusCode != 200)
                                              {
                                                  NSLog(@"Error, Server returned code %zd", httpResponse.statusCode);
                                              }
                                          }];
        [dataTask resume];
    }];
}

- (void)clearCachedPhoneNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"myPhoneNumber"];
}

- (void)getMyPhoneWithCompletion:(void(^_Nonnull)(NSString *_Nullable phone))completion
{
    [self callFirebaseCloudFunction:@"getPhone" parameters:nil completion:^(NSDictionary *data, NSError *error) {
        if (error)
        {
            NSString* phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"myPhoneNumber"];
            if (!phoneNumber)
            {
                NSString *message = [NSString stringWithFormat:@"Checking phone number error:\n%@", error.localizedDescription];
                [[self uiDelegate] showMessagePrompt:message];
            }
            completion(phoneNumber);
        }
        else
        {
            NSString* phoneNumber = data[@"phone"];
            if ([phoneNumber isEqualToString:@"undefinedPhone"])
            {
                phoneNumber = nil;
            }
            [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:@"myPhoneNumber"];
            completion(phoneNumber);
        }
    }];
}

- (void)setMyPhone:(NSString *_Nonnull)phone completion:(_Nullable FirebaseRequestCallback)completion
{
    [self callFirebaseCloudFunction:@"setPhone" parameters:@{@"phone":phone} completion:^(NSDictionary *data, NSError *error) {
        completion(data, error);
    }];
}

- (void)downloadOwes:(NSString*)status
{
    [self callFirebaseCloudFunction:@"getOwes2" parameters:@{@"status":status} completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        NSLog(@"Downloaded owes: %@\nDownloaded owes with error:%@", data, error);
        
        NSArray *owesArray = data[@"result"];
        if (!owesArray)
        {
            return;
        }
        
        [[VMZCoreDataManager sharedInstance] updateOwes:owesArray];
    }];
}

- (void)doActions
{
    NSArray *action = self.actionsQueue.firstObject;
    if(action)
    {
        [self callFirebaseCloudFunction:action[0] parameters:action[1] completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            NSLog(@"action %@ with error %@", action, error);
            
            if (error)
            {
                NSLog(@"ERROR: %@", error.localizedDescription);
            }
            else
            {
                [self.actionsQueue removeObject:action];
                NSLog(@"GOOD");
            }
            [self doActions];
        }];
    }
    
}

- (void)closeOwe:(VMZOweData *)owe
{
    if (![owe selfIsCreditor])
    {
        NSLog(@"Error: trying to CLOSE owe by debtor");
        return;
    }

    NSArray *obj = @[@"changeOwe", @{@"id":owe.uid, @"action":@"close"}];
    [[VMZCoreDataManager sharedInstance] closeOwe:owe];
    
    [self.actionsQueue addObject: obj];
    [self doActions];
}

- (void)confirmOwe:(VMZOweData *)owe
{
    if ([owe selfIsCreditor])
    {
        NSLog(@"Error: trying to CONFIRM owe by creditor");
        return;
    }
    
    NSArray *obj = @[@"changeOwe", @{@"id":owe.uid, @"action":@"confirm"}];
    [[VMZCoreDataManager sharedInstance] confirmOwe:owe];
    
    [self.actionsQueue addObject: obj];
    [self doActions];
}

- (void)cancelRequestForOwe:(VMZOweData *)owe
{
    NSArray *obj = @[@"changeOwe", @{@"id":owe.uid, @"action":@"cancel"}];
    [[VMZCoreDataManager sharedInstance] cancelRequestForOwe:owe];
    
    [self.actionsQueue addObject: obj];
    [self doActions];
}

@end

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
#import "UIViewController+VMZExtensions.h"
#import "VMZCoreDataManager.h"
#import "VMZOweAction+CoreDataClass.h"

@interface VMZOwe ()

@property (nonatomic, strong) id<NSObject> firebaseAuthStateDidChangeHandler;
@property (nonatomic, strong) NSTimer *requestsTimer;
@property (atomic, assign) BOOL doingActions;

@end


@implementation VMZOwe

- (void)addDelegate:(nonnull NSObject<VMZOweDelegate> *)delegate
{
    [self.delegates addPointer:(__bridge void * _Nullable)(delegate)];
    
    if (!self.firebaseAuthStateDidChangeHandler)
    {
        self.firebaseAuthStateDidChangeHandler =
        [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
            NSLog(@"Auth state changed %@", user);
            
            if(user)
            {
                [self VMZAuthDidSignInForUser:user withError:nil];
                
                [self getMyPhoneWithCompletion:^(NSString * _Nullable phone, NSError * error) {
                    NSLog(@"Got my phone: %@",phone);
                    
                    [self VMZPhoneNumberCheckedWithResult: phone != nil];
                    
                    [self VMZOweErrorOccured:error.localizedDescription];
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

- (void)removeDelegate:(nonnull NSObject<VMZOweDelegate> *)delegate
{
    for(int i = 0; i < [self.delegates count]; i++)
    {
        if(delegate == [self.delegates pointerAtIndex:i])
        {
            [self.delegates removePointerAtIndex: i];
            return;
        }
    }
    //@throw @"Your are trying to delete unexisting pointer from delegates.";
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

+ (VMZOwe*)sharedInstance
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
        _requestsTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self doOweActionsAsync];
        }];
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
                                              NSLog(@"parseError is - %@", parseError);
                                              
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

- (void)getMyPhoneWithCompletion:(void(^_Nonnull)(NSString *_Nullable phone, NSError *error))completion
{
    [self callFirebaseCloudFunction:@"getPhone" parameters:nil completion:^(NSDictionary *data, NSError *error) {
        NSString *phoneNumber = nil;
        if (error)
        {
            phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"myPhoneNumber"];
        }
        else if (data)
        {
            phoneNumber = data[@"phone"];
            if ([phoneNumber isEqualToString:@"undefinedPhone"])
            {
                phoneNumber = nil;
            }
            [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:@"myPhoneNumber"];
        }
        completion(phoneNumber, error);
    }];
}

- (void)setMyPhone:(NSString *_Nonnull)phone completion:(_Nullable FirebaseRequestCallback)completion
{
    [self callFirebaseCloudFunction:@"setPhone" parameters:@{@"phone":phone} completion:^(NSDictionary *data, NSError *error) {
        completion(data, error);
    }];
}

- (void)downloadOwes:(NSString*)status completion:(void(^)(NSError *error))completion
{
    [self callFirebaseCloudFunction:@"getOwes2" parameters:@{@"status":status} completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        NSLog(@"Downloaded owes %lu with error:%@", [data count], error.localizedDescription);
        
        NSArray *owesArray = data[@"result"];
        if (!owesArray)
        {
            if(completion)
            {
                completion(error);
            }
            return;
        }
        
        [[VMZCoreDataManager sharedInstance] updateOwes:owesArray];
        completion(nil);
    }];
}

- (void)closeOwe:(VMZOweData *)owe
{
    if (![owe selfIsCreditor])
    {
        NSLog(@"Error: trying to CLOSE owe by debtor");
        return;
    }

    if ([owe.status isEqualToString:@"active"])
    {
        owe.status = @"closed";
    }
    
    [[VMZCoreDataManager sharedInstance] addNewAction:@"changeOwe"
                                           parameters:@{@"id":owe.uid.copy, @"action":@"close"}
                                                  owe:owe];
    [self doOweActionsAsync];
}

- (void)confirmOwe:(VMZOweData *)owe
{
    if ([owe selfIsCreditor])
    {
        NSLog(@"Error: trying to CONFIRM owe by creditor");
        return;
    }
    
    if ([owe.status isEqualToString:@"requested"])
    {
        owe.status = @"active";
    }
    
    [[VMZCoreDataManager sharedInstance] addNewAction:@"changeOwe"
                                           parameters:@{@"id":owe.uid.copy, @"action":@"confirm"}
                                                  owe:owe];
    [self doOweActionsAsync];
}

- (void)cancelOwe:(VMZOweData *)owe
{
    if ([owe.status isEqualToString:@"requested"])
    {
        owe.status = @"closed";
    }
    
    [[VMZCoreDataManager sharedInstance] addNewAction:@"changeOwe"
                                           parameters:@{@"id":owe.uid.copy, @"action":@"cancel"}
                                                  owe:owe];
    [self doOweActionsAsync];
}

- (void)addNewOweFor:(NSString *)partner whichIsDebtor:(BOOL)partnerIsDebtor sum:(NSString*)sum descr:(NSString *)descr
{
    [[VMZCoreDataManager sharedInstance] addNewOweWithActionFor:partner whichIsDebtor:partnerIsDebtor sum:sum descr:descr];
    [self doOweActionsAsync];
}

- (void)doOweActionsAsync
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doOweActions];
    });
}

- (void)doOweActions
{
    if (self.doingActions)
    {
        NSLog(@"DOING ACTIONS");
        return;
    }
    self.doingActions = YES;
    
    NSArray *actions = [[VMZCoreDataManager sharedInstance] getActions];
    if ([actions count] == 0)
    {
        self.doingActions = NO;
        return;
    }
    
    while ([actions count] > 0)
    {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        __block BOOL stop = NO;
        
        for (VMZOweAction *action in actions)
        {
            NSLog(@"DOING ACTION: %@ %@", action.action, action.parameters);
            
            [self callFirebaseCloudFunction:action.action parameters:(NSDictionary *)action.parameters completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
                
                if (error)
                {
                    NSLog(@"ERROR: %@", error.localizedDescription);
                    stop = YES;
                    [self VMZOweErrorOccured:error.localizedDescription];
                }
                else if (data)
                {
                    NSString *serverErrorMessage = [[data objectForKey:@"error"] objectForKey:@"message"];
                    if (serverErrorMessage)
                    {
                        NSLog(@"ACTION DONE WITH SERVER ERROR %@", serverErrorMessage);
                        
                        [self VMZOweErrorOccured:serverErrorMessage];
                    }
                    else
                    {
                        NSLog(@"ACTION DONE SUCCESSFULLY");
                        
                        if ([action.action isEqualToString: @"addOwe"])
                        {
                            action.owe.uid = data[@"oweId"];
                        }
                    }
                    
                    [[VMZCoreDataManager sharedInstance] removeAction:action];
                }
                
                dispatch_semaphore_signal(sema);
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            if (stop)
            {
                break;
            }
        }
        if (stop)
        {
            break;
        }
        actions = [[VMZCoreDataManager sharedInstance] getActions];
    }
    
    self.doingActions = NO;
}

@end

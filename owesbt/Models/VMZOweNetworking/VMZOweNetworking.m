//
//  VMZOweNetworking.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 18.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Firebase.h>

#import "VMZOweNetworking.h"
#import "VMZCoreDataManager.h"
#import "VMZOweController.h"
#import "VMZOweAction+CoreDataClass.h"
#import "VMZOweData+CoreDataClass.h"
#import "VMZOweAuth.h"

@interface VMZOweNetworking ()

@property (nonatomic, strong, readonly) VMZCoreDataManager* coreDataManager;

@property (nonatomic, strong) id<NSObject> firebaseAuthStateDidChangeHandler;

@property (nonatomic, strong) NSTimer *requestsTimer;
@property (atomic, assign) BOOL doingActions;

@end


@implementation VMZOweNetworking


#pragma mark - Lifecycle

- (instancetype)initWithCoreDataManager:(VMZCoreDataManager *)manager
{
    self = [super init];
    if (self)
    {
        _coreDataManager = manager;
    }
    return self;
}


#pragma mark - VMZOweAuthDelegate

- (void)VMZAuthStateChangedForUser:(FIRUser *)user withError:(NSError *)error
{
    if(user)
    {
        [self checkPhoneNumberForFIRUser:user];
    }
    else
    {
        [self clearCachedPhoneNumber];
    }
}


#pragma mark - FirebaseNetworking

- (void)checkPhoneNumberForFIRUser:(FIRUser *)user
{
    [self getMyPhoneWithCompletion:^(NSString * _Nullable phone, NSError * error) {
        NSLog(@"Got my phone: %@",phone);
        
        [[VMZOweController sharedInstance] VMZPhoneNumberCheckedWithResult: phone != nil];
    }];
}

- (NSString*)firebaseUrlForFunction:(NSString *_Nonnull)function withParameters:(NSDictionary *_Nullable)parameters
{
    if (parameters)
    {
        NSMutableString *resultUrl = [[NSMutableString alloc] initWithString:function];
        [resultUrl appendString:@"?"];
        for (NSString *param in parameters)
        {
            NSString *value = parameters[param];
            NSString *escapedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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
        if (!token)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:VMZNotificationAuthSignedOut object:self];
            if(completion)
            {
                completion(nil, error);
            }
            return;
        }
        
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        
        [urlRequest setHTTPMethod:@"GET"];
        NSString* bearer = [NSString stringWithFormat:@"Bearer %@", token];
        [urlRequest setValue:bearer forHTTPHeaderField:@"Authorization"];
        
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:
          ^(NSData *data, NSURLResponse *response, NSError *error){
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

- (void)doOweActions
{
    if (self.doingActions)
    {
        NSLog(@"DOING ACTIONS");
        return;
    }
    self.doingActions = YES;
    
    NSArray *actions = [self.coreDataManager actions];
    if (actions.count == 0)
    {
        self.doingActions = NO;
        return;
    }
    
    while (actions.count > 0)
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
                    //[[VMZOweController sharedInstance] VMZOweErrorOccured:error.localizedDescription];
                }
                else if (data)
                {
                    NSString *serverErrorMessage = [[data objectForKey:@"error"] objectForKey:@"message"];
                    if (serverErrorMessage)
                    {
                        NSLog(@"ACTION DONE WITH SERVER ERROR %@", serverErrorMessage);
                        
                        [[VMZOweController sharedInstance] VMZOweErrorOccured:serverErrorMessage];
                    }
                    else
                    {
                        NSLog(@"ACTION DONE SUCCESSFULLY");
                        
                        if ([action.action isEqualToString: @"addOwe"])
                        {
                            action.owe.uid = data[@"oweId"];
                        }
                    }
                    
                    [self.coreDataManager removeAction:action];
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
        actions = [self.coreDataManager actions];
    }
    
    self.doingActions = NO;
}


#pragma mark - Public

- (void)doOweActionsAsync
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doOweActions];
    });
}

- (void)startActionsTimer
{
    if(!self.requestsTimer)
    {
        self.requestsTimer = [NSTimer scheduledTimerWithTimeInterval:15 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self doOweActionsAsync];
        }];
    }
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
        if (completion)
        {
            completion(phoneNumber, error);
        }
    }];
}

- (void)setMyPhone:(NSString *_Nonnull)phone completion:(void(^)(NSString *errorText))completion
{
    [self callFirebaseCloudFunction:@"setPhone" parameters:@{@"phone":phone} completion:^(NSDictionary *data, NSError *error) {
        NSString* errorText = error ? error.localizedDescription : [[data objectForKey:@"error"] objectForKey:@"message"];
        if (completion)
        {
            completion(errorText);
        }
    }];
}

- (void)passError:(NSError *)error
     toCompletion:(void(^)(NSError *error))completion
    andIfIsNotNil:(NSObject *)object
      thenDoBlock:(void(^)(void))block
{
    if (object == nil)
    {
        if(completion)
        {
            completion(error);
        }
    }
    else
    {
        block();
        if (completion)
        {
            completion(nil);
        }
    }
}

- (void)downloadOwes:(NSString*)status completion:(void(^)(NSError *error))completion
{
    [self callFirebaseCloudFunction:@"getOwes2" parameters:@{@"status":status} completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        
        NSArray *owesArray = [data objectForKey:@"result"];
        [self passError:error
           toCompletion:completion
          andIfIsNotNil:owesArray
            thenDoBlock:^{
                [self.coreDataManager updateOwes:owesArray status:status];
            }];
    }];
}

- (void)downloadGroupsWithCompletion:(void(^)(NSError *error))completion
{
    [self callFirebaseCloudFunction:@"getGroups" parameters:nil completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        
        NSArray *groupsArray = [data objectForKey:@"result"];
        [self passError:error
           toCompletion:completion
          andIfIsNotNil:groupsArray
            thenDoBlock:^{
                [self.coreDataManager updateGroups:groupsArray];
        }];
    }];
}

@end

//
//  VMZOwe.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Firebase.h>
#import <GoogleSignIn/GoogleSignIn.h>

#import "VMZOwe.h"
#import "VMZChangePhoneViewController.h"


@interface VMZOwe ()

@property (nonatomic, strong) id<NSObject> firebaseAuthStateDidChangeHandler;

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
                                      [self VMZAuthDidSignInForUser:user withError:error];
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
    // Perform any operations when the user disconnects from app here.
    // ...
}


#pragma mark - VMZOweDelegate

- (void)VMZAuthDidSignInForUser:(FIRUser*)user withError:(NSError*)error
{
    if ([self.uiDelegate respondsToSelector:@selector(VMZAuthDidSignInForUser:withError:)])
    {
        [self.uiDelegate VMZAuthDidSignInForUser:user withError:error];
    }
}

- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success
{
    if ([self.uiDelegate respondsToSelector:@selector(VMZPhoneNumberCheckedWithResult:)])
    {
        [self.uiDelegate VMZPhoneNumberCheckedWithResult:success];
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
    
    self.firebaseAuthStateDidChangeHandler =
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
        NSLog(@"Auth state changed %@", user);
        
        if(user)
        {
            [self getMyPhoneWithCompletion:^(NSString * _Nullable phone) {
                NSLog(@"Got my phone: %@",phone);
                
                if ([phone isEqualToString:@"undefinedPhone"])
                {
                    [self presentChangePhoneView];
                }
                else
                {
                    //goto authorized view
                }
            }];
        }
        else
        {
            [self VMZAuthDidSignInForUser:nil withError:nil];
        }
    }];
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [[FIRAuth auth] removeAuthStateDidChangeListener:self.firebaseAuthStateDidChangeHandler];
}

- (void)presentChangePhoneView
{
    UIViewController* view = [VMZChangePhoneViewController new];
    [view setModalPresentationStyle:UIModalPresentationFullScreen];
    [view setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.uiDelegate presentViewController:view animated:YES completion:^{
        NSLog(@"presentChangePhoneView completion");
        [self VMZPhoneNumberCheckedWithResult:YES];
    }];
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

- (void)firebaseCloudFunctionCall:(NSString *_Nonnull)function
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

- (void)getMyPhoneWithCompletion:(void(^_Nonnull)(NSString *_Nullable phone))completion
{
    [self firebaseCloudFunctionCall:@"getPhone" parameters:nil completion:^(NSDictionary *data, NSError *error) {
        completion(error || data == nil ? nil : data[@"phone"]);
        if (error)
        {
            @throw error;
        }
    }];
}

- (void)setMyPhone:(NSString *_Nonnull)phone completion:(_Nullable FirebaseRequestCallback)completion
{
    [self firebaseCloudFunctionCall:@"setPhone" parameters:@{@"phone":phone} completion:^(NSDictionary *data, NSError *error) {
        completion(data, error);
        if (error)
        {
            @throw error;
        }
    }];
}

@end

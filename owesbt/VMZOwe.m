//
//  VMZOwe.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOwe.h"

@implementation VMZOwe


#pragma mark - VMZOweDelegate

- (void)FIRAuthDidSignInForUser:(FIRUser*)user withError:(NSError*)error
{
    if (self.delegate != self)
    {
        [self.delegate FIRAuthDidSignInForUser:user withError:error];
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


#pragma mark - FirebaseNetworking

- (void)firebaseCloudFunctionCall:(NSString *_Nonnull)function completion:(_Nullable FirebaseRequestCallback)completion
{
    NSString *escapedParameters = [function stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"https://us-central1-owe-ios.cloudfunctions.net/app/%@", escapedParameters];
   
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
    [self firebaseCloudFunctionCall:@"getPhone" completion:^(NSDictionary *data, NSError *error) {
        completion(error || data == nil ? nil : data[@"phone"]);
        if (error)
        {
            @throw error;
        }
    }];
}

- (void)setMyPhone:(NSString *_Nonnull)phone completion:(_Nullable FirebaseRequestCallback)completion
{
    NSString *functionWithParameters = [NSString stringWithFormat:@"setPhone?phone=%@", phone];
    [self firebaseCloudFunctionCall:functionWithParameters completion:^(NSDictionary *data, NSError *error) {
        completion(data, error);
        if (error)
        {
            @throw error;
        }
    }];
}

@end

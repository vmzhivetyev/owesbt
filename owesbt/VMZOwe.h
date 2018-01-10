//
//  VMZOwe.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GIDSignInDelegate;
@class FIRUser;


typedef void (^FirebaseRequestCallback)(NSDictionary *_Nullable data, NSError *_Nullable error);


@protocol VMZOweUIDelegate

@optional

- (void)VMZAuthDidSignInForUser:(FIRUser *_Nullable)user withError:(NSError *_Nullable)error;
- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success;

@end


@interface VMZOwe : NSObject <GIDSignInDelegate>

@property (nonatomic, weak) UIViewController<VMZOweUIDelegate> *_Nullable uiDelegate;

+ (VMZOwe *_Nonnull)sharedInstance;

//- (void)firebaseCloudFunctionCall:(NSString *_Nonnull)function completion:(_Nullable FirebaseRequestCallback)completion;
- (void)getMyPhoneWithCompletion:(void(^_Nonnull)(NSString *_Nullable phone))completion;
- (void)setMyPhone:(NSString *_Nonnull)phone completion:(_Nullable FirebaseRequestCallback)completion;

@end

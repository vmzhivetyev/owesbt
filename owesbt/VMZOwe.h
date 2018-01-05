//
//  VMZOwe.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase.h>


typedef void (^FirebaseRequestCallback)(NSDictionary *_Nullable data, NSError *_Nullable error);


@protocol VMZOweDelegate <NSObject>

- (void)FIRAuthDidSignInForUser:(FIRUser *_Nullable)user withError:(NSError *_Nullable)error;

@end


@interface VMZOwe : NSObject <VMZOweDelegate>

@property (nonatomic, weak) _Nullable id<VMZOweDelegate> delegate;

+ (VMZOwe *_Nonnull)sharedInstance;

//- (void)firebaseCloudFunctionCall:(NSString *_Nonnull)function completion:(_Nullable FirebaseRequestCallback)completion;
- (void)getMyPhoneWithCompletion:(void(^_Nonnull)(NSString *_Nullable phone))completion;
- (void)setMyPhone:(NSString *_Nonnull)phone completion:(_Nullable FirebaseRequestCallback)completion;

@end

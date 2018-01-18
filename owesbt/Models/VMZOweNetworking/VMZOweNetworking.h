//
//  VMZOweNetworking.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 18.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>


@class VMZCoreDataManager;


typedef void (^FirebaseRequestCallback)(NSDictionary *data, NSError *error);


@interface VMZOweNetworking : NSObject

- (instancetype)initWithCoreDataManager:(VMZCoreDataManager *)manager;

- (void)startActionsTimer;

- (void)clearCachedPhoneNumber;
- (void)getMyPhoneWithCompletion:(void(^)(NSString *phone, NSError *error))completion;
- (void)setMyPhone:(NSString *)phone completion:(void(^)(NSString *errorText))completion;
- (void)downloadOwes:(NSString *)status completion:(void(^)(NSError *error))completion;

@end

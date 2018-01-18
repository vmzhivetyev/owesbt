//
//  VMZOweController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GIDSignInDelegate;
@class FIRUser;
@class VMZOweData;
@class VMZCoreDataManager;
@class VMZOweNetworking;


@protocol VMZOweDelegate<NSObject>

@optional

/*
    при успешном логине в firebase
        user - not nil
        error - nil
    при ошибке логина в google/firebase или логауте из firebase
        user - nil
        error - nil / not nil
 */
- (void)VMZAuthDidSignInForUser:(FIRUser *_Nullable)user withError:(NSError *_Nullable)error;

/*
    success - номер телефона не пустой (из кэша либо получен от сервера)
 */
- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success;

/*
    обновились данные в кордате для entity "Owe"
 */
- (void)VMZOwesCoreDataDidUpdate;

- (void)VMZOweErrorOccured:(NSString *)error;

@end


@interface VMZOweController : NSObject <GIDSignInDelegate, VMZOweDelegate>

@property (nonatomic, strong, readonly) VMZCoreDataManager* coreDataManager;
@property (nonatomic, strong, readonly) VMZOweNetworking* networking;

@property (nonatomic, strong) NSPointerArray * _Nonnull delegates;

@property (nonatomic, strong) NSArray *_Nullable owes;


+ (VMZOweController *_Nonnull)sharedInstance;

- (void)addDelegate:(nonnull NSObject<VMZOweDelegate> *)delegate;
- (void)removeDelegate:(nonnull NSObject<VMZOweDelegate> *)delegate;

- (void)loggedInViewControllerDidLoad;

- (void)setMyPhone:(NSString *)phone completion:(void(^)(NSString *errorText))completion;
- (void)refreshOwesWithStatus:(NSString *)status completion:(void(^)(NSError *error))completion;
- (void)closeOwe:(VMZOweData *)owe;
- (void)confirmOwe:(VMZOweData *)owe;
- (void)cancelOwe:(VMZOweData *)owe;
- (void)addNewOweFor:(NSString *)partner whichIsDebtor:(BOOL)partnerIsDebtor sum:(NSString*)sum descr:(NSString *)descr;


@end

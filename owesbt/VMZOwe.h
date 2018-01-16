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
@class VMZOweData;
@class UIViewController;


typedef void (^FirebaseRequestCallback)(NSDictionary *_Nullable data, NSError *_Nullable error);


@protocol VMZOweDelegate

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


@interface VMZOwe : NSObject <GIDSignInDelegate, VMZOweDelegate>

@property (nonatomic, weak) UIViewController *_Nullable currentViewController;

@property (nonatomic, strong) NSPointerArray * _Nonnull delegates;

@property (nonatomic, strong) NSArray *_Nullable owes;


+ (VMZOwe *_Nonnull)sharedInstance;

- (void)addDelegate:(nonnull NSObject<VMZOweDelegate> *)delegate;
- (void)removeDelegate:(nonnull NSObject<VMZOweDelegate> *)delegate;

- (void)getMyPhoneWithCompletion:(void(^_Nonnull)(NSString *_Nullable phone))completion;
- (void)setMyPhone:(NSString *_Nonnull)phone completion:(_Nullable FirebaseRequestCallback)completion;
- (void)downloadOwes:(NSString*_Nonnull)status completion:(void(^_Nullable)(NSError * _Nullable error))completion;
- (void)closeOwe:(VMZOweData *_Nonnull)owe;
- (void)confirmOwe:(VMZOweData *_Nonnull)owe;
- (void)cancelRequestForOwe:(VMZOweData *_Nonnull)owe;
- (void)addNewOweFor:(NSString *)partner whichIsDebtor:(BOOL)partnerIsDebtor sum:(NSString*)sum descr:(NSString *)descr;
- (void)doOweActionsAsync;


@end

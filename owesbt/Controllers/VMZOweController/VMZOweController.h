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
@class VMZOweAuth;
@class VMZUIController;


static NSString *const VMZNotificationAuthNilUser = @"VMZNotificationAuthNilUser";
static NSString *const VMZNotificationAuthSignedIn = @"VMZNotificationAuthSignedIn";
static NSString *const VMZNotificationAuthCheckedPhoneNumberBad = @"VMZNotificationAuthCheckedPhoneNumber";
static NSString *const VMZNotificationAuthCheckedPhoneNumberGood = @"VMZNotificationAuthCheckedPhoneNumber";
static NSString *const VMZNotificationAuthSignedOut = @"VMZNotificationAuthSignedOut";


@protocol VMZOweDelegate<NSObject>

@optional

/* success - номер телефона не пустой (из кэша либо получен от сервера)
 */
- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success;

/* обновились данные в кордате для entity "Owe"
 */
- (void)VMZOwesCoreDataDidUpdate;

- (void)VMZOweErrorOccured:(NSString *)error;

@end


@interface VMZOweController : NSObject <VMZOweDelegate>

@property (nonatomic, strong, readonly) VMZCoreDataManager* coreDataManager;
@property (nonatomic, strong, readonly) VMZOweNetworking* networking;
@property (nonatomic, strong, readonly) VMZOweAuth *auth;
@property (nonatomic, strong, readonly) VMZUIController *uiController;

@property (nonatomic, weak) id<VMZOweDelegate> delegate;

+ (VMZOweController *_Nonnull)sharedInstance;

- (void)loggedInViewControllerDidLoad;

- (void)setMyPhone:(NSString *)phone completion:(void(^)(NSString *errorText))completion;
- (void)refreshOwesWithStatus:(NSString *)status completion:(void(^)(NSError *error))completion;
- (void)closeOwe:(VMZOweData *)owe;
- (void)confirmOwe:(VMZOweData *)owe;
- (void)cancelOwe:(VMZOweData *)owe;
- (void)addNewOweFor:(NSString *)partner whichIsDebtor:(BOOL)partnerIsDebtor sum:(NSString*)sum descr:(NSString *)descr;


@end

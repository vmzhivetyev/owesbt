//
//  VMZOweAuth.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 28.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FIRUser;
@protocol GIDSignInDelegate;


@protocol VMZOweAuthDelegate <NSObject>

/* при успешном логине в firebase
 user - not nil
 error - nil
 при ошибке логина в google/firebase или логауте из firebase
 user - nil
 error - nil / not nil
 */
- (void)VMZAuthStateChangedForUser:(FIRUser *_Nullable)user withError:(NSError *_Nullable)error;

@end


@interface VMZOweAuth : NSObject <GIDSignInDelegate>

/* сразу вызовется VMZAuthStateChangedForUser у delegate для текущего состояния авторизации
 */
- (void)setDelegate:(id<VMZOweAuthDelegate>)delegate;

@property (nonatomic, weak) id<VMZOweAuthDelegate> delegate;

@end

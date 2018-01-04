//
//  VMZOwe.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase.h>


@protocol VMZOweDelegate <NSObject>

- (void)FIRAuthDidSignInForUser:(FIRUser*)user withError:(NSError*)error;

@end


@interface VMZOwe : NSObject

@property (nonatomic, weak) id<VMZOweDelegate> delegate;

+ (VMZOwe*)sharedInstance;

@end

//
//  MainViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GIDSignInUIDelegate;
@protocol VMZOweDelegate;
@protocol VMZOweAuthDelegate;


@interface VMZMainViewController : UIViewController <VMZOweDelegate, VMZOweAuthDelegate>

@end


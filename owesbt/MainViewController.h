//
//  MainViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GIDSignInUIDelegate;
@protocol VMZOweUIDelegate;


@interface VMZMainViewController : UIViewController <GIDSignInUIDelegate, VMZOweUIDelegate>

@end


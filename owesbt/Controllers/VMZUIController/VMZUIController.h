//
//  VMZUIController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 31.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@class VMZOweData;


@interface VMZUIController : NSObject

+ (void)doTransitionToViewController:(UIViewController *)viewController
                         withOptions:(UIViewAnimationOptions)options;

+ (UIViewController *)mainViewController;
+ (UIViewController *)phoneSetupViewController;
+ (UIViewController *)newOweViewController;
+ (UIViewController *)groupsViewController;
+ (UIViewController *)newGroupViewController;
+ (UIViewController *)viewControllerForOwe:(VMZOweData *)owe;

@end

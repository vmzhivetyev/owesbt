//
//  VMZUIController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 31.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZUIController.h"

#import "VMZOweController.h"
#import "VMZMainViewController.h"
#import "VMZChangePhoneViewController.h"
#import "VMZNavigationController.h"
#import "VMZOweViewController.h"
#import "VMZGroupsViewController.h"
#import "VMZGroupViewController.h"


@implementation VMZUIController


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self subscribeForNotificationCenter];
    }
    return self;
}

- (void)dealloc
{
    [self unsubscribeFromNotificationCenter];
}

- (void)subscribeForNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signedIn)
                                                 name:VMZNotificationAuthSignedIn
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signedOut)
                                                 name:VMZNotificationAuthSignedOut
                                               object:nil];
}

- (void)unsubscribeFromNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

+ (void)doTransitionToViewController:(UIViewController *)viewController withOptions:(UIViewAnimationOptions)options
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [UIView transitionWithView:window duration:0.5 options:options animations:^{
                        window.rootViewController = viewController;
                    } completion:nil];
}

+ (UIViewController *)mainViewController
{
    return [[VMZMainViewController alloc] init];
}

+ (UIViewController *)signedInViewController
{
    VMZNavigationController *navigationController = [[VMZNavigationController alloc] init];
    
    return navigationController;
}

+ (UIViewController *)phoneSetupViewController
{
    return [[VMZChangePhoneViewController alloc] init];
}

+ (UIViewController *)newOweViewController
{
    return [[VMZOweViewController alloc] init];
}

+ (UIViewController *)groupsViewController
{
    return [[VMZGroupsViewController alloc] init];
}

+ (UIViewController *)newGroupViewController
{
    return [[VMZGroupViewController alloc] init];
}

+ (UIViewController *)viewControllerForOwe:(VMZOweData *)owe
{
    return [[VMZOweViewController alloc] initWithOwe:owe forceTouchActions:nil];
}

+ (UIViewController *)viewControllerForGroup:(VMZOweGroup *)group
{
    return [[VMZGroupViewController alloc] initWithGroup:group forceTouchActions:nil];
}

#pragma mark - NSNotificationCenter Selectors

- (void)signedIn
{
    [[self class] doTransitionToViewController:[[self class] signedInViewController]
                                   withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)signedOut
{
    [[self class] doTransitionToViewController:[[self class] mainViewController]
                                   withOptions:UIViewAnimationOptionTransitionNone];
}


@end

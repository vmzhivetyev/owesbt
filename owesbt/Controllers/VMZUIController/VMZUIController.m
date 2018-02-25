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
#import "VMZOweController.h"


#define VMZ_DEBUG_LOAD_GROUPS_VIEW
#ifdef VMZ_DEBUG_LOAD_GROUPS_VIEW

#import "VMZGroupViewController.h"

#endif


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

- (void)doTransitionToViewController:(UIViewController *)viewController withOptions:(UIViewAnimationOptions)options
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [UIView transitionWithView:window duration:0.5 options:options animations:^{
                        window.rootViewController = viewController;
                    } completion:nil];
}

- (UIViewController *)mainViewController
{
    return [[VMZMainViewController alloc] init];
}

- (UIViewController *)signedInWithController
{
    VMZNavigationController *navigationController = [[VMZNavigationController alloc] init];
    
#ifdef VMZ_DEBUG_LOAD_GROUPS_VIEW
    [navigationController pushViewController:[VMZGroupViewController new] animated:YES];
#endif
    
    return navigationController;
}

- (UIViewController *)phoneSetupViewController
{
    return [[VMZChangePhoneViewController alloc] init];
}


#pragma mark - NSNotificationCenter Selectors

- (void)signedIn
{
    [self doTransitionToViewController:[self signedInWithController]
                           withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)signedOut
{
    [self doTransitionToViewController:[self mainViewController]
                           withOptions:UIViewAnimationOptionTransitionNone];
}


@end

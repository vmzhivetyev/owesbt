//
//  MainViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>
#import <Firebase.h>
#import <Masonry.h>

#import "VMZOwe.h"
#import "VMZMainViewController.h"
#import "VMZChangePhoneViewController.h"
#import "VMZNavigationController.h"
#import "UIViewController+VMZExtensions.h"

@interface VMZMainViewController ()

@property (nonatomic, strong) GIDSignInButton *googleSignInButton;
@property (nonatomic, strong) UIImageView *spinnerImageView;

@end


@implementation VMZMainViewController


#pragma mark - VMZOweDelegate

- (void)VMZAuthDidSignInForUser:(FIRUser *_Nullable)user withError:(NSError *_Nullable)error
{
    if (error)
    {
        [self showMessagePrompt: [NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
        return;
    }
    
    //[self showMessagePrompt: [NSString stringWithFormat:@"Signed in for user: %@", user]];
    
    self.spinnerImageView.hidden = !user;
    self.googleSignInButton.hidden = !!user;
}

- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success
{
    if (success)
    {
        [[VMZOwe sharedInstance] removeDelegate:self];
        [self presentViewController:[[VMZNavigationController alloc] init] animated:YES completion:nil];
    }
    else
    {
        [self presentChangePhoneView];
    }
}

- (void)VMZOweErrorOccured:(NSString *)error
{
    [self showMessagePrompt:error];
}


#pragma mark - UI

- (void)signOutButtonClicked:(UIButton*)button
{
    NSError *signOutError;
    if([[FIRAuth auth] signOut:&signOutError])
    {
        [self showMessagePrompt:@"Signed out"];
    }
    else
    {
        [self showMessagePrompt:[NSString stringWithFormat:@"Sign out error: %@", signOutError.localizedDescription]];
    }
}

- (void)presentChangePhoneView
{
    UIViewController* view = [VMZChangePhoneViewController new];
    [view setModalPresentationStyle:UIModalPresentationFullScreen];
    [view setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:view animated:YES completion:nil];
}


#pragma mark - LifeCycle

- (void)dealloc
{
    [[VMZOwe sharedInstance] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[VMZOwe sharedInstance] addDelegate:self];
    [GIDSignIn sharedInstance].uiDelegate = self;
    //[[GIDSignIn sharedInstance] signIn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.googleSignInButton = [[GIDSignInButton alloc] init];
    [self.view addSubview:self.googleSignInButton];
    
    UIImage* image = [UIImage imageNamed:@"Dual Ring"];
    self.spinnerImageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:self.spinnerImageView];
    
    [self.spinnerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(image.size);
    }];
    [self.googleSignInButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(150, 40));
    }];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
    animation.duration = 1.0f;
    animation.repeatCount = INFINITY;
    [self.spinnerImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
    
    
    //sign out button
    UIButton* signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signOutButton.frame = CGRectMake(25, CGRectGetMaxY(self.view.bounds) - 25, 60, 25);
    [signOutButton setTitle:@"Sign out" forState:UIControlStateNormal];
    [signOutButton addTarget:self action:@selector(signOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signOutButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

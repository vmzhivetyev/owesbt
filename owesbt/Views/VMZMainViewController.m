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

#import "VMZOweController.h"
#import "VMZMainViewController.h"
#import "VMZChangePhoneViewController.h"
#import "VMZNavigationController.h"
#import "UIViewController+VMZExtensions.h"

@interface VMZMainViewController ()

@property (nonatomic, weak) GIDSignInButton *googleSignInButton;
@property (nonatomic, weak) UIImageView *spinnerImageView;

@end


@implementation VMZMainViewController


#pragma mark - VMZOweDelegate

- (void)VMZAuthDidSignInForUser:(FIRUser *_Nullable)user withError:(NSError *_Nullable)error
{
    if (error)
    {
        [self VMZShowMessagePrompt: [NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
        return;
    }
    
    self.spinnerImageView.hidden = !user;
    self.googleSignInButton.hidden = !!user;
}

- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success
{
    if (success)
    {
        [[VMZOweController sharedInstance] removeDelegate:self];
        [self presentViewController:[[VMZNavigationController alloc] init] animated:YES completion:nil];
    }
    else
    {
        [self presentChangePhoneView];
    }
}

- (void)VMZOweErrorOccured:(NSString *)error
{
    [self VMZShowMessagePrompt:error];
}


#pragma mark - UI

- (void)signOutButtonClicked:(UIButton*)button
{
    NSError *signOutError;
    if([[FIRAuth auth] signOut:&signOutError])
    {
        [self VMZShowMessagePrompt:@"Signed out"];
    }
    else
    {
        [self VMZShowMessagePrompt:[NSString stringWithFormat:@"Sign out error: %@", signOutError.localizedDescription]];
    }
}

- (void)presentChangePhoneView
{
    UIViewController* view = [VMZChangePhoneViewController new];
    [view setModalPresentationStyle:UIModalPresentationFullScreen];
    [view setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    GIDSignInButton *googleSignInButton = [[GIDSignInButton alloc] init];
    self.googleSignInButton = googleSignInButton;
    [self.view addSubview:self.googleSignInButton];
    
    UIImage* image = [UIImage imageNamed:@"Dual Ring"];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithImage:image];
    self.spinnerImageView = spinnerImageView;
    [self.view addSubview:self.spinnerImageView];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
    animation.duration = 1.0f;
    animation.repeatCount = INFINITY;
    [self.spinnerImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
    
    UIButton* signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signOutButton.frame = CGRectMake(25, CGRectGetMaxY(self.view.bounds) - 25, 60, 25);
    [signOutButton setTitle:@"Sign out" forState:UIControlStateNormal];
    [signOutButton addTarget:self action:@selector(signOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signOutButton];
    
    [self.spinnerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(image.size);
    }];
    [self.googleSignInButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(150, 40));
    }];
}


#pragma mark - LifeCycle

- (void)dealloc
{
    [[VMZOweController sharedInstance] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[VMZOweController sharedInstance] addDelegate:self];
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

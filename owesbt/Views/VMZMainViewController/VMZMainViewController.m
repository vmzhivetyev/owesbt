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
#import "UIViewController+MessagePrompt.h"
#import "VMZOweAuth.h"

@interface VMZMainViewController ()

@property (nonatomic, weak) GIDSignInButton *googleSignInButton;
@property (nonatomic, weak) UIImageView *spinnerImageView;

@end


@implementation VMZMainViewController


#pragma mark - VMZOweAuthDelegate

- (void)VMZAuthStateChangedForUser:(FIRUser *_Nullable)user withError:(NSError *_Nullable)error
{
    if (error)
    {
        [self mp_showMessagePrompt: [NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
        return;
    }
    
    self.googleSignInButton.hidden = !!user;
    self.spinnerImageView.hidden = !user;
    if (!self.spinnerImageView.hidden)
    {
        [self createSpinnerAnimation];
    }
}


#pragma mark - VMZOweDelegate

- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success
{
    if (success)
    {
        [self presentViewController:[[VMZNavigationController alloc] init] animated:YES completion:nil];
    }
    else
    {
        [self presentChangePhoneView];
    }
}


#pragma mark - UI

- (void)presentChangePhoneView
{
    UIViewController* view = [VMZChangePhoneViewController new];
    [view setModalPresentationStyle:UIModalPresentationFullScreen];
    [view setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)createSpinnerAnimation
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
    animation.duration = 1.0f;
    animation.repeatCount = INFINITY;
    [self.spinnerImageView.layer removeAllAnimations];
    [self.spinnerImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
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
    
    [self createSpinnerAnimation];
    
    self.googleSignInButton.hidden = YES;
    
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [VMZOweController sharedInstance].delegate = self;
    [VMZOweController sharedInstance].auth.delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    [self createUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

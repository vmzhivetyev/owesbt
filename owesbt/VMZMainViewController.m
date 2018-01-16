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
#import "VMZOweTabsViewController.h"
#import "UIViewController+Extension.h"

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
        UIViewController *tabbarView = [[VMZOweTabsViewController alloc] init];
        UINavigationController *navigationController =
            [[UINavigationController alloc] initWithRootViewController:tabbarView];
        [self presentViewController:navigationController animated:YES completion:^{
            [[VMZOwe sharedInstance] removeDelegate:self];
        }];
    }
    else
    {
        [self presentChangePhoneView];
    }
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
    //TODO костыль для дисмиса алерта, который нужен для дебага, не будет алерта - не нужен dismiss
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    UIViewController* view = [VMZChangePhoneViewController new];
    [view setModalPresentationStyle:UIModalPresentationFullScreen];
    [view setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:view animated:YES completion:nil];
}


#pragma mark - LifeCycle

//- (void)showPhoneNumberVerificationAlert
//{
//    UIAlertController * alertController =
//        [UIAlertController alertControllerWithTitle: @"Verify phone number"
//                                            message: @"Please, enter the code we sent you in SMS"
//                                     preferredStyle: UIAlertControllerStyleAlert];
//
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = @"code";
//        //textField.textColor = [UIColor blueColor];
//        //textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        //textField.borderStyle = UITextBorderStyleRoundedRect;
//    }];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        NSArray * textfields = alertController.textFields;
//        UITextField * codeTextField = textfields[0];
//
//        NSString *verificationID = [[NSUserDefaults standardUserDefaults] stringForKey:@"authVerificationID"];
//
//        FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider]
//                                         credentialWithVerificationID:verificationID
//                                                     verificationCode:codeTextField.text];
//
//        [[FIRAuth auth].currentUser updatePhoneNumberCredential:credential completion:^(NSError * _Nullable error) {
//            if(error)
//            {
//                @throw error;
//            }
//        }];
//    }]];
//    [self presentViewController:alertController animated:YES completion:nil];
//}

//- (void)setPhoneNumber
//{
//    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:@"89620565757"
//        completion: ^(NSString * _Nullable verificationID, NSError * _Nullable error) {
//            if (error)
//            {
//                @throw error;
//                return;
//            }
//
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setObject:verificationID forKey:@"authVerificationID"];
//
//            [self showPhoneNumberVerificationAlert];
//        }];
//}

- (void)dealloc
{
    [[VMZOwe sharedInstance] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[VMZOwe sharedInstance] addDelegate:self];
    [VMZOwe sharedInstance].currentViewController = self;
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
    UIButton* signOutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    signOutButton.frame = CGRectMake(25, CGRectGetMaxY(self.view.bounds) - 25, 60, 25);
    [signOutButton setTitle:@"Sign out" forState:UIControlStateNormal];
    [signOutButton addTarget:self action:@selector(signOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signOutButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self.spinnerImageView.layer animationForKey:@"SpinAnimation"] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

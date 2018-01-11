//
//  MainViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>
#import <Firebase.h>

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
        self.view.backgroundColor = [UIColor greenColor];
        //show view for authorized user
        
        UIViewController *tabbarView = [[VMZOweTabsViewController alloc] init];
        UINavigationController *navigationController =
            [[UINavigationController alloc] initWithRootViewController:tabbarView];
        [self presentViewController:navigationController animated:YES completion:^{
            
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [VMZOwe sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    //[[GIDSignIn sharedInstance] signIn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.googleSignInButton = [[GIDSignInButton alloc] initWithFrame:CGRectMake(80.0, 210.0, 120.0, 40.0)];
    [self.view addSubview:self.googleSignInButton];
    
    UIImage* image = [UIImage imageNamed:@"Dual Ring"];
    CGFloat x = CGRectGetMidX(self.view.bounds) - image.size.width/2;
    CGFloat y = CGRectGetMidY(self.view.bounds) - image.size.height/2;
    CGRect rect = CGRectMake(x, y, image.size.width, image.size.height);
    self.spinnerImageView = [[UIImageView alloc] initWithFrame:rect];
    self.spinnerImageView.image = image;
    self.spinnerImageView.tintColor = [UIColor whiteColor];
    self.spinnerImageView.opaque = YES;
    self.spinnerImageView.contentMode = UIViewContentModeScaleToFill;
    self.spinnerImageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    [self.view addSubview:self.spinnerImageView];
    
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
    [self.spinnerImageView.layer animationForKey:@"SpinAnimation"] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  MainViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>
#import <Firebase.h>

#import "MainViewController.h"
#import "VMZOwe.h"

@interface VMZMainViewController ()

@property (nonatomic, strong) GIDSignInButton *googleSignInButton;

@end


@implementation VMZMainViewController


#pragma mark - VMZOweDelegate

- (void)VMZAuthDidSignInForUser:(FIRUser *_Nullable)user withError:(NSError *_Nullable)error
{
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)VMZPhoneNumberCheckedWithResult:(BOOL)success
{
    self.view.backgroundColor = success ? [UIColor greenColor] : [UIColor redColor];
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
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(80, 250, 220, 40)];
    label.textColor = UIColor.blackColor;
    [self.view addSubview:label];
    
    self.googleSignInButton = [[GIDSignInButton alloc] initWithFrame:CGRectMake(80.0, 210.0, 120.0, 40.0)];
    [self.view addSubview:self.googleSignInButton];
    
    //TODO unsubscribe
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  MainViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) GIDSignInButton *googleSignInButton;

@end


@implementation MainViewController


#pragma mark - VMZOweDelegate

- (void)FIRAuthDidSignInForUser:(FIRUser *)user withError:(NSError *)error
{
    self.view.backgroundColor = [UIColor blueColor];
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
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    [VMZOwe sharedInstance].delegate = self;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(80, 250, 220, 40)];
    label.textColor = UIColor.blackColor;
    [self.view addSubview:label];
    
    //TODO unsubscribe
    id handle = [[FIRAuth auth]
                   addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
                       label.text = (user!=nil ? user.displayName : @"nil");
                       NSLog(@"%@", user);
                       
                       if(user)
                       {
                           [[VMZOwe sharedInstance] getMyPhoneWithCompletion:^(NSString * _Nullable phone) {
                               label.text = phone;
                           }];
                       }
                   }];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    //[[GIDSignIn sharedInstance] signIn];
    
    self.googleSignInButton = [[GIDSignInButton alloc] initWithFrame:CGRectMake(80.0, 210.0, 120.0, 40.0)];
    [self.view addSubview:self.googleSignInButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

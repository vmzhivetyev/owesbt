//
//  PhoneChangeViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZChangePhoneViewController.h"
#import "VMZOwe.h"
#import "UIViewController+Extension.h"


@interface VMZChangePhoneViewController ()

@property (strong, nonatomic) UITextField* phoneTextField;

@end

@implementation VMZChangePhoneViewController


#pragma mark - UI

- (void)doneButtonClick:(UIButton*)button
{
    NSString* phone = self.phoneTextField.text;
    [[VMZOwe sharedInstance] setMyPhone:phone completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        if (data)
        {
            NSString* phone = [data objectForKey:@"phone"];
            NSString* errorText = [[data objectForKey:@"error"] objectForKey:@"message"];
            
            if (phone)
            {
                [self showMessagePrompt:[NSString stringWithFormat:@"Error: %@", errorText]];
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
}


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.view safeAreaInsets].top
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat leftRightMargin = 8;
    CGFloat top = 28;
    CGFloat width = CGRectGetWidth([self.view frame]) - 2*leftRightMargin;
    CGFloat height = 30;
    self.phoneTextField = [UITextField new];
    self.phoneTextField.frame = CGRectMake(leftRightMargin, top, width, height);
    self.phoneTextField.textColor = [UIColor blackColor];
    self.phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneTextField.textContentType = UITextContentTypeTelephoneNumber;
    [self.view addSubview:self.phoneTextField];
    
    [self.phoneTextField becomeFirstResponder];
    
    UIButton* setPhoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    setPhoneButton.frame = CGRectMake(leftRightMargin, CGRectGetMaxY(self.phoneTextField.frame) + 8, width, 25);
    [setPhoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [setPhoneButton addTarget:self
                       action:@selector(doneButtonClick:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setPhoneButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

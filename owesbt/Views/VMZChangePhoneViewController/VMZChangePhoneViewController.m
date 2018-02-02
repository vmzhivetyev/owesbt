//
//  PhoneChangeViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Masonry.h>

#import "VMZChangePhoneViewController.h"
#import "VMZOweController.h"
#import "VMZNavigationController.h"

#import "UIViewController+MessagePrompt.h"

@interface VMZChangePhoneViewController ()

@property (nonatomic, weak) UITextField* phoneTextField;

@end

@implementation VMZChangePhoneViewController


#pragma mark - UI

- (void)doneButtonClick:(UIButton*)button
{
    NSString* phone = self.phoneTextField.text;
    [[VMZOweController sharedInstance] setMyPhone:phone completion:^(NSString *errorText) {
        if (errorText)
        {
            [self mp_showMessagePrompt:[NSString stringWithFormat:@"Error: %@", errorText]];
        }
        else
        {
            [self.phoneTextField endEditing:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:VMZNotificationAuthSignedIn object:self];
        }
    }];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITextField *phoneTextField = [UITextField new];
    phoneTextField.textColor = [UIColor blackColor];
    phoneTextField.borderStyle = UITextBorderStyleNone;
    phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    phoneTextField.textContentType = UITextContentTypeTelephoneNumber;
    phoneTextField.placeholder = @"Enter your phone number";
    phoneTextField.textAlignment = NSTextAlignmentCenter;
    phoneTextField.adjustsFontSizeToFitWidth = YES;
    phoneTextField.font = [UIFont boldSystemFontOfSize:30];
    [self.view addSubview:phoneTextField];
    self.phoneTextField = phoneTextField;
    
    [self.phoneTextField becomeFirstResponder];
    
    UIButton* setPhoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    setPhoneButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [setPhoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [setPhoneButton addTarget:self
                       action:@selector(doneButtonClick:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setPhoneButton];
    
    //constrainsts
    
    [phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view).insets(UIEdgeInsetsMake(130, 30, 10, 30));
        make.height.equalTo(@30);
    }];
    
    [setPhoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.phoneTextField.mas_bottom).offset(30);
        make.height.equalTo(@40);
        make.width.equalTo(@100);
    }];
}


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

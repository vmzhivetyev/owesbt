//
//  PhoneChangeViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 05.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZChangePhoneViewController.h"

@interface VMZChangePhoneViewController ()

@end

@implementation VMZChangePhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.view safeAreaInsets].top
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat leftRightMargin = 8;
    CGFloat top = self.view.safeAreaInsets.top + 8;
    CGFloat width = CGRectGetWidth([self.view frame]) - 2*leftRightMargin;
    CGFloat height = 21;
    UITextField *phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, top, width, height)];
    phoneTextField.textColor = [UIColor blackColor];
    phoneTextField.backgroundColor = [UIColor blackColor];
    [self.view addSubview:phoneTextField];
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

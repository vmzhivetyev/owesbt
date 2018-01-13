//
//  VMZOweTabsViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOweTabsViewController.h"
#import "VMZOwesTableViewController.h"

@interface VMZOweTabsViewController ()

@end

@implementation VMZOweTabsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *view1 = [[VMZOwesTableViewController alloc] initWithStatus:@"active" tabBarImage:@"list1"];
    UIViewController *view2 = [[VMZOwesTableViewController alloc] initWithStatus:@"requested" tabBarImage:@"pending1"];
    UIViewController *view3 = [[VMZOwesTableViewController alloc] initWithStatus:@"closed" tabBarImage:@"stack"];
    
    [self setViewControllers:@[view1, view2, view3]];
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
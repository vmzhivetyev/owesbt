//
//  VMZOweTabsViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOweTabsViewController.h"
#import "VMZOwesTableViewController.h"
#import "VMZNewOweViewController.h"

@interface VMZOweTabsViewController ()

@end

@implementation VMZOweTabsViewController

- (void)plusButtonClicked:(UIBarButtonItem *)button
{
    UIViewController *view = [VMZNewOweViewController new];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *view1 = [[VMZOwesTableViewController alloc] initWithStatus:@"active" tabBarImage:@"list1"];
    UIViewController *view2 = [[VMZOwesTableViewController alloc] initWithStatus:@"requested" tabBarImage:@"pending1"];
    UIViewController *view3 = [[VMZOwesTableViewController alloc] initWithStatus:@"closed" tabBarImage:@"stack"];
    
    [self setViewControllers:@[view1, view2, view3]];
    
    UIBarButtonItem *plusButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(plusButtonClicked:)];
    self.navigationItem.rightBarButtonItem = plusButton;
    
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

//
//  VMZOweTabsViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZNavigationController.h"
#import "VMZOwesTableViewController.h"
#import "VMZNewOweViewController.h"
#import "VMZOweController.h"

@interface VMZNavigationController ()

@end

@implementation VMZNavigationController

- (void)plusButtonClicked:(UIBarButtonItem *)button
{
    UIViewController *view = [VMZNewOweViewController new];
    [self pushViewController:view animated:YES];
}

- (instancetype)init
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    self = [super initWithRootViewController:tabBarController];
    if (self)
    {
        UIViewController *view1 = [[VMZOwesTableViewController alloc] initWithStatus:@"active" tabBarImage:@"list1"];
        UIViewController *view2 = [[VMZOwesTableViewController alloc] initWithStatus:@"requested" tabBarImage:@"pending1"];
        UIViewController *view3 = [[VMZOwesTableViewController alloc] initWithStatus:@"closed" tabBarImage:@"stack"];
        
        [tabBarController setViewControllers:@[view1, view2, view3]];
        
        UIBarButtonItem *plusButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(plusButtonClicked:)];
        tabBarController.navigationItem.rightBarButtonItem = plusButton;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[VMZOweController sharedInstance] loggedInViewControllerDidLoad];
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

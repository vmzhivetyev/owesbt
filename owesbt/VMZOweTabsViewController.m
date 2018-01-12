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
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    VMZOwesTableViewController *view1 = [[VMZOwesTableViewController alloc] initWithStatus:@"active"];
    VMZOwesTableViewController *view2 = [[VMZOwesTableViewController alloc] init];
    VMZOwesTableViewController *view3 = [[VMZOwesTableViewController alloc] init];
    
    NSArray *tabViewControllers = @[view1, view2, view3];
    
    [self setViewControllers:tabViewControllers];
    
    view1.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"view1"
                                  image:[UIImage imageNamed:@"list1"]
                                    tag:1];
    view2.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"view2"
                                  image:[UIImage imageNamed:@"pending1"]
                                    tag:2];
    view3.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"view3"
                                  image:[UIImage imageNamed:@"stack"]
                                    tag:3];
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

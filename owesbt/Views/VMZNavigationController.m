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
#import "VMZOweData+CoreDataClass.h"

@interface VMZNavigationController ()

@property (nonatomic, weak) UISearchController *searchController;

@end


@implementation VMZNavigationController


#pragma mark - UI

- (void)plusButtonClicked:(UIBarButtonItem *)button
{
    UIViewController *view = [VMZNewOweViewController new];
    [self pushViewController:view animated:YES];
}

- (void)dismissKeyboard
{
    [self.searchController.searchBar endEditing:YES];
}

- (void)createUI:(UITabBarController *)tabBarController
{
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController = searchController;
    self.searchController.searchBar.placeholder = @"Search by description or name";
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    tabBarController.navigationItem.searchController = self.searchController;
    
    NSArray *statuses = @[[VMZOweData stringFromStatus:VMZOweStatusActive],
                          [VMZOweData stringFromStatus:VMZOweStatusRequested],
                          [VMZOweData stringFromStatus:VMZOweStatusClosed]];
    NSArray *images = @[@"list1", @"pending1", @"stack"];
    
    for(NSInteger i = 0; i < [statuses count]; i++)
    {
        [tabBarController addChildViewController:[[VMZOwesTableViewController alloc] initWithStatus:statuses[i] tabBarImage:images[i]]];
    }
    
    UIBarButtonItem *plusButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(plusButtonClicked:)];
    tabBarController.navigationItem.rightBarButtonItem = plusButton;
    self.navigationBar.prefersLargeTitles = YES;
}


#pragma mark - Lifecycle

- (instancetype)init
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    self = [super initWithRootViewController:tabBarController];
    if (self)
    {
        [self createUI:tabBarController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[VMZOweController sharedInstance] loggedInViewControllerDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

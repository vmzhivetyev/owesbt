//
//  VMZOweTabsViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZNavigationController.h"
#import "VMZOwesTableViewController.h"
#import "VMZOweViewController.h"
#import "VMZOweController.h"
#import "VMZOweData+CoreDataClass.h"

#import "VMZOwesActiveViewController.h"
#import "VMZOwesRequestedViewController.h"
#import "VMZOwesClosedViewController.h"
#import "VMZGroupsViewController.h"
#import "VMZUIController.h"

@interface VMZNavigationController ()

@property (nonatomic, weak) UISearchController *searchController;

@end


@implementation VMZNavigationController


#pragma mark - UI Selectors

- (void)plusButtonClicked:(UIBarButtonItem *)button
{
    [self pushViewController:[VMZUIController newOweViewController] animated:YES];
}

- (void)groupButtonClicked:(UIBarButtonItem *)button
{
    [self pushViewController:[VMZUIController groupsViewController] animated:YES];
}


#pragma mark - UI

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
    
    [tabBarController addChildViewController:[[VMZOwesActiveViewController alloc] init]];
    [tabBarController addChildViewController:[[VMZOwesRequestedViewController alloc] init]];
    [tabBarController addChildViewController:[[VMZOwesClosedViewController alloc] init]];
    
    UIBarButtonItem *plusButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(plusButtonClicked:)];
    tabBarController.navigationItem.rightBarButtonItem = plusButton;
    
    UIBarButtonItem *groupButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                  target:self
                                                  action:@selector(groupButtonClicked:)];
    tabBarController.navigationItem.leftBarButtonItem = groupButton;
    
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

@end

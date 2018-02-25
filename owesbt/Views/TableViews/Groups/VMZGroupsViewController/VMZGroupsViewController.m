//
//  VMZGroupsViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 25.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZGroupsViewController.h"

#import "VMZGroupViewController.h"
#import "VMZOweController.h"
#import "VMZCoreDataManager.h"
#import "VMZOweGroup+CoreDataClass.h"

NSString * const VMZCellIdentifier = @"VMZGroupInfoCell";


@interface VMZGroupsViewController ()

@property (nonatomic, strong) NSArray<VMZOweGroup *> *cells;

@end


@implementation VMZGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(addButtonTapped)];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:VMZCellIdentifier];
    
    self.cells = [[VMZOweController sharedInstance].coreDataManager groups];
}

- (void)addButtonTapped
{
    UIViewController *newGroupViewController = [[VMZGroupViewController alloc] init];
    [self.navigationController pushViewController:newGroupViewController animated:YES];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self removeMemberAtIndexPath:indexPath];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VMZCellIdentifier
                                                            forIndexPath:indexPath];
    
    cell.textLabel.text = self.cells[indexPath.row].name;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

@end

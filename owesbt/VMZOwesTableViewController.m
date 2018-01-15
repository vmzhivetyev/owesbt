//
//  VMZOwesTableViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Masonry.h>

#import "VMZOwesTableViewController.h"
#import "VMZOwe.h"
#import "VMZOweData+CoreDataClass.h"
#import "VMZCoreDataManager.h"
#import "VMZOwesTableViewCell.h"
#import "UIViewController+Extension.h"

@interface VMZOwesTableViewController ()

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *owesToDisplay;
@property (nonatomic, copy, readonly) NSString *cellIdentifier;

@end

@implementation VMZOwesTableViewController


#pragma mark - VMZOweUIDelegate

- (void)updateData
{
    _owesToDisplay = @[
                       [[[VMZCoreDataManager sharedInstance] owesForStatus:self.owesStatus selfIsDebtor:YES] mutableCopy],
                       [[[VMZCoreDataManager sharedInstance] owesForStatus:self.owesStatus selfIsDebtor:NO]  mutableCopy]
                     ];
    [self.tableView reloadData];
}

- (void)VMZOwesCoreDataDidUpdate
{
    [self updateData];
    [self.refreshControl endRefreshing];
}


#pragma mark - UI

- (void)refresh:(UIRefreshControl*)sender
{
    [[VMZOwe sharedInstance] downloadOwes:self.owesStatus];
}


#pragma mark - Lifecycle

- (instancetype)init
{
    return [self initWithStatus:nil tabBarImage:nil];
}

- (instancetype)initWithStatus:(NSString*)status tabBarImage:(NSString*)imageName
{
    self = [super init];
    if(self)
    {
        _owesStatus = status;
        _cellIdentifier = @"reusableCellId";
        
        if(imageName)
        {
            self.tabBarItem = [[UITabBarItem alloc] initWithTitle:_owesStatus
                                                            image:[UIImage imageNamed:imageName]
                                                              tag:1];
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init instances
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    self.tableView.refreshControl = self.refreshControl;
    
    //additional init
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerClass:[VMZOwesTableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self updateData];
    [self refresh:self.refreshControl];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [VMZOwe sharedInstance].uiDelegate = self;
    
    [self updateData];
    
    self.parentViewController.navigationItem.title = self.owesStatus;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *status = [self oweForIndexPath:indexPath].status;
    if ([status isEqualToString:@"active"])
    {
        NSString *message = @"Вы действительно вернули себе этот долг и хотите пометить его закрытым?";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Active Owe" message:message preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction: [UIAlertAction actionWithTitle:@"Close Owe" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //[self showMessagePrompt:@"CLOSED"];
            /*[tableView beginUpdates];
            [_owesToDisplay[indexPath.section] removeObject:[self oweForIndexPath:indexPath]];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];*/
            
            [[VMZCoreDataManager sharedInstance] closeOwe:[self oweForIndexPath:indexPath]];
        }]];
        [alert addAction: [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [self.owesToDisplay[section] count];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self numberOfRowsInSection:section];
    return count > 0 ? count : 1;
}

- (VMZOweData *)oweForIndexPath:(NSIndexPath *)indexPath
{
    return (VMZOweData*)self.owesToDisplay[indexPath.section][indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VMZOwesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    VMZOweData *owe = [self numberOfRowsInSection:indexPath.section] > 0 ? [self oweForIndexPath:indexPath] : nil;
    [cell loadOweData:owe];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(tableView.frame), 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string = @[@"You owe", @"You are creditor"][section];
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 18)];
    return view;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end

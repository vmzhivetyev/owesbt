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
#import "UIViewController+VMZExtensions.h"
#import "VMZNewOweViewController.h"
#import "NSString+VMZExtensions.h"

@interface VMZOwesTableViewController ()

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *owesToDisplay;
@property (nonatomic, copy, readonly) NSString *cellIdentifier;

@end

@implementation VMZOwesTableViewController


- (void)updateData
{
    _owesToDisplay = @[
                       [[[VMZCoreDataManager sharedInstance] owesForStatus:self.owesStatus selfIsDebtor:YES] mutableCopy],
                       [[[VMZCoreDataManager sharedInstance] owesForStatus:self.owesStatus selfIsDebtor:NO]  mutableCopy]
                       ];
    [self.tableView reloadData];
}


#pragma mark - VMZOweUIDelegate

- (void)VMZOwesCoreDataDidUpdate
{
    [self updateData];
}


#pragma mark - UI

- (void)refresh:(UIRefreshControl*)sender
{
    [[VMZOwe sharedInstance] downloadOwes:self.owesStatus completion:^(NSError * _Nullable error) {
        [sender endRefreshing];
        
        if (error)
        {
            [self showMessagePrompt:error.localizedDescription];
        }
    }];
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

- (void)dealloc
{
    [[VMZOwe sharedInstance] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[VMZOwe sharedInstance] addDelegate:self];
    
    //init instances
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
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
    self.tableView.sectionHeaderHeight = 28;
    self.tableView.sectionFooterHeight = 18;
    
    [self.tableView registerClass:[VMZOwesTableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self updateData];
    [self refresh:self.refreshControl];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [VMZOwe sharedInstance].currentViewController = self;
    
    [self updateData];
    
    self.parentViewController.title = [[self.owesStatus uppercaseFirstLetter] stringByAppendingString:@" Owes"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)removeAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.owesToDisplay[indexPath.section] removeObjectAtIndex:indexPath.row];
    if ([self.owesToDisplay[indexPath.section] count] == 0)
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VMZOweData *owe = [self oweForIndexPath:indexPath];
    UIViewController *view = [[VMZNewOweViewController alloc] initWithOwe:owe];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    VMZOweData *owe = [self oweForIndexPath:indexPath];
    NSString *status = owe.status;
    NSString *message, *title;
    NSMutableArray *actions = [NSMutableArray new];
    if ([status isEqualToString:@"active"])
    {
        message = @"Вы действительно вернули себе этот долг и хотите пометить его закрытым?";
        title = @"Active Owe";
        [actions addObject: [UIAlertAction actionWithTitle:@"Close Owe" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[VMZOwe sharedInstance] closeOwe:[self oweForIndexPath:indexPath]];
            [self removeAtIndexPath:indexPath];
        }]];
    }
    else if ([status isEqualToString:@"requested"])
    {
        message = [owe selfIsCreditor] ? @"Отменить запрос?" : @"Подтвердить вашу задолжность?";
        title = @"Requested Owe";
        if (![owe selfIsCreditor])
        {
            [actions addObject: [UIAlertAction actionWithTitle:@"Confirm request" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        
                [[VMZOwe sharedInstance] confirmOwe:[self oweForIndexPath:indexPath]];
                [self removeAtIndexPath:indexPath];
            }]];
        }
        [actions addObject: [UIAlertAction actionWithTitle:@"Cancel request" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
            [[VMZOwe sharedInstance] cancelRequestForOwe:[self oweForIndexPath:indexPath]];
            [self removeAtIndexPath:indexPath];
        }]];
    }
    
    if (message)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        
        for(UIAlertAction *action in actions)
        {
            [alert addAction:action];
        }
        [alert addAction: [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [self.owesToDisplay[section] count];
}

- (VMZOweData *)oweForIndexPath:(NSIndexPath *)indexPath
{
    return (VMZOweData*)self.owesToDisplay[indexPath.section][indexPath.row];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self numberOfRowsInSection:section];
    return count > 0 ? count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VMZOwesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    VMZOweData *owe = [self numberOfRowsInSection:indexPath.section] > 0 ? [self oweForIndexPath:indexPath] : nil;
    [cell loadOweData:owe];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    UILabel *label = [UILabel new];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [label setText: @[@"You owe", @"You are creditor"][section] ];
    label.textAlignment = NSTextAlignmentNatural;
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view).offset(-5);
        make.left.equalTo(view).offset(10);
    }];
    
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

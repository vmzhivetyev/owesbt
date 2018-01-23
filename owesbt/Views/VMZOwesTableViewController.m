//
//  VMZOwesTableViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Masonry.h>

#import "VMZOwesTableViewController.h"
#import "VMZOweController.h"
#import "VMZOweNetworking.h"
#import "VMZOweData+CoreDataClass.h"
#import "VMZCoreDataManager.h"
#import "VMZOwesTableViewCell.h"
#import "UIViewController+VMZExtensions.h"
#import "VMZNewOweViewController.h"
#import "NSString+VMZExtensions.h"

@interface VMZOwesTableViewController ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIRefreshControl *refreshControl;
@property (nonatomic, weak) UISearchController *searchController;

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *owes;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *owesToDisplay;
@property (nonatomic, strong) NSArray<NSNumber *> *sums;

@property (nonatomic, copy, readonly) NSString *cellIdentifier;
@property (nonatomic, copy, readonly) NSString *headerIdentifier;
@property (nonatomic, copy, readonly) NSString *footerIdentifier;

@property (nonatomic, strong) id<UIViewControllerPreviewing> previewingContext;

@end

@implementation VMZOwesTableViewController

- (void)recountSums
{
    NSMutableArray *sums = @[@0, @0].mutableCopy;
    for(NSInteger i = 0; i < self.owesToDisplay.count; i++)
    {
        __block NSInteger count = 0;
        for (VMZOweData *data in self.owesToDisplay[i])
        {
            count += [data.sum integerValue];
        }
        sums[i] = @(count);
    }
    self.sums = sums;
}

- (NSMutableArray<NSMutableArray *> *)owesToDisplay
{
    if (self.searchController.isActive && [self.searchController.searchBar.text length] > 0)
    {
        return _owesToDisplay;
    }
    return _owes;
}

- (void)updateData
{
    VMZCoreDataManager *coreDataMgr = [VMZOweController sharedInstance].coreDataManager;
    _owes = @[
              [[coreDataMgr owesForStatus:self.owesStatus selfIsDebtor:YES] mutableCopy],
              [[coreDataMgr owesForStatus:self.owesStatus selfIsDebtor:NO]  mutableCopy]
              ].mutableCopy;
    
    [self recountSums];
    
    [self.tableView reloadData];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *text = searchController.searchBar.text;
    if ([text length] == 0)
    {
        [self.tableView reloadData];
        return;
    }
    NSString *string =
        [NSString stringWithFormat:@"(descr CONTAINS[c] '%1$@') || (partnerName CONTAINS[c] '%1$@')", text];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    for(NSInteger i = 0; i < 2; i++)
    {
        _owesToDisplay[i] = [_owes[i] filteredArrayUsingPredicate:predicate].mutableCopy;
    }
    
    [self recountSums];
    
    [self.tableView reloadData];
}


#pragma mark - VMZOweDelegate

- (void)VMZOwesCoreDataDidUpdate
{
    [self updateData];
}

- (void)VMZOweErrorOccured:(NSString *)error
{
    [self VMZShowMessagePrompt:error];
}


#pragma mark - UI

- (void)refresh:(UIRefreshControl*)sender
{
    [[VMZOweController sharedInstance] refreshOwesWithStatus:self.owesStatus completion:^(NSError * _Nullable error) {
        [sender endRefreshing];
        
        if (error)
        {
            [self VMZShowMessagePrompt:error.localizedDescription];
        }
    }];
}

- (void)removeOweAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.owesToDisplay[indexPath.section] removeObjectAtIndex:indexPath.row];
    if (self.owesToDisplay[indexPath.section].count == 0)
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}

- (VMZOweData *)oweAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.owesToDisplay[indexPath.section].count == 0)
    {
        return nil;
    }
    return (VMZOweData*)self.owesToDisplay[indexPath.section][indexPath.row];
}

- (void)presentOweActionsAlertViewAtIndexPath:(NSIndexPath *)indexPath
{
    VMZOweData *owe = [self oweAtIndexPath:indexPath];
    if (!owe)
    {
        return;
    }
    
    NSString *message, *title;
    NSMutableArray *actions = [NSMutableArray new];
    if (owe.statusType == VMZOweStatusActive)
    {
        message = @"Вы действительно вернули себе этот долг и хотите пометить его закрытым?";
        title = @"Active Owe";
        [actions addObject: [UIAlertAction actionWithTitle:@"Close Owe" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[VMZOweController sharedInstance] closeOwe:owe];
            [self removeOweAtIndexPath:indexPath];
        }]];
    }
    else if (owe.statusType == VMZOweStatusRequested)
    {
        message = [owe selfIsCreditor] ? @"Отменить запрос?" : @"Подтвердить вашу задолжность?";
        title = @"Requested Owe";
        if (![owe selfIsCreditor])
        {
            [actions addObject: [UIAlertAction actionWithTitle:@"Confirm request" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [[VMZOweController sharedInstance] confirmOwe:owe];
                [self removeOweAtIndexPath:indexPath];
            }]];
        }
        [actions addObject: [UIAlertAction actionWithTitle:@"Cancel request" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[VMZOweController sharedInstance] cancelOwe:owe];
            [self removeOweAtIndexPath:indexPath];
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

- (NSArray *)forceTouchActionsForOweAtIndexPath:(NSIndexPath *)indexPath
{
    VMZOweData *owe = [self oweAtIndexPath:indexPath];
    
    NSString *status = owe.status;
    NSString *message, *title;
    NSMutableArray *actions = [NSMutableArray new];
    if (owe.statusType == VMZOweStatusActive && [owe selfIsCreditor])
    {
        message = @"Вы действительно вернули себе этот долг и хотите пометить его закрытым?";
        title = @"Active Owe";
        
        [actions addObject: [UIPreviewAction actionWithTitle:@"Close Owe" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
            
            [[VMZOweController sharedInstance] closeOwe:owe];
            [self removeOweAtIndexPath:indexPath];
        }]];
    }
    else if (owe.statusType == VMZOweStatusRequested)
    {
        message = [owe selfIsCreditor] ? @"Отменить запрос?" : @"Подтвердить вашу задолжность?";
        title = @"Requested Owe";
        if (![owe selfIsCreditor])
        {
            [actions addObject: [UIPreviewAction actionWithTitle:@"Confirm request" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
                
                [[VMZOweController sharedInstance] confirmOwe:owe];
                [self removeOweAtIndexPath:indexPath];
            }]];
        }
        [actions addObject: [UIPreviewAction actionWithTitle:@"Cancel request" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
            
            [[VMZOweController sharedInstance] cancelOwe:owe];
            [self removeOweAtIndexPath:indexPath];
        }]];
    }
    
    return actions;
}

- (void)createUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    self.tableView.refreshControl = self.refreshControl;
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.sectionHeaderHeight = 28;
    self.tableView.sectionFooterHeight = 18;
    
    [self.tableView registerClass:[VMZOwesTableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    [self.tableView
     registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:self.headerIdentifier];
    [self.tableView
     registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:self.footerIdentifier];
    
    
    self.searchController = self.parentViewController.navigationItem.searchController;
}


#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    CGPoint cellPostion = [self.tableView convertPoint:location fromView:self.view];
    
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:cellPostion];
    
    if (path)
    {
        VMZOweData *owe = [self oweAtIndexPath:path];
        if (owe)
        {
            UITableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:path];
            
            VMZNewOweViewController *previewController =
                [[VMZNewOweViewController alloc] initWithOwe:owe forceTouchActions:[self forceTouchActionsForOweAtIndexPath:path]];
            
            previewingContext.sourceRect = [self.view convertRect:tableCell.frame fromView:self.tableView];
            return previewController;
        }
    }
    
    return nil;
}

-(void)previewingContext:(id )previewingContext commitViewController: (UIViewController *)viewControllerToCommit
{
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}


#pragma mark - Lifecycle

- (instancetype)init
{
    return nil;
}

- (instancetype)initWithStatus:(NSString*)status tabBarImage:(NSString*)imageName
{
    self = [super init];
    if(self)
    {
        _owesStatus = status;
        _cellIdentifier = @"VMZReusableCellId";
        _headerIdentifier = @"VMZHeaderId";
        _footerIdentifier = @"VMZFooterId";
        _owesToDisplay = @[@[].mutableCopy,@[].mutableCopy].mutableCopy;
        
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
    [[VMZOweController sharedInstance] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[VMZOweController sharedInstance] addDelegate:self];
    
    [self createUI];
    
    [self updateData];
    [self refresh:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateData];
    self.searchController.searchResultsUpdater = self;
    [self updateSearchResultsForSearchController:self.searchController];
    
    self.parentViewController.title = [[self.owesStatus VMZUppercaseFirstLetter] stringByAppendingString:@" Owes"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)])
    {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
        {
            if (!self.previewingContext)
            {
                self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
            }
        }
        else
        {
            [self unregisterForPreviewingWithContext:self.previewingContext];
            self.previewingContext = nil;
        }
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VMZOweData *owe = [self oweAtIndexPath:indexPath];
    if (!owe)
    {
        return;
    }
    
    UIViewController *view = [[VMZNewOweViewController alloc] initWithOwe:owe forceTouchActions:nil];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self presentOweActionsAlertViewAtIndexPath:indexPath];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return self.owesToDisplay[section].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self numberOfRowsInSection:section];
    return count > 0 ? count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VMZOwesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    VMZOweData *owe = [self oweAtIndexPath:indexPath];
    [cell loadOweData:owe];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:self.footerIdentifier];
    footer.textLabel.text = [NSString stringWithFormat:@"Total: %@", self.sums[section]];
    footer.frame = self.tableView.frame;
    footer.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return footer;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:self.headerIdentifier];
    header.textLabel.text = @[@"You owe", @"You are creditor"][section];
    header.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return header;
}

@end

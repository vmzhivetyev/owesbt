//
//  VMZOwesTableViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOwesTableViewController.h"

#import <Masonry.h>

#import "VMZOweController.h"
#import "VMZUIController.h"
#import "VMZOweNetworking.h"
#import "VMZCoreDataManager.h"

#import "VMZOweData+CoreDataClass.h"
#import "VMZOweTableViewCell.h"
#import "VMZOweViewController.h"

#import "UIViewController+MessagePrompt.h"
#import "NSString+Formatting.h"


NSString *const cellIdentifier = @"VMZReusableCellId";
NSString *const headerIdentifier = @"VMZReusableHeaderId";
NSString *const footerIdentifier = @"VMZReusableFooterId";


@interface VMZOwesTableViewController ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIRefreshControl *refreshControl;
@property (nonatomic, weak) UISearchController *searchController;

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *owes;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *owesToDisplay;
@property (nonatomic, strong) NSArray<NSNumber *> *sums;


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
    self.owes = @[
                  [[coreDataMgr owesForStatus:self.owesStatus selfIsDebtor:YES] mutableCopy],
                  [[coreDataMgr owesForStatus:self.owesStatus selfIsDebtor:NO]  mutableCopy]
                  ].mutableCopy;
    
    [self recountSums];
    
    [self.tableView reloadData];
}

- (void)filterOwesToDisplayForText:(NSString *)text
{
    if ([text length] == 0)
    {
        [self.tableView reloadData];
        return;
    }
    
    NSString *string = [NSString stringWithFormat:
                        @"(descr CONTAINS[c] '%1$@') || (partnerName CONTAINS[c] '%1$@') || (partner CONTAINS[c] '%1$@')", text];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    self.owesToDisplay = [NSMutableArray new];
    for(NSInteger i = 0; i < self.owes.count; i++)
    {
        [self.owesToDisplay addObject:[NSMutableArray new]];
        self.owesToDisplay[i] = [self.owes[i] filteredArrayUsingPredicate:predicate].mutableCopy;
    }
    
    [self recountSums];
    
    [self.tableView reloadData];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *text = searchController.searchBar.text;
    
    [self filterOwesToDisplayForText:text];
}


#pragma mark - VMZOweDelegate

- (void)VMZOwesCoreDataDidUpdate
{
    [self updateData];
}

- (void)VMZOweErrorOccured:(NSString *)error
{
    [self mp_showMessagePrompt:error];
}


#pragma mark - UI

- (void)refresh:(UIRefreshControl*)sender
{
    [[VMZOweController sharedInstance] refreshOwesWithStatus:self.owesStatus completion:^(NSError * _Nullable error) {
        [sender endRefreshing];
        
        if (error && sender)
        {
            [self mp_showMessagePrompt:error.localizedDescription];
        }
    }];
}

- (VMZOweData *)oweAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.owesToDisplay[indexPath.section].count == 0)
    {
        return nil;
    }
    return (VMZOweData*)self.owesToDisplay[indexPath.section][indexPath.row];
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

- (NSString *)titleForActionsAlertForOwe:(VMZOweData *)owe
{
    return [[self.owesStatus stringByAppendingString:@" Owe"] ft_uppercaseFirstLetter];
}

- (NSString *)messageForActionsAlertForOwe:(VMZOweData *)owe
{
    return nil;
}

- (NSArray *)actionsForOwe:(VMZOweData*)owe atIndexPath:(NSIndexPath *)indexPath
{
    return @[ [self cancelActionForOwe: owe] ];
}

- (UIAlertAction *)cancelActionForOwe:(VMZOweData *)owe
{
    return [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
}

- (void)presentOweActionsAlertViewAtIndexPath:(NSIndexPath *)indexPath
{
    VMZOweData *owe = [self oweAtIndexPath:indexPath];
    if (!owe)
    {
        return;
    }
    
    NSString *title = [self titleForActionsAlertForOwe: owe];
    NSString *message = [self messageForActionsAlertForOwe: owe];
    NSArray *actions = [self actionsForOwe:owe atIndexPath:indexPath];
    
    if (actions)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        for(UIAlertAction *action in actions)
        {
            [alert addAction:action];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
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
    
    self.tableView.sectionHeaderHeight = 40;
    self.tableView.sectionFooterHeight = 30;
    
    [self.tableView registerClass:[VMZOweTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.tableView
     registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:headerIdentifier];
    [self.tableView
     registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:footerIdentifier];
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
            
            VMZOweViewController *previewController =
                [[VMZOweViewController alloc] initWithOwe:owe forceTouchActions:nil];
            
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
    return [self initWithStatus:VMZOweStatusUndefined tabBarImage:nil];
}

- (instancetype)initWithStatus:(VMZOweStatus)status tabBarImage:(NSString*)imageName
{
    self = [super init];
    if(self)
    {
        _owesStatus = [VMZOweData stringFromStatus:status];
        
        if(imageName)
        {
            self.tabBarItem = [[UITabBarItem alloc] initWithTitle:_owesStatus
                                                            image:[UIImage imageNamed:imageName]
                                                              tag:1];
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
    
    self.searchController = self.parentViewController.navigationItem.searchController;
    
    [self refresh:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [VMZOweController sharedInstance].delegate = self;
    
    self.searchController.searchResultsUpdater = self;
    
    [self updateData];
    
    [self updateSearchResultsForSearchController:self.searchController];
    
    self.parentViewController.title = [[self.owesStatus ft_uppercaseFirstLetter] stringByAppendingString:@" Owes"];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    //чекаем есть ли forcetouch
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
    
    UIViewController *view = [VMZUIController viewControllerForOwe:owe];
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
    VMZOweTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    VMZOweData *owe = [self oweAtIndexPath:indexPath];
    [cell loadOweData:owe];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerIdentifier];
    footer.textLabel.text = [NSString stringWithFormat:@"Total: %@", self.sums[section]];
    footer.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return footer;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    header.textLabel.text = @[@"You owe", @"You are creditor"][section];
    header.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end

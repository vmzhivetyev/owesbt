//
//  VMZUITableViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 20.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZUITableViewController.h"

#import <Masonry.h>


@interface VMZUITableViewController ()


@end


@implementation VMZUITableViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                          style:UITableViewStyleGrouped];
    _tableView = tableView;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.allowsSelection = NO;
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


@end

//
//  VMZUITableViewController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 20.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMZUITableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak, readonly) UITableView *tableView;

@end

//
//  (UpdatesBlock).h
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (UpdatesBlock)

- (void)ub_doUpdates:(void (^_Nonnull)(UITableView *  _Nonnull tableView))updatesBlock;

@end

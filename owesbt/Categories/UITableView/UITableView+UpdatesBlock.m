//
//  (UpdatesBlock).m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "UITableView+UpdatesBlock.h"

@implementation UITableView (UpdatesBlock)

- (void)ub_doUpdates:(void (^)(UITableView *tableView))updatesBlock
{
    [self beginUpdates];
    updatesBlock(self);
    [self endUpdates];
}

@end

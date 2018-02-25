//
//  VMZOweTableViewCell.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@class VMZOweData;


@interface VMZOweTableViewCell : UITableViewCell

- (void)loadOweData:(VMZOweData *)owe;

@end

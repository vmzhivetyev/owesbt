//
//  VMZPersonTableViewCell.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 14.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMZUITextField.h"


@class VMZContact;


@interface VMZContactTableViewCell : UITableViewCell

@property (nonatomic, weak) VMZUITextField *nameTextField;
@property (nonatomic, weak) VMZUITextField *phoneTextField;
@property (nonatomic, strong) VMZContact *contact;
@property (nonatomic, copy) void (^accessoryTappedBlock)(NSIndexPath *);

- (void)showContact:(VMZContact *)contact;

@end

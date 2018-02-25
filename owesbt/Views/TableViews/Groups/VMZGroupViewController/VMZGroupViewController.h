//
//  VMZGroupViewController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VMZUITextField.h"
#import "VMZUITableViewController.h"


@protocol CNContactPickerDelegate;
@class VMZOweGroup;


@interface VMZGroupViewController : VMZUITableViewController <CNContactPickerDelegate>

- (instancetype)initWithGroup:(VMZOweGroup *)group forceTouchActions:(NSArray *)actions;

@end

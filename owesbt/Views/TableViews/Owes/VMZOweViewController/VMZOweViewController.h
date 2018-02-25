//
//  VMZOweViewController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 16.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CNContactPickerDelegate;
@protocol VMZOweDelegate;
@class VMZOwesTableViewController;
@class VMZOweData;


@interface VMZOweViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, VMZOweDelegate, UITextFieldDelegate, CNContactPickerDelegate>

- (instancetype)initWithOwe:(VMZOweData *)owe forceTouchActions:(NSArray *)actions;

@end

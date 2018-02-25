//
//  VMZGroupsViewController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VMZUITextField.h"
#import "VMZUITableViewController.h"


@protocol CNContactPickerDelegate;

/*
@interface VMZGroupOweUIs

@property (nonatomic, strong) VMZUITextField *sumTextField;
@property (nonatomic, strong) VMZUITextField *descriptionTextField;
@property (nonatomic, strong) VMZUITextField *creditorTextField;

@end*/


@interface VMZGroupsViewController : VMZUITableViewController <CNContactPickerDelegate>

@end


/*
 
 
 :Name:
 ------------------
 Group name
 ------------------
 
 :Members:
 ------------------
 Name
 Phone
             Remove
 ------------------
 Name
 Phone
             Remove
 ------------------
                Add
 ------------------
 
 :Owes:
 ------------------
 1000 taxi Creditor
 ------------------
                Add
 ------------------
 
 
 */

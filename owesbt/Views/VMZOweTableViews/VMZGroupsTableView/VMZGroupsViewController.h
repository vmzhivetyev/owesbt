//
//  VMZGroupsViewController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CNContactPickerDelegate;


@interface VMZGroupOweUIs

@property (nonatomic, strong) UITextField *sumTextField;
@property (nonatomic, strong) UITextField *descriptionTextField;
@property (nonatomic, strong) UITextField *creditorTextField;

@end

@interface VMZGroupsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate>

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

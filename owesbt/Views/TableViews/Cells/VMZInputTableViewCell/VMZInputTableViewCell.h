//
//  VMZInputTableViewCell.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 07.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMZUITextField.h"


@class VMZUITextFieldController;


@interface VMZInputTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) VMZUITextField *textField;

@property (nonatomic, copy) void (^accessoryTappedBlock)(NSIndexPath *);

- (instancetype)initWithPlaceholder:(NSString *)placeholder
                       keyboardType:(UIKeyboardType)keyboardType
                    textFieldInsets:(UIEdgeInsets)insets
                           readOnly:(BOOL)readonly
                  allowedCharacters:(NSString *)characters NS_DESIGNATED_INITIALIZER;

@end

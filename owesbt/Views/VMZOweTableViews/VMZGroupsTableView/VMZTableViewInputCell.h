//
//  VMZTableViewInputCell.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 07.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMZTableViewInputCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *textField;

@property (nonatomic, assign, readonly) BOOL readonly;
@property (nonatomic, strong, readonly) NSCharacterSet *allowedCharacters;

@property (nonatomic, copy) NSString *sectionHeader;
@property (nonatomic, copy) void (^accessoryTappedBlock)(NSIndexPath *);

- (instancetype)initWithPlaceholder:(NSString *)placeholder
                       keyboardType:(UIKeyboardType)keyboardType
                    textFieldInsets:(UIEdgeInsets)insets
                           readOnly:(BOOL)readonly
                  allowedCharacters:(NSString *)characters NS_DESIGNATED_INITIALIZER;

@end

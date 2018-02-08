//
//  VMZTableViewInputCell.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 07.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZTableViewInputCell.h"

#import <Masonry.h>


@interface VMZTableViewInputCell ()

@end


@implementation VMZTableViewInputCell


#pragma mark - Lifecycle

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createUI:(const UIEdgeInsets *)insets keyboardType:(UIKeyboardType)keyboardType placeholder:(NSString *)placeholder
{
    UITextField *textField = [UITextField new];
    _textField = textField;
    _textField.placeholder = placeholder;
    _textField.keyboardType = keyboardType;
    _textField.delegate = self;
    [self.contentView addSubview:textField];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(*insets);
    }];

    if (_readonly)
    {
        _textField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (instancetype)initWithPlaceholder:(NSString *)placeholder
                       keyboardType:(UIKeyboardType)keyboardType
                    textFieldInsets:(UIEdgeInsets)insets
                           readOnly:(BOOL)readonly
                  allowedCharacters:(NSString *)characters
{
    self = [super init];
    if (self)
    {
        _readonly = readonly;
        _allowedCharacters = !characters ?
                                     nil : [NSCharacterSet characterSetWithCharactersInString:characters];
        _accessoryTappedBlock = ^void(NSIndexPath *indexPath){ };
        
        [self createUI:&insets keyboardType:keyboardType placeholder:placeholder];
    }
    return self;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.allowedCharacters)
    {
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
        
        return [self.allowedCharacters isSupersetOfSet:characterSetFromTextField];
    }
    return !self.readonly;
}

@end

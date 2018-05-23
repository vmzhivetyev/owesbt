//
//  VMZInputTableViewCell.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 07.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZInputTableViewCell.h"

#import <Masonry.h>

#import "VMZUITextFieldController.h"


@implementation VMZInputTableViewCell


#pragma mark - Lifecycle

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createUI:(const UIEdgeInsets *)insets keyboardType:(UIKeyboardType)keyboardType placeholder:(NSString *)placeholder
{
    VMZUITextField *textField = [[VMZUITextField alloc] init];
    _textField = textField;
    _textField.placeholder = placeholder;
    _textField.keyboardType = keyboardType;
    [self.contentView addSubview:textField];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(*insets);
    }];
}

- (instancetype)initWithPlaceholder:(NSString *)placeholder
                       keyboardType:(UIKeyboardType)keyboardType
                    textFieldInsets:(UIEdgeInsets)insets
                           readOnly:(BOOL)readonly
                  allowedCharacters:(NSString *)allowedCharacters
{
    self = [super init];
    if (self)
    {
        [self createUI:&insets keyboardType:keyboardType placeholder:placeholder];
        
        NSCharacterSet *allowedCharactersSet = allowedCharacters ?
            [NSCharacterSet characterSetWithCharactersInString:allowedCharacters] : nil;
        
        _textField.controller =
            [[VMZUITextFieldController alloc] initWithTextField:_textField
                                                       readonly:readonly
                                              allowedCharacters:allowedCharactersSet];
        
        _accessoryTappedBlock = ^void(NSIndexPath *indexPath){ };
        
    }
    return self;
}

- (instancetype)init
{
    self = nil;
    return self;
}

@end

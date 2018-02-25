//
//  VMZPersonTableViewCell.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 14.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZContactTableViewCell.h"

#import <Masonry.h>

#import "VMZContact.h"
#import "VMZUITextFieldController.h"


@interface VMZContactTableViewCell ()

@end


@implementation VMZContactTableViewCell


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self createUI];
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return self;
}

- (void)createUI
{
    VMZUITextField *nameTextField = [[VMZUITextField alloc] initReadonly];
    self.nameTextField = nameTextField;
    
    VMZUITextField *phoneTextField = [[VMZUITextField alloc] initReadonly];
    self.phoneTextField = phoneTextField;
    phoneTextField.textColor = [UIColor lightGrayColor];
    phoneTextField.font = [UIFont systemFontOfSize:UIFont.smallSystemFontSize];
    
    [self.contentView addSubview:nameTextField];
    [self.contentView addSubview:phoneTextField];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 20, 10, 10);
    [nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView).insets(insets);
    }];
    [phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameTextField.mas_bottom).offset(5);
        make.left.right.bottom.equalTo(self.contentView).insets(insets);
    }];
}


#pragma mark - Public

-(void)showContact:(VMZContact *)contact
{
    _contact = contact;
    
    self.nameTextField.text = _contact  ? _contact.name  : @"Unnamed";
    self.phoneTextField.text = _contact ? _contact.phone : @"xxxxxxxxxxx";
}

@end

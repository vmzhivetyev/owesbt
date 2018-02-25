//
//  VMZOwesTableViewCell.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Masonry.h>
#import <Contacts/Contacts.h>

#import "VMZOwesTableViewCell.h"
#import "VMZOweData+CoreDataClass.h"
#import "VMZContact.h"

@interface VMZOwesTableViewCell ()

@property (nonatomic, weak, readonly) UILabel *sumLabel;
@property (nonatomic, weak, readonly) UILabel *mainLabel;
@property (nonatomic, weak, readonly) UILabel *secondLabel;
@property (nonatomic, weak, readonly) UILabel *emptyLabel;
@property (nonatomic, weak) VMZOweData *owe;

@end

@implementation VMZOwesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        UILabel *sumLabel = [UILabel new];
        _sumLabel = sumLabel;
        _sumLabel.text = @"Sum";
        _sumLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_sumLabel];
        
        UILabel *mainLabel = [UILabel new];
        _mainLabel = mainLabel;
        _mainLabel.text = @"Main";
        [self.contentView addSubview:_mainLabel];
        
        UILabel *secondLabel = [UILabel new];
        _secondLabel = secondLabel;
        _secondLabel.text = @"Second";
        _secondLabel.textColor = [UIColor grayColor];
        _secondLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_secondLabel];
        
        UILabel *emptyLabel = [UILabel new];
        _emptyLabel = emptyLabel;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.textColor = [UIColor grayColor];
        _emptyLabel.text = @"Empty";
        [self.contentView addSubview:_emptyLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self.sumLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 20, 10, 10));
        make.width.equalTo(@50);
    }];
    [self.mainLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sumLabel.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.top.equalTo(self.sumLabel);
    }];
    [self.secondLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-10);
       
        if (self.secondLabel.text.length == 0)
        {
            make.top.equalTo(self.mainLabel.mas_bottom);
        }
        else
        {
            make.top.equalTo(self.mainLabel.mas_bottom).offset(5);
        }
        
        if (self.owe)
        {
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
        }
    }];
    [self.emptyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40).priorityHigh();
        make.left.top.right.equalTo(self.contentView);
        
        if (!self.owe)
        {
            make.bottom.equalTo(self.contentView.mas_bottom);
        }
    }];
    
    [super updateConstraints];
}

- (void)loadOweData:(VMZOweData *)owe
{
    if (owe)
    {
        self.sumLabel.text = owe.sum;
        self.mainLabel.text = owe.partnerName;
        self.secondLabel.text = owe.descr;
        
        if (owe.statusType == VMZOweStatusActive)
        {
            self.accessoryType = [owe selfIsCreditor] ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (owe.statusType == VMZOweStatusRequested)
        {
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.mainLabel.hidden = !owe;
    self.secondLabel.hidden = !owe;
    self.sumLabel.hidden = !owe;
    self.emptyLabel.hidden = !!owe;
    self.owe = owe;
    
    [self setNeedsUpdateConstraints];
}

@end

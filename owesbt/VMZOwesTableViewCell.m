//
//  VMZOwesTableViewCell.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Masonry.h>

#import "VMZOwesTableViewCell.h"
#import "VMZOweData+CoreDataClass.h"

@interface VMZOwesTableViewCell ()

@property (nonatomic, weak, readonly) UILabel *mainLabel;
@property (nonatomic, weak, readonly) UILabel *secondLabel;
@property (nonatomic, weak, readonly) UILabel *emptyLabel;
@property (nonatomic, weak) VMZOweData *owe;

@end

@implementation VMZOwesTableViewCell

+ (CGFloat)heightForEmpty:(BOOL)emptyCell
{
    return emptyCell ? 37 : 58;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        UILabel *mainLabel = [UILabel new];
        _mainLabel = mainLabel;
        _mainLabel.textColor = [UIColor blackColor];
        _mainLabel.backgroundColor = [UIColor cyanColor];
        _mainLabel.text = @"Text";
        [self.contentView addSubview:_mainLabel];
        
        UILabel *secondLabel = [UILabel new];
        _secondLabel = secondLabel;
        _secondLabel.textColor = [UIColor blackColor];
        _secondLabel.backgroundColor = [UIColor cyanColor];
        _secondLabel.text = @"Text";
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
    [self.mainLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 20, 10, 10));
    }];
    [self.secondLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.mainLabel);
        make.top.equalTo(self.mainLabel.mas_bottom).offset(5);
        
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
        self.mainLabel.text = [owe selfIsCreditor] ? owe.debtor : owe.creditor;
        self.secondLabel.text = [NSString stringWithFormat:@"%@ %@ %@", owe.sum, owe.descr, owe.created];
        
        if ([owe.status isEqualToString: @"active"])
        {
            self.accessoryType = [owe selfIsCreditor] ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([owe.status isEqualToString: @"requested"])
        {
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            //self.accessoryType = ![owe selfIsCreditor] ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.mainLabel.hidden = !owe;
    self.secondLabel.hidden = !owe;
    self.emptyLabel.hidden = !!owe;
    self.owe = owe;
    
    [self setNeedsUpdateConstraints];
}

@end

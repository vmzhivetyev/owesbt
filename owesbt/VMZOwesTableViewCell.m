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

@property (nonatomic, strong, readonly) UILabel *mainLabel;
@property (nonatomic, strong, readonly) UILabel *secondLabel;
@property (nonatomic, strong, readonly) UILabel *emptyLabel;

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
        _mainLabel = [[UILabel alloc] init];
        _mainLabel.textColor = [UIColor blackColor];
        _mainLabel.backgroundColor = [UIColor cyanColor];
        _mainLabel.text = @"Text";
        [self.contentView addSubview:_mainLabel];
        
        _secondLabel = [[UILabel alloc] init];
        _secondLabel.textColor = [UIColor blackColor];
        _secondLabel.backgroundColor = [UIColor cyanColor];
        _secondLabel.text = @"Text";
        _secondLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_secondLabel];
        
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.textColor = [UIColor grayColor];
        _emptyLabel.backgroundColor = [UIColor lightGrayColor];
        _emptyLabel.text = @"Empty";
        [self.contentView addSubview:_emptyLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [_mainLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
        make.height.equalTo(@21);
    }];
    [_secondLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_mainLabel);
        make.top.equalTo(_mainLabel.mas_bottom).offset(5);
        make.height.equalTo(@15);
    }];
    [_emptyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
        make.height.equalTo(@21);
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
    
    [_secondLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (owe)
        {
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
        }
    }];
    [_emptyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (!owe)
        {
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
        }
    }];
}

@end

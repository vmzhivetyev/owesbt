//
//  VMZOwesTableViewCell.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

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
        
        _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 21+8, CGRectGetWidth(self.frame) - 16, 21)];
        _secondLabel.textColor = [UIColor blackColor];
        _secondLabel.backgroundColor = [UIColor cyanColor];
        _secondLabel.text = @"Text";
        _secondLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_secondLabel];
        
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, CGRectGetWidth(self.frame) - 16, 21)];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.textColor = [UIColor grayColor];
        _emptyLabel.text = @"Empty";
        [self.contentView addSubview:_emptyLabel];
    }
    return self;
}

- (void)loadOweData:(VMZOweData *)owe
{
    if (owe)
    {
        self.mainLabel.text = [owe.creditor isEqualToString:@"self"] ? owe.debtor : owe.creditor;
        self.secondLabel.text = [NSString stringWithFormat:@"%@ %@ %@", owe.sum, owe.descr, owe.created];
        
        self.accessoryType = [owe.creditor isEqualToString:@"self"] ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.mainLabel.hidden = !owe;
    self.secondLabel.hidden = !owe;
    self.emptyLabel.hidden = !!owe;
}

@end

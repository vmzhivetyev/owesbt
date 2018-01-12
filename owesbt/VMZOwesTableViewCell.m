//
//  VMZOwesTableViewCell.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOwesTableViewCell.h"

@implementation VMZOwesTableViewCell

+ (CGFloat)height
{
    return 58;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, CGRectGetWidth(self.frame) - 16, 21)];
        _mainLabel.textColor = [UIColor blackColor];
        _mainLabel.backgroundColor = [UIColor cyanColor];
        _mainLabel.text = @"Text";
        [self addSubview:_mainLabel];
        
        _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 21+8, CGRectGetWidth(self.frame) - 16, 21)];
        _secondLabel.textColor = [UIColor blackColor];
        _secondLabel.backgroundColor = [UIColor cyanColor];
        _secondLabel.text = @"Text";
        _secondLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_secondLabel];
    }
    return self;
}

@end

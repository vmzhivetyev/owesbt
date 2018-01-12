//
//  VMZOwesTableViewCell.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 12.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMZOwesTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *mainLabel;
@property (nonatomic, strong, readonly) UILabel *secondLabel;

+ (CGFloat)height;

@end

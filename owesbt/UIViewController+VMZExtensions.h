//
//  UIView+Extension.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VMZExtensions)

- (CGFloat)statusBarHeight;
- (void)showMessagePrompt:(NSString *)message;

@end
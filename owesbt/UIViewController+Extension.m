//
//  UIView+Extension.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (VMZExtension)

- (CGFloat)statusBarHeight
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGRect statusBarWindowRect = [self.view.window convertRect:statusBarFrame fromWindow: nil];
    CGRect statusBarViewRect = [self.view convertRect:statusBarWindowRect fromView: nil];
    return CGRectGetMaxY(statusBarViewRect);
}

- (void)showMessagePrompt:(NSString *)message
{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:nil
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction =
    [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

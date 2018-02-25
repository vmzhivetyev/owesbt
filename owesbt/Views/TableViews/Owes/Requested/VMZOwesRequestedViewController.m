//
//  VMZOwesRequestedViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 28.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOwesRequestedViewController.h"

#import "NSString+Formatting.h"
#import "VMZOweController.h"

@interface VMZOwesRequestedViewController ()

@end

@implementation VMZOwesRequestedViewController

- (instancetype)init
{
    self = [super initWithStatus:VMZOweStatusRequested tabBarImage:@"pending1"];
    if (self)
    {
        
    }
    return self;
}

- (NSString *)messageForActionsAlertForOwe:(VMZOweData *)owe
{
    return [owe selfIsCreditor] ? @"Отменить запрос?" : @"Подтвердить Вашу задолжность?";
}

- (NSArray *)actionsForOwe:(VMZOweData *)owe atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *actions = [NSMutableArray new];
    
    if (![owe selfIsCreditor])
    {
        //'confirm request'
        [actions addObject:
         [UIAlertAction actionWithTitle:@"Подтвердить долг" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[VMZOweController sharedInstance] confirmOwe:owe];
            [self removeOweAtIndexPath:indexPath];
        }]];
    }
    
    //'cancel request'
    [actions addObject:
     [UIAlertAction actionWithTitle:@"Отменить долг" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[VMZOweController sharedInstance] cancelOwe:owe];
        [self removeOweAtIndexPath:indexPath];
    }]];
    
    //'cancel'
    [actions addObject: [self cancelActionForOwe:owe]];
    
    return actions;
}

@end

//
//  VMZOwesActiveViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 28.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZOwesActiveViewController.h"

#import "VMZOweData+CoreDataClass.h"
#import "VMZOweController.h"

@interface VMZOwesActiveViewController ()

@end

@implementation VMZOwesActiveViewController

- (instancetype)init
{
    self = [super initWithStatus:VMZOweStatusActive tabBarImage:@"list1"];
    if (self)
    {
        
    }
    return self;
}

- (NSString *)messageForActionsAlertForOwe:(VMZOweData *)owe
{
    return @"Вы действительно вернули себе этот долг и хотите пометить его закрытым?";
}

- (NSArray *)actionsForOwe:(VMZOweData *)owe atIndexPath:(NSIndexPath *)indexPath
{
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Закрыть долг" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [[VMZOweController sharedInstance] closeOwe:owe];
        [self removeOweAtIndexPath:indexPath];
    }];
    return @[ closeAction, [self cancelActionForOwe:owe] ];
}

@end

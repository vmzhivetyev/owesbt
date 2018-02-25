//
//  VMZOwesTableViewController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMZOweData+CoreDataClass.h"


@protocol VMZOweDelegate;


@interface VMZOwesTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, VMZOweDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong, readonly) NSString* owesStatus;

- (instancetype)initWithStatus:(VMZOweStatus)status tabBarImage:(NSString*)imageName NS_DESIGNATED_INITIALIZER;

- (VMZOweData *)oweAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeOweAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)titleForActionsAlertForOwe:(VMZOweData *)owe;
- (NSString *)messageForActionsAlertForOwe:(VMZOweData *)owe;
- (NSArray *)actionsForOwe:(VMZOweData*)owe atIndexPath:(NSIndexPath *)indexPath;
- (UIAlertAction *)cancelActionForOwe:(VMZOweData *)owe;

@end

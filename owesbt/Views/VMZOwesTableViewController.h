//
//  VMZOwesTableViewController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol VMZOweDelegate;


@interface VMZOwesTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, VMZOweDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong, readonly) NSString* owesStatus;

- (instancetype)initWithStatus:(NSString*)status tabBarImage:(NSString*)imageName;

@end

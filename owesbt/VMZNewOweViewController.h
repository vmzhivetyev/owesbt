//
//  VMZNewOweViewController.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 16.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol VMZOweDelegate;


@interface VMZNewOweViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, VMZOweDelegate>

@end

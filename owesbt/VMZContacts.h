//
//  VMZContacts.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CNContactPickerViewController;


@interface VMZContacts : NSObject

+ (NSArray *)fetchContacts;
+ (CNContact *)contactWithPhoneNumber:(NSString *)phoneNumber phoneNumberRef:(CNPhoneNumber **)ref;

+ (CNContactPickerViewController *)contactPickerViewForPhoneNumber;

@end

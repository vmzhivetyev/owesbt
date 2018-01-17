//
//  VMZContacts.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMZContacts : NSObject

+ (NSArray *)fetchContactsUncached;
+ (NSArray *)fetchContacts;
+ (CNContact *)contactWithPhoneNumber:(NSString *)phoneNumber;

@end

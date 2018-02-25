//
//  VMZContacts.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CNContact+FullName.h"


@class CNContactPickerViewController;
@class CNContact;
@class CNPhoneNumber;


@interface VMZContact : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy, readonly) NSString *uid;

- (BOOL)isEqualToContact:(VMZContact *)other;
- (instancetype)initWithName:(NSString *)name
                       phone:(NSString *)phone
                         uid:(NSString *)uid;
- (instancetype)initWithPhone:(CNPhoneNumber *)phone
                    cnContact:(CNContact *)contact;

// class methods

+ (NSArray *)fetchContacts;
+ (CNContact *)contactWithPhoneNumber:(NSString *)phoneNumber phoneNumberRef:(CNPhoneNumber **)ref;

+ (CNContactPickerViewController *)contactPickerViewForPhoneNumber;

@end

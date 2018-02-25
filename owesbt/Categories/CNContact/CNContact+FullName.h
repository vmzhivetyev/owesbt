//
//  CNContact+FullName.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 13.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Contacts/Contacts.h>

@interface CNContact (FullName)

@property (nonatomic, copy, readonly) NSString *fullNameValue;

@end

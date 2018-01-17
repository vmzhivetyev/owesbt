//
//  VMZContacts.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Contacts/Contacts.h>

#import "VMZContacts.h"
#import "NSString+VMZExtensions.h"


@implementation VMZContacts

+ (NSArray *)fetchContactsUncached
{
    CNContactStore *store = [CNContactStore new];
    
    NSArray *keysToFetch = @[ [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey ];
    
    NSError *error;
    NSArray *allContainers = [store containersMatchingPredicate:nil error:&error];
    
    NSMutableArray *results = [NSMutableArray new];
    
    for (CNContainer *container in allContainers)
    {
        NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
        NSArray *contactsInContainer = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:&error];
        [results addObjectsFromArray:contactsInContainer];
    }
    
    return [NSArray arrayWithArray:results];
}

+ (NSArray *)fetchContacts
{
    static NSArray<CNContact*>* contacts = nil;
    if (contacts)
    {
        return contacts;
    }
    contacts = [self fetchContactsUncached];
    return contacts;
}

+ (CNContact *)contactWithPhoneNumber:(NSString *)phoneNumber
{
    NSString *phoneNumberToCompareAgainst = [phoneNumber phoneNumberDigits];
    
    for (CNContact *contact in [self fetchContactsUncached])
    {
        for (CNLabeledValue<CNPhoneNumber*>* phoneNumber in contact.phoneNumbers)
        {
            if ([phoneNumber.value.stringValue.phoneNumberDigits isEqualToString:phoneNumberToCompareAgainst])
            {
                return contact;
            }
        }
    }
    
    return nil;
}

@end

//
//  VMZContacts.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

#import "VMZContacts.h"
#import "NSString+VMZExtensions.h"


@implementation VMZContacts

+ (NSArray *)fetchContacts
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

+ (CNContact *)contactWithPhoneNumber:(NSString *)phoneNumber phoneNumberRef:(CNPhoneNumber **)ref
{
    NSString *phoneNumberToCompareAgainst = [phoneNumber phoneNumberDigits];
    
    for (CNContact *contact in [self fetchContacts])
    {
        for (CNLabeledValue<CNPhoneNumber*>* phoneNumber in contact.phoneNumbers)
        {
            if ([phoneNumber.value.stringValue.phoneNumberDigits isEqualToString:phoneNumberToCompareAgainst])
            {
                if(ref)
                {
                    *ref = phoneNumber.value;
                }
                return contact;
            }
        }
    }
    
    return nil;
}

+ (CNContactPickerViewController *)contactPickerViewForPhoneNumber
{
    CNContactPickerViewController *contactPicker = [CNContactPickerViewController new];
    
    contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
    contactPicker.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"phoneNumbers.@count > 0"];
    contactPicker.predicateForSelectionOfProperty = [NSPredicate predicateWithFormat:@"key=='phoneNumbers'"];
    
    return contactPicker;
}

@end

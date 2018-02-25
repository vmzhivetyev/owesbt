//
//  VMZContacts.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 17.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

#import "VMZContact.h"
#import "NSString+Formatting.h"


@implementation VMZContact


- (BOOL)isEqualToContact:(VMZContact *)other
{
    if (!self.uid)
    {
        return YES;
    }
    
    return [self.uid isEqualToString:other.uid];
}


#pragma mark - Lifecycle

-   (instancetype)initWithName:(NSString *)name phone:(NSString *)phone uid:(NSString *)uid
{
    self = [self init];
    if (self)
    {
        _name = name;
        _phone = phone;
        _uid = uid;
    }
    return self;
}

- (instancetype)initWithPhone:(CNPhoneNumber *)phone
                    cnContact:(CNContact *)contact
{
    self = [self initWithName:contact.fullNameValue phone:phone.stringValue uid:contact.identifier];
    return self;
}


#pragma mark - Class Methods

+ (NSArray *)fetchContacts
{
    CNContactStore *store = [CNContactStore new];
    
    NSArray *keysToFetch = @[ [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey ];
    
    NSError *error;
    NSArray *allContainers = [store containersMatchingPredicate:nil error:&error];
    if (error)
    {
        return nil;
    }
    
    NSMutableArray *results = [NSMutableArray new];
    
    for (CNContainer *container in allContainers)
    {
        NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
        NSArray *contactsInContainer = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:&error];
        [results addObjectsFromArray:contactsInContainer];
    }
    
    return [NSArray arrayWithArray:results];
}

+ (CNPhoneNumber *)numberFromContact:(CNContact *)contact equalsToString:(NSString *)phoneString
{
    for (CNLabeledValue<CNPhoneNumber*>* phoneNumber in contact.phoneNumbers)
    {
        if ([[phoneNumber.value.stringValue ft_phoneNumberDigits] isEqualToString:phoneString])
        {
            return phoneNumber.value;
        }
    }
    return nil;
}

+ (CNContact *)contactWithPhoneNumber:(NSString *)phoneNumber phoneNumberRef:(CNPhoneNumber **)ref
{
    NSString *phoneNumberToCompareAgainst = [phoneNumber ft_phoneNumberDigits];
    
    for (CNContact *contact in [self fetchContacts])
    {
        CNPhoneNumber *number = [self numberFromContact:contact equalsToString:phoneNumberToCompareAgainst];
        if (number)
        {
            if(ref)
            {
                *ref = number;
            }
            return contact;
        }
    }
    
    if(ref)
    {
        *ref = nil;
    }
    return nil;
}

+ (CNContactPickerViewController *)contactPickerViewForPhoneNumber
{
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    
    contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
    contactPicker.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"phoneNumbers.@count > 0"];
    contactPicker.predicateForSelectionOfProperty = [NSPredicate predicateWithFormat:@"key=='phoneNumbers'"];
    
    return contactPicker;
}

@end

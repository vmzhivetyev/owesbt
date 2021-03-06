//
//  VMZOweData+CoreDataClass.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import <Contacts/Contacts.h>

#import "VMZOweData+CoreDataClass.h"
#import "VMZContact.h"


@implementation VMZOweData

+ (NSString *)stringFromStatus:(VMZOweStatus)status
{
    return @[@"undefined", @"active", @"requested", @"closed"][status];
}

+ (VMZOweStatus)statusFromName:(NSString *)name
{
    if([@"active" isEqualToString:name])
    {
        return VMZOweStatusActive;
    }
    if([@"requested" isEqualToString:name])
    {
        return VMZOweStatusRequested;
    }
    if([@"closed" isEqualToString:name])
    {
        return VMZOweStatusClosed;
    }
    return VMZOweStatusUndefined;
}

- (NSString *)partner
{
    return [self selfIsCreditor] ? self.debtor : self.creditor;
}

- (VMZOweStatus)statusType
{
    return [VMZOweData statusFromName:self.status];
}

- (void)setStatusType:(VMZOweStatus)status
{
    self.status = [VMZOweData stringFromStatus:status];
}

- (void)loadFromDictionary:(NSDictionary * _Nonnull)dict
{
    if ([[dict objectForKey:@"created"] integerValue] == 0)
    {
        self.created = nil;
    }
    else
    {
        self.created = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"created"] integerValue]/1000.0];
    }
    if ([dict[@"closed"] integerValue] == 0)
    {
        self.closed = nil;
    }
    else
    {
        self.closed = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"closed"] integerValue]/1000.0];
    }
    self.creditor = dict[@"to"];
    self.debtor = dict[@"who"];
    self.descr = dict[@"descr"];
    self.status = dict[@"status"];
    self.uid = dict[@"id"];
    self.sum = dict[@"sum"];
    [self updatePartnerName];
}

- (void)updatePartnerName
{
    self.partnerName = [self findPartnerName];
}

- (NSString *)findPartnerName
{
    CNPhoneNumber *phone = nil;
    CNContact* partnerContact = [VMZContact contactWithPhoneNumber:self.partner phoneNumberRef:&phone];
    return partnerContact ? partnerContact.fn_fullName : self.partner;
}

- (BOOL)selfIsCreditor
{
    return [self.creditor isEqualToString:@"self"];
}

-(void)log
{
//    @property (nullable, nonatomic, copy) NSDate *closed;
//    @property (nullable, nonatomic, copy) NSDate *created;
//    @property (nullable, nonatomic, copy) NSString *creditor;
//    @property (nullable, nonatomic, copy) NSString *debtor;
//    @property (nullable, nonatomic, copy) NSString *descr;
//    @property (nullable, nonatomic, copy) NSString *status;
//    @property (nullable, nonatomic, copy) NSString *sum;
//    @property (nullable, nonatomic, copy) NSString *uid;
//    @property (nullable, nonatomic, copy) NSString *partnerName;
    NSLog(@"{ \n\tuid: %@\n\tdescr: %@\n\tstatus: %@\n\tcreditor: %@\n\tdebtor: %@\n }",
          self.uid, self.descr, self.status, self.creditor, self.debtor);
}

@end

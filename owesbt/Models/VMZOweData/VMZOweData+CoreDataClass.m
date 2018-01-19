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
#import "VMZContacts.h"


@implementation VMZOweData

+ (NSString *)stringFromStatus:(VMZOweStatus)status
{
    return @[@"active", @"requested", @"closed"][status];
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
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"The enum VMZOweStatus has no value %@", name]
                                 userInfo:nil];
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

+ (instancetype)newOweInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Owe" inManagedObjectContext:moc];
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
    if ([[dict objectForKey:@"closed"] integerValue] == 0)
    {
        self.closed = nil;
    }
    else
    {
        self.closed = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"closed"] integerValue]/1000.0];
    }
    self.creditor = [dict objectForKey:@"to"];
    self.debtor = [dict objectForKey:@"who"];
    self.descr = [dict objectForKey:@"descr"];
    self.status = [dict objectForKey:@"status"];
    self.uid = [dict objectForKey:@"id"];
    self.sum = [dict objectForKey:@"sum"];
}

- (BOOL)selfIsCreditor
{
    return [self.creditor isEqualToString:@"self"];
}

@end

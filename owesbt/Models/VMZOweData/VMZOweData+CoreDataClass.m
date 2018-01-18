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

+ (instancetype)newOweInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Owe" inManagedObjectContext:moc];
}

- (void)loadFromDictionary:(NSDictionary * _Nonnull)dict
{
    self.created = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"created"] integerValue]/1000.0];
    self.closed = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"closed"] integerValue]/1000.0];
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

- (NSString *)partner
{
    return [self selfIsCreditor] ? self.debtor : self.creditor;
}

@end

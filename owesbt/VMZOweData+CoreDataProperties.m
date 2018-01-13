//
//  VMZOweData+CoreDataProperties.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "VMZOweData+CoreDataProperties.h"


@implementation VMZOweData (CoreDataProperties)

+ (NSFetchRequest<VMZOweData *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Owe"];
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

@dynamic closed;
@dynamic created;
@dynamic creditor;
@dynamic debtor;
@dynamic descr;
@dynamic status;
@dynamic uid;
@dynamic sum;

@end

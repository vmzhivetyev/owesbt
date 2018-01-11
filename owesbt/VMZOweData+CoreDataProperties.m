//
//  VMZOweData+CoreDataProperties.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 11.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//
//

#import "VMZOweData+CoreDataProperties.h"

@implementation VMZOweData (CoreDataProperties)

+ (NSFetchRequest<VMZOweData *> *)fetchRequest
{
	return [[NSFetchRequest alloc] initWithEntityName:@"Owe"];
}

- (void)loadFromDictionary:(NSDictionary * _Nonnull)dict
{
    //self.created = [dict objectForKey:@"created"];
    //self.closed = [dict objectForKey:@"closed"];
    self.creditor = [dict objectForKey:@"to"];
    self.debtor = [dict objectForKey:@"who"];
    self.descr = [dict objectForKey:@"descr"];
    self.status = [dict objectForKey:@"status"];
    self.uid = [dict objectForKey:@"id"];
}

@dynamic closed;
@dynamic created;
@dynamic creditor;
@dynamic debtor;
@dynamic descr;
@dynamic status;
@dynamic uid;

@end

//
//  VMZContactsTests.m
//  owesbtTests
//
//  Created by Вячеслав Живетьев on 25.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import <Contacts/Contacts.h>

#import "VMZContacts.h"


@interface VMZContacts (Tests)

+ (CNPhoneNumber *)numberFromContact:(CNContact *)contact equalsToString:(NSString *)phoneString;

@end


@interface VMZContactsTests : XCTestCase

@property (nonatomic, strong) id contacts;

@end


@implementation VMZContactsTests

- (void)setUp
{
    [super setUp];
    self.contacts = OCMPartialMock([VMZContacts class]);
}

- (void)tearDown
{
    self.contacts = nil;
    [super tearDown];
}

- (void)testFetchWithoutErrors
{
    expect([self.contacts fetchContacts]).toNot.equal(nil);
}

- (void)test
{
    OCMExpect([self.contacts fetchContacts]).andReturn(@[[CNContact new]]);
    
    CNPhoneNumber *phoneNumber = [[CNPhoneNumber alloc] initWithStringValue:@""];
    CNContact *contact = [self.contacts contactWithPhoneNumber:@"111" phoneNumberRef:&phoneNumber];
    
    expect(contact).to.equal(nil);
    expect(phoneNumber).to.equal(nil);
    OCMVerify([self.contacts fetchContacts]);
    OCMVerify([self.contacts numberFromContact:[OCMArg any] equalsToString:[OCMArg any]]);
}

@end

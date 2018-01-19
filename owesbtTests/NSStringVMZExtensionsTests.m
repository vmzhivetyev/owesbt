//
//  NSString+VMZExtensionsTests.m
//  owesbtTests
//
//  Created by Вячеслав Живетьев on 21.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import "NSString+VMZExtensions.h"

@interface NSStringVMZExtensionsTests : XCTestCase

@end

@implementation NSStringVMZExtensionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testVMZUppercaseFirstLetter {
    expect([@"" VMZUppercaseFirstLetter]).equal(@"");
    expect([@"s" VMZUppercaseFirstLetter]).equal(@"S");
    expect([@"с" VMZUppercaseFirstLetter]).equal(@"С");
    expect([@"string" VMZUppercaseFirstLetter]).equal(@"String");
    expect([@"строка" VMZUppercaseFirstLetter]).equal(@"Строка");
    expect([@"String" VMZUppercaseFirstLetter]).equal(@"String");
    expect([@"100" VMZUppercaseFirstLetter]).equal(@"100");
}

- (void)testVMZPhoneNumberDigits {
    expect([@"" VMZPhoneNumberDigits]).equal(@"");
    expect([@"+7+7+7" VMZPhoneNumberDigits]).equal(@"8+7+7");
    expect([@"8abcdefr1ghiklmno2pqrstxyz()a-a=a %$#3" VMZPhoneNumberDigits]).equal(@"8123");
    expect([@"1234567890" VMZPhoneNumberDigits]).equal(@"1234567890");
}

@end

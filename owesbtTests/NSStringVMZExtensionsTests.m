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

#import "NSString+Formatting.h"

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
    expect([@"" ft_uppercaseFirstLetter]).equal(@"");
    expect([@"s" ft_uppercaseFirstLetter]).equal(@"S");
    expect([@"с" ft_uppercaseFirstLetter]).equal(@"С");
    expect([@"string" ft_uppercaseFirstLetter]).equal(@"String");
    expect([@"строка" ft_uppercaseFirstLetter]).equal(@"Строка");
    expect([@"String" ft_uppercaseFirstLetter]).equal(@"String");
    expect([@"100" ft_uppercaseFirstLetter]).equal(@"100");
}

- (void)testVMZPhoneNumberDigits {
    expect([@"" ft_phoneNumberDigits]).equal(@"");
    expect([@"+7+7+7" ft_phoneNumberDigits]).equal(@"8+7+7");
    expect([@"8abcdefr1ghiklmno2pqrstxyz()a-a=a %$#3" ft_phoneNumberDigits]).equal(@"8123");
    expect([@"1234567890" ft_phoneNumberDigits]).equal(@"1234567890");
}

@end

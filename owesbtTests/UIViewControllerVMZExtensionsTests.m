//
//  UIViewControllerVMZExtensionsTests.m
//  owesbtTests
//
//  Created by Вячеслав Живетьев on 21.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import "UIViewController+VMZExtensions.h"

@interface UIViewControllerVMZExtensionsTests : XCTestCase

@end

@implementation UIViewControllerVMZExtensionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testVMZShowMessagePrompt {
    id mock = OCMPartialMock([UIViewController new]);
    [mock VMZShowMessagePrompt:@""];
    OCMVerify([mock presentViewController:[OCMArg any] animated:[OCMArg any] completion:[OCMArg any]]);
}

@end

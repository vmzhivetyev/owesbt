//
//  VMZMainViewControllerTests.m
//  owesbtTests
//
//  Created by Вячеслав Живетьев on 23.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import <Firebase.h>

#import "UIViewController+VMZExtensions.h"
#import "VMZMainViewController.h"
#import "VMZOweController.h"
#import "VMZNavigationController.h"


@interface VMZMainViewController (Tests)

@property (nonatomic, weak) id googleSignInButton;
@property (nonatomic, weak) id spinnerImageView;

- (void)presentChangePhoneView;
- (void)signOutButtonClicked:(UIButton*)button;
- (void)createUI;

@end


@interface VMZMainViewControllerTests : XCTestCase

@property (nonatomic, strong) VMZMainViewController *mainViewController;

@end


@implementation VMZMainViewControllerTests

- (void)setUp
{
    [super setUp];
    _mainViewController = OCMPartialMock([VMZMainViewController new]);
}

- (void)tearDown
{
    _mainViewController = nil;
    [super tearDown];
}

- (void)testAuthDidSignInForNilUser
{
    OCMReject([_mainViewController VMZShowMessagePrompt:[OCMArg any]]);
    [_mainViewController VMZAuthDidSignInForUser:nil withError:nil];
}

- (void)testAuthDidSignInForNilUserWithError
{
    id error = OCMClassMock([NSError class]);
    [_mainViewController VMZAuthDidSignInForUser:nil withError:error];
    OCMVerify([_mainViewController VMZShowMessagePrompt:[OCMArg any]]);
}

- (void)testAuthDidSignInForNotNilUser
{
    FIRUser *user = OCMClassMock([FIRUser class]);
    OCMReject([_mainViewController VMZShowMessagePrompt:[OCMArg any]]);
    [_mainViewController VMZAuthDidSignInForUser:user withError:nil];
}

- (void)testPhoneNumberCheckedSuccessfully
{
    OCMReject([_mainViewController presentChangePhoneView]);
    [_mainViewController VMZPhoneNumberCheckedWithResult:YES];
    OCMVerify([[VMZOweController sharedInstance] removeDelegate:_mainViewController]);
}

- (void)testPhoneNumberCheckedUnsuccessfully
{
    OCMReject([[VMZOweController sharedInstance] removeDelegate:_mainViewController]);
    [_mainViewController VMZPhoneNumberCheckedWithResult:NO];
    OCMVerify([_mainViewController presentChangePhoneView]);
}

- (void)testShowErrorMessage
{
    id string = OCMClassMock([NSString class]);
    OCMStub([_mainViewController VMZShowMessagePrompt:[OCMArg any]]);
    [_mainViewController VMZOweErrorOccured:string];
    OCMVerify([_mainViewController VMZShowMessagePrompt:string]);
}

- (void)signOutWithResult:(BOOL)successfullLogout
{
    id authClass = OCMClassMock([FIRAuth class]);
    OCMStub(ClassMethod([authClass auth])).andReturn(authClass);
    
    OCMStub([_mainViewController VMZShowMessagePrompt:[OCMArg any]]);
    
    id btn = OCMClassMock([UIButton class]);
    
    OCMExpect([authClass signOut:[OCMArg anyObjectRef]]).andReturn(successfullLogout);
    [_mainViewController signOutButtonClicked:btn];
    OCMVerify([_mainViewController VMZShowMessagePrompt:[OCMArg any]]);
}

- (void)testSignOutBad
{
    [self signOutWithResult:NO];
}

- (void)testSignOutGood
{
    [self signOutWithResult:YES];
}

- (void)testPresentChangePhoneView
{
    [_mainViewController presentChangePhoneView];
    OCMVerify([_mainViewController presentViewController:[OCMArg any] animated:[OCMArg any] completion:[OCMArg any]]);
}

- (void)testCreateUI
{
    [_mainViewController createUI];
    expect(_mainViewController.googleSignInButton).toNot.equal(nil);
    expect(_mainViewController.spinnerImageView).toNot.equal(nil);
}

@end

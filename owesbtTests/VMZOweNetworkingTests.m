//
//  VMZOweNetworkingTests.m
//  owesbtTests
//
//  Created by Вячеслав Живетьев on 25.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import "VMZCoreDataManager.h"
#import "VMZOweNetworking.h"


@interface VMZOweNetworking (Tests)

@property (nonatomic, strong, readonly) VMZCoreDataManager* coreDataManager;

@property (nonatomic, strong) NSTimer *requestsTimer;
@property (atomic, assign) BOOL doingActions;

- (NSString*)firebaseUrlForFunction:(NSString *_Nonnull)function withParameters:(NSDictionary *_Nullable)parameters;
- (void)callFirebaseCloudFunction:(NSString *_Nonnull)function
                       parameters:(NSDictionary *_Nullable)parameters
                       completion:(_Nullable FirebaseRequestCallback)completion;
- (void)doOweActions;


@end


@interface VMZOweNetworkingTests : XCTestCase

@property (nonatomic, strong) id coreDataManager;
@property (nonatomic, strong) VMZOweNetworking *networking;

@end


@implementation VMZOweNetworkingTests

- (void)setUp
{
    [super setUp];
    self.coreDataManager = OCMClassMock([VMZCoreDataManager class]);
    self.networking = OCMPartialMock([[VMZOweNetworking alloc] initWithCoreDataManager:self.coreDataManager]);
}

- (void)tearDown
{
    self.coreDataManager = nil;
    self.networking = nil;
    [super tearDown];
}

- (void)testInit
{
    expect(self.networking.coreDataManager).to.equal(self.coreDataManager);
}

- (void)testFirebaseUrlForFunction
{
    expect([self.networking firebaseUrlForFunction:nil withParameters:nil]).to.equal(nil);
    expect([self.networking firebaseUrlForFunction:@"" withParameters:nil]).to.equal(@"");
    expect([self.networking firebaseUrlForFunction:@"1" withParameters:nil]).to.equal(@"1");
    
    expect([self.networking firebaseUrlForFunction:@"0" withParameters:@{@"1":@"2"}]).to.equal(@"0?1=2");
    expect([self.networking firebaseUrlForFunction:@"0" withParameters:@{@"1":@"2", @"2":@"3"}]).to.equal(@"0?1=2&2=3");
    expect([self.networking firebaseUrlForFunction:@"0" withParameters:@{@"1":@"2", @"2":@"" }]).to.equal(@"0?1=2&2=");
    expect([self.networking firebaseUrlForFunction:@"0" withParameters:@{@"1":@"a a"}]).to.equal(@"0?1=a%20a");
}

@end

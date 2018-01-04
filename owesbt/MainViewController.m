//
//  MainViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) GIDSignInButton *googleSignInButton;

@end


@implementation MainViewController


#pragma mark - VMZOweDelegate

- (void)FIRAuthDidSignInForUser:(FIRUser *)user withError:(NSError *)error
{
    self.view.backgroundColor = [UIColor blueColor];
}


#pragma mark - IBActions

- (void)loginButtonClicked:(UIButton*)button
{
    [[GIDSignIn sharedInstance] signIn];
}


#pragma mark - GIDSignInUIDelegate

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    self.view.backgroundColor =  error ? [UIColor redColor] : [UIColor greenColor];
    
    if (error)
    {
        NSLog(@"%@", error.localizedDescription);
    }
}


#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    [VMZOwe sharedInstance].delegate = self;
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    //[[GIDSignIn sharedInstance] signIn];
    
    self.googleSignInButton = [[GIDSignInButton alloc] initWithFrame:CGRectMake(80.0, 210.0, 120.0, 40.0)];
    [self.view addSubview:self.googleSignInButton];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

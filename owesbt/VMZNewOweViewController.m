//
//  VMZNewOweViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 16.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Masonry.h>

#import "VMZNewOweViewController.h"
#import "VMZOwe.h"
#import "UIViewController+Extension.h"

@interface VMZNewOweViewController ()

@property (nonatomic, weak, readonly) UITableView *tableView;

@property (strong, nonatomic) NSArray *cells;

@property (weak, nonatomic) UITextField *nameTextField;

@property (weak, nonatomic) UITextField *phoneTextField;

@property (weak, nonatomic) UITextField *sumTextField;
@property (weak, nonatomic) UITextView *infoTextField;
@property (weak, nonatomic) UISegmentedControl *roleSegmentedControl;

@end

@implementation VMZNewOweViewController


#pragma mark - VMZOweUIDelegate

- (void)VMZOweErrorOccured:(NSString *)error
{
    [self showMessagePrompt:error];
}


#pragma mark - UI

- (void)doneButtonClicked:(UIBarButtonItem *)button
{
    if (self.roleSegmentedControl.selectedSegmentIndex < 0)
    {
        return;
    }
    
    NSString *partner = self.phoneTextField.text;
    BOOL partnerIsDebtor = self.roleSegmentedControl.selectedSegmentIndex == 1;
    NSString *sum = self.sumTextField.text;
    NSString *descr = self.infoTextField.text;
    
    [[VMZOwe sharedInstance] addNewOweFor:partner whichIsDebtor:partnerIsDebtor sum:sum descr:descr];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [textView sizeToFit];
    [textView setNeedsUpdateConstraints];
}


#pragma mark - Lifecycle

- (void)dealloc
{
    [[VMZOwe sharedInstance] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[VMZOwe sharedInstance] addDelegate:self];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView = tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // cells
    
    self.title = @"New Owe";
    
    UITableViewCell *nameCell = [UITableViewCell new];
    nameCell.accessoryType = UITableViewCellAccessoryCheckmark;
    UITextField *nameTextField = [UITextField new];
    self.nameTextField = nameTextField;
    [self.nameTextField setUserInteractionEnabled:NO];
    self.nameTextField.placeholder = @"Person Name";
    [nameCell addSubview:self.nameTextField];
    
    UITableViewCell *phoneCell = [UITableViewCell new];
    UITextField *phoneTextField = [UITextField new];
    self.phoneTextField = phoneTextField;
    self.phoneTextField.text = @"89999696597";
    [self.phoneTextField setUserInteractionEnabled:NO];
    self.phoneTextField.placeholder = @"Phone Number";
    [phoneCell addSubview:self.phoneTextField];
    
    UITableViewCell *roleCell = [UITableViewCell new];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"is creditor", @"is debtor"]];
    self.roleSegmentedControl = segmentedControl;
    [roleCell addSubview:self.roleSegmentedControl];
    
    UITableViewCell *sumCell = [UITableViewCell new];
    UITextField *sumTextField = [UITextField new];
    self.sumTextField = sumTextField;
    self.sumTextField.placeholder = @"Sum";
    [sumCell addSubview:self.sumTextField];
    
    UITableViewCell *infoCell = [UITableViewCell new];
    UITextView *infoTextField = [UITextView new];
    self.infoTextField = infoTextField;
    self.infoTextField.delegate = self;
    self.infoTextField.editable = YES;
    self.infoTextField.scrollEnabled = NO;
    //self.infoTextField.
    [infoCell addSubview:self.infoTextField];
   
    /// UITextField * = [UITextField new]; [sumField setUserInteractionEnabled:NO];
    
    self.cells = @[@[nameCell, phoneCell, roleCell], @[sumCell, infoCell]];
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 20, 10, 10);
    
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(nameCell).insets(insets);
    }];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(phoneCell).insets(insets);
    }];
    [self.roleSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(roleCell).insets(insets);
    }];
    [self.sumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sumCell).insets(insets);
    }];
    [self.infoTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.infoTextField.contentSize.height)).priorityLow();
        make.height.greaterThanOrEqualTo(@24).priorityHigh();
        make.edges.equalTo(infoCell).insets(insets);
    }];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    self.tableView.allowsSelection = NO;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [VMZOwe sharedInstance].currentViewController = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cells count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cells[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cells[indexPath.section][indexPath.row];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  VMZNewOweViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 16.01.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <Masonry.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

#import "VMZNewOweViewController.h"
#import "VMZOwe.h"
#import "VMZOweData+CoreDataClass.h"
#import "UIViewController+VMZExtensions.h"
#import "NSString+VMZExtensions.h"
#import "VMZContacts.h"

@interface VMZNewOweViewController ()

@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, strong) NSArray *cells;

@property (nonatomic, weak) UITextField *nameTextField;
@property (nonatomic, weak) UITextField *phoneTextField;
@property (nonatomic, weak) UISegmentedControl *roleSegmentedControl;

@property (nonatomic, weak) UITextField *sumTextField;
@property (nonatomic, weak) UITextField *descriptionTextField;

@property (nonatomic, assign) BOOL readonlyMode;

@end

@implementation VMZNewOweViewController


#pragma mark - VMZOweUIDelegate

- (void)VMZOweErrorOccured:(NSString *)error
{
    [self showMessagePrompt:error];
}


#pragma mark - CNContactPickerDelegate

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker
{
    
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    CNPhoneNumber *phoneNumber = contactProperty.value;
    if (phoneNumber)
    {
        self.nameTextField.text = [contactProperty.contact valueForKey:@"fullName"];
        self.phoneTextField.text = phoneNumber.stringValue;
        //selectedContactPhoneNumberDigits = phoneNumber.digits
    }
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
    NSString *descr = self.descriptionTextField.text;
    
    [[VMZOwe sharedInstance] addNewOweFor:partner whichIsDebtor:partnerIsDebtor sum:sum descr:descr];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [textView sizeToFit];
    [textView setNeedsUpdateConstraints];
}


#pragma mark - Lifecycle

- (instancetype)initWithOwe:(VMZOweData *)owe
{
    self = [super init];
    if (self)
    {
        // чтобы вызвать viewDidLoad
        [self view];
        
        self.title = [[owe.status uppercaseFirstLetter] stringByAppendingString:@" Owe"];
        
        NSString *partnerPhone = [owe selfIsCreditor] ? owe.debtor : owe.creditor;
        CNPhoneNumber *phone = nil;
        CNContact* partnerContact = [VMZContacts contactWithPhoneNumber:partnerPhone phoneNumberRef:&phone];
        
        self.nameTextField.text = partnerContact ? [partnerContact valueForKey: @"fullName"] : @"Unnamed";
        self.phoneTextField.text = phone ? phone.stringValue : partnerPhone;
        self.sumTextField.text = owe.sum;
        self.descriptionTextField.text = owe.descr;
        self.roleSegmentedControl.selectedSegmentIndex = [owe selfIsCreditor] ? 1 : 0;
        self.roleSegmentedControl.enabled = NO;
        
        // чтобы клавиатура не показывалась при тапе по текстфилду, при этом текст можно выделять
        self.sumTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
        self.descriptionTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.readonlyMode = YES;
        
        self.navigationItem.rightBarButtonItem = nil;
        ((UITableViewCell*)self.nameTextField.superview).accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

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
    nameCell.accessoryType = UITableViewCellAccessoryDetailButton;
    UITextField *nameTextField = [UITextField new];
    self.nameTextField = nameTextField;
    self.nameTextField.placeholder = @"Person Name";
    self.nameTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    self.nameTextField.delegate = self;
    [nameCell addSubview:self.nameTextField];
    
    UITableViewCell *phoneCell = [UITableViewCell new];
    UITextField *phoneTextField = [UITextField new];
    self.phoneTextField = phoneTextField;
    self.phoneTextField.text = @"89999696597";
    self.phoneTextField.placeholder = @"Phone Number";
    self.phoneTextField.delegate = self;
    self.phoneTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    [phoneCell addSubview:self.phoneTextField];
    
    UITableViewCell *roleCell = [UITableViewCell new];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"is creditor", @"is debtor"]];
    self.roleSegmentedControl = segmentedControl;
    [roleCell addSubview:self.roleSegmentedControl];
    
    UITableViewCell *sumCell = [UITableViewCell new];
    UITextField *sumTextField = [UITextField new];
    self.sumTextField = sumTextField;
    self.sumTextField.placeholder = @"Sum";
    self.sumTextField.delegate = self;
    [sumCell addSubview:self.sumTextField];
    
    UITableViewCell *infoCell = [UITableViewCell new];
    UITextField *infoTextField = [UITextField new];
    self.descriptionTextField = infoTextField;
    self.descriptionTextField.placeholder = @"Description";
    self.descriptionTextField.delegate = self;
    [infoCell addSubview:self.descriptionTextField];
   
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
    [self.descriptionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
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


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        CNContactPickerViewController *view = [VMZContacts contactPickerViewForPhoneNumber];
        view.delegate = self;
        [self presentViewController:view animated:YES completion:nil];
    }
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


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.nameTextField || textField == self.phoneTextField)
        return NO;
    
    return !self.readonlyMode;
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

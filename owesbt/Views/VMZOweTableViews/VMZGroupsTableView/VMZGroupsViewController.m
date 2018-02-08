//
//  VMZGroupsViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZGroupsViewController.h"

#import <Masonry.h>
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>

#import "VMZTableViewInputCell.h"
#import "NSArray+IndexPath.h"
#import "VMZContacts.h"

@interface VMZGroupsViewController ()
/*
 
 
 :Name:
 ------------------
 Group name
 ------------------
 
 :Members:
 ------------------
 Name
 Phone
             Remove
 ------------------
 Name
 Phone
             Remove
 ------------------
 Add
 ------------------
 
 :Owes:
 ------------------
 1000 taxi Creditor
 ------------------
                Add
 ------------------
 
 
 */

@property (nonatomic, weak, readonly) UITableView *tableView;

@property (nonatomic, weak, readonly)  NSArray<NSArray<UITableViewCell *> *> *cells;

@property (nonatomic, strong) NSArray<NSArray<VMZTableViewInputCell *> *> *staticSections;
@property (nonatomic, strong) NSMutableArray<NSArray<VMZTableViewInputCell *> *> *membersSections;

@property (nonatomic, weak) NSArray<VMZGroupOweUIs *> *owes;
@property (nonatomic, assign) UIButton *addOweButton;

@property (nonatomic, assign, readonly) NSInteger sectionCountWithoutMembers;

@end

@implementation VMZGroupsViewController

- (NSArray<NSArray<UITableViewCell *> *> *)cells
{
    NSArray *arr = [self.staticSections arrayByAddingObjectsFromArray:self.membersSections];
    if (self.membersSections.count > 0)
    {
        arr = [arr arrayByAddingObject:@[[self cellWithButtonWithText:@"Create Group"
                                                               action:@selector(createButtonTapped)]]];
    }
    return arr;
}

- (void)addMember:(NSString *)name withPhoneNumber:(NSString *)phoneNumber
{
    NSArray<VMZTableViewInputCell *> *section = [self nameAndPhoneCellsForPerson];
    section[0].textField.text = name;
    section[1].textField.text = phoneNumber;
    
    [self.tableView beginUpdates];
    {
        [self.membersSections addObject:section];
        [self.tableView insertSections:[[NSIndexSet alloc] initWithIndex:self.cells.count-2] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (self.membersSections.count == 1)
        {
            [self.tableView insertSections:[[NSIndexSet alloc] initWithIndex:self.cells.count-1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    [self.tableView endUpdates];
}

- (void)removeSectionForIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    {
        [self.membersSections removeObject:self.cells[indexPath.section]];
        [self.tableView deleteSections:[[NSIndexSet alloc] initWithIndex:indexPath.section]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (self.membersSections.count == 0)
        {
            [self.tableView deleteSections:[[NSIndexSet alloc] initWithIndex:self.cells.count+1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    [self.tableView endUpdates];
}

- (void)addButtonTapped
{
    CNContactPickerViewController *view = [VMZContacts contactPickerViewForPhoneNumber];
    view.delegate = self;
    [self presentViewController:view animated:YES completion:nil];
}

- (void)createButtonTapped
{
    
}

- (UITableViewCell *)cellWithButtonWithText:(NSString *)text action:(SEL)selector
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:text forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
        make.height.equalTo(@40);
    }];
    
    return cell;
}

- (UIView *)doneButton
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Create Group" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(20);
        make.left.bottom.right.equalTo(view);
    }];
    
    return view;
}

#pragma mark - Lifecycle

- (void)createUI
{
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView = tableView;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.allowsSelection = NO;
    
    [self.view addSubview:self.tableView];
    
    /*UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
     */
    
    // cells
    
    self.title = @"New Group";
    
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 20, 10, 10);
    VMZTableViewInputCell *groupNameCell = [[VMZTableViewInputCell alloc] initWithPlaceholder:@"Group Name"
                                                                                 keyboardType:UIKeyboardTypeDefault
                                                                              textFieldInsets:insets
                                                                                     readOnly:NO
                                                                            allowedCharacters:nil];
    groupNameCell.sectionHeader = @"Name";
    
    VMZTableViewInputCell *yourselfCell = [self nameCell];
    yourselfCell.textField.text = @"You";
    
    UITableViewCell *addMemberCell = [self cellWithButtonWithText:@"Add Member"
                                                           action:@selector(addButtonTapped)];
    
    self.staticSections = @[ @[groupNameCell], @[yourselfCell, addMemberCell] ].mutableCopy;
    self.membersSections = [NSMutableArray new];
    _sectionCountWithoutMembers = self.cells.count;
}

- (VMZTableViewInputCell *)nameCell
{
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 20, 10, 10);
    
    VMZTableViewInputCell *nameCell =
    [[VMZTableViewInputCell alloc] initWithPlaceholder:@"Person Name"
                                          keyboardType:UIKeyboardTypeDefault
                                       textFieldInsets:insets
                                              readOnly:YES
                                     allowedCharacters:nil];
    return nameCell;
}

- (NSArray<VMZTableViewInputCell *> *)nameAndPhoneCellsForPerson
{
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 20, 10, 10);
    
    VMZTableViewInputCell *nameCell = [self nameCell];
    VMZTableViewInputCell *phoneCell =
    [[VMZTableViewInputCell alloc] initWithPlaceholder:@"Phone Number"
                                          keyboardType:UIKeyboardTypeDefault
                                       textFieldInsets:insets
                                              readOnly:YES
                                     allowedCharacters:nil];
    
    nameCell.accessoryType = UITableViewCellAccessoryDetailButton;
    nameCell.accessoryTappedBlock = ^void(NSIndexPath *indexPath){
        UIAlertController *alert = [[UIAlertController alloc] init];
        [alert addAction:[UIAlertAction actionWithTitle:@"Remove Member" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self removeSectionForIndexPath:indexPath];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    return @[nameCell, phoneCell];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


#pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    CNPhoneNumber *phoneNumber = contactProperty.value;
    if (phoneNumber)
    {
        [self addMember:[contactProperty.contact valueForKey:@"fullName"] withPhoneNumber:phoneNumber.stringValue];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath
{
    VMZTableViewInputCell* cell = [self.cells objectAtIndexPath:indexPath];
    cell.accessoryTappedBlock(indexPath);
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView %zd", self.cells.count);
    return self.cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection %zd", self.cells[section].count);
    return self.cells[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMZTableViewInputCell *cell = [self.cells objectAtIndexPath:indexPath];
    NSLog(@"cell %@", cell);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";// self.cells[section][0].sectionHeader;
}

@end

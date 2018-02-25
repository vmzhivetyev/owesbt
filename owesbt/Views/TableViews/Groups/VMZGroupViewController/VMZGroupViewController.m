//
//  VMZGroupViewController.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 02.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZGroupViewController.h"

#import <Masonry.h>
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>

#import "VMZInputTableViewCell.h"
#import "NSArray+IndexPath.h"
#import "VMZContact.h"
#import "UIViewController+MessagePrompt.h"
#import "UITableView+UpdatesBlock.h"
#import "VMZContactTableViewCell.h"


@interface VMZGroupViewController ()

@property (nonatomic, strong, readonly)  NSArray<NSArray<UITableViewCell *> *> *cells;

@property (nonatomic, strong) NSArray<VMZInputTableViewCell *> *groupNameCells;
@property (nonatomic, strong) NSArray<VMZInputTableViewCell *> *addMemberCells;
@property (nonatomic, strong) NSMutableArray<VMZContactTableViewCell *> *membersCells;
@property (nonatomic, strong) NSMutableArray<UITableViewCell *> *createGroupCells;

//@property (nonatomic, weak) NSArray<VMZGroupOweUIs *> *owes;
@property (nonatomic, weak) UIButton *addOweButton;

@end


@implementation VMZGroupViewController

- (BOOL)isMemberAlreadyAdded:(VMZContact *)member
{
    for(VMZContactTableViewCell *memberCell in self.membersCells)
    {
        if ([memberCell.contact isEqualToContact:member])
        {
            return YES;
        }
    }
    return NO;
}

- (VMZContactTableViewCell *)newCellForContact:(VMZContact *)member
{
    VMZContactTableViewCell *newCell = [[VMZContactTableViewCell alloc] init];
    
    [newCell showContact:member];
    
    return newCell;
}

- (BOOL)showCreateGroupButton
{
    return YES;
}

- (void)showOrHideCreateGroupButton
{
    UITableViewCell *createGroupButtonCell = [self.createGroupCells objectAtIndex:0];
    
    createGroupButtonCell.hidden = self.membersCells.count < 2;
}

- (void)addMember:(VMZContact *)member
{
    VMZContactTableViewCell *newCell = [self newCellForContact:member];
    
    [self.membersCells addObject:newCell];
    
    [self.tableView doUpdates:^(UITableView *tableView) {
        NSIndexPath *indexPathForNewMemberCell =
            [NSIndexPath indexPathForRow:self.membersCells.count-1
                               inSection:[self.cells indexOfObject:self.membersCells]];
        
        [tableView insertRowsAtIndexPaths:@[ indexPathForNewMemberCell ]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self showOrHideCreateGroupButton];
    }];
}

- (void)removeMemberAtIndexPath:(NSIndexPath *)indexPath
{
    VMZContactTableViewCell *cell = (VMZContactTableViewCell *)[self tableView:self.tableView
                                                         cellForRowAtIndexPath:indexPath];
    
    [self.tableView doUpdates:^(UITableView *tableView) {
        [self.membersCells removeObject:cell];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self showOrHideCreateGroupButton];
    }];
}

- (void)addButtonTapped
{
    CNContactPickerViewController *view = [VMZContact contactPickerViewForPhoneNumber];
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
    /*UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView = tableView;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.allowsSelection = NO;
    
    [self.view addSubview:self.tableView];*/
    
    /*UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
     */
    
    // cells
    
    self.title = @"New Group";
    
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 20, 10, 10);
    VMZInputTableViewCell *groupNameCell =
        [[VMZInputTableViewCell alloc] initWithPlaceholder:@"Group Name"
                                              keyboardType:UIKeyboardTypeDefault
                                           textFieldInsets:insets
                                                  readOnly:NO
                                         allowedCharacters:nil];
    groupNameCell.sectionHeader = @"Name";
    
    VMZInputTableViewCell *yourselfCell =
        [[VMZInputTableViewCell alloc] initWithPlaceholder:nil
                                              keyboardType:UIKeyboardTypeDefault
                                           textFieldInsets:insets
                                                  readOnly:NO
                                         allowedCharacters:nil];
    yourselfCell.textField.text = @"You";
    
    UITableViewCell *addMemberCell = [self cellWithButtonWithText:@"Add Member"
                                                           action:@selector(addButtonTapped)];
    
    self.groupNameCells = @[ groupNameCell ];
    self.addMemberCells = @[ addMemberCell ];
    self.membersCells = [NSMutableArray new];
    self.createGroupCells = [NSMutableArray new];
    
    UITableViewCell *buttonCell =
    [self cellWithButtonWithText:@"Create Group"
                          action:@selector(createButtonTapped)];
    
    [self.createGroupCells addObject:buttonCell];
    
    _cells = @[ _groupNameCells, _addMemberCells, _membersCells, _createGroupCells ];
}

- (VMZInputTableViewCell *)nameCell
{
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 20, 10, 10);
    
    VMZInputTableViewCell *nameCell =
    [[VMZInputTableViewCell alloc] initWithPlaceholder:@"Person Name"
                                          keyboardType:UIKeyboardTypeDefault
                                       textFieldInsets:insets
                                              readOnly:YES
                                     allowedCharacters:nil];
    return nameCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    
#define VMZ_DEBUG_LOAD_GROUPS_VIEW
#ifdef VMZ_DEBUG_LOAD_GROUPS_VIEW
    
    [self addMember:[[VMZContact alloc] initWithName:@"You" phone:@"phone" uid:@"self"]];
    [self addMember:[[VMZContact alloc] initWithName:@"Somebody" phone:@"88005553535" uid:@"o"]];
    
#endif
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


#pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    CNPhoneNumber *phoneNumber = contactProperty.value;
    if (!phoneNumber)
    {
        return;
    }
    
    CNContact *contact = contactProperty.contact;
    
    VMZContact *member = [[VMZContact alloc] initWithPhone:phoneNumber cnContact:contact];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([self isMemberAlreadyAdded:member])
        {
            [self mp_showMessagePrompt:@"This member is already added to the group."];
        }
        else
        {
            [self addMember:member];
        }
    }];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath
{
    return;
    VMZInputTableViewCell* cell = [self.cells objectAtIndexPath:indexPath];
    cell.accessoryTappedBlock(indexPath);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    return indexPath.section == [self.cells indexOfObject:self.membersCells]
        && indexPath.row > 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == [self.cells indexOfObject:self.membersCells]
    && indexPath.row > 0 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeMemberAtIndexPath:indexPath];
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
    VMZInputTableViewCell *cell = [self.cells objectAtIndexPath:indexPath];
    NSLog(@"cell %@", cell);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";// self.cells[section][0].sectionHeader;
}

@end

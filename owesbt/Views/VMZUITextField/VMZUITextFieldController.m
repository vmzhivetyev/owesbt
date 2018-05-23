//
//  VMZReadonlyUITextFieldDelegate.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 14.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZUITextFieldController.h"


@interface VMZUITextFieldController ()

@property (nonatomic, weak, readonly) UITextField *textField;
@property (nonatomic, assign) BOOL readonly;
@property (nonatomic, strong) NSCharacterSet *allowedCharacters;

@property (nonatomic, strong, readonly) UIView *editableInputView;

@end


@implementation VMZUITextFieldController


#pragma mark - Propties getters & setters

- (void)setReadonly:(BOOL)readonly
{
#warning setting to YES needs testing
    _readonly = readonly;
    
    if (self.textField)
    {
        self.textField.inputView = _readonly ?
            [[UIView alloc] initWithFrame:CGRectZero] : self.editableInputView;
    }
}


#pragma mark - Lifecycle

- (instancetype)initReadonlyWithTextField:(UITextField *)field
{
    self = [self initWithTextField:field readonly:YES allowedCharacters:nil];
    return self;
}

- (instancetype)initWithTextField:(UITextField *)field allowedCharacters:(NSCharacterSet *)allowedCharacters
{
    self = [self initWithTextField:field readonly:NO allowedCharacters:allowedCharacters];
    return self;
}

- (instancetype)initWithTextField:(UITextField *)textField readonly:(BOOL)readonly allowedCharacters:(NSCharacterSet *)allowedCharacters
{
    self = [self init];
    if (self)
    {
        if (textField)
        {
            textField.delegate = self;
        }
        
        _textField = textField;
        _allowedCharacters = allowedCharacters;
        _editableInputView = _textField.inputView;
        
        [self setReadonly:readonly];
    }
    return self;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.readonly)
    {
        return NO;
    }
    
    if (self.allowedCharacters)
    {
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
        
        return [self.allowedCharacters isSupersetOfSet:characterSetFromTextField];
    }
    return !self.readonly;
}

@end

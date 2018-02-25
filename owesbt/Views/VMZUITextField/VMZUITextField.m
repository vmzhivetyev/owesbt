//
//  VMZUITextField.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 14.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "VMZUITextField.h"
#import "VMZUITextFieldController.h"


@implementation VMZUITextField

- (instancetype)init
{
    self = [self initWithAllowedCharacters:nil];
    if (self) {
        
    }
    return self;
}

- (instancetype)initReadonly
{
    self = [super init];
    if (self)
    {
        self.controller = [[VMZUITextFieldController alloc] initReadonlyWithTextField:self];
    }
    return self;
}

- (instancetype)initWithAllowedCharacters:(NSCharacterSet *)allowedCharacters
{
    self = [super init];
    if (self)
    {
        self.controller = [[VMZUITextFieldController alloc] initWithTextField:self
                                                            allowedCharacters:allowedCharacters];
    }
    return self;
}

@end

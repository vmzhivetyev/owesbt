//
//  VMZUITextField.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 14.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@class VMZUITextFieldController;


@interface VMZUITextField : UITextField

@property (nonatomic, strong) VMZUITextFieldController *controller;

// readonly:NO allowedCharacters:nil
- (instancetype)init;
- (instancetype)initReadonly;
- (instancetype)initWithAllowedCharacters:(NSCharacterSet *)allowedCharacters;

@end

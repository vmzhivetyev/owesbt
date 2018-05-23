//
//  VMZReadonlyUITextFieldDelegate.h
//  owesbt
//
//  Created by Вячеслав Живетьев on 14.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VMZUITextFieldController : NSObject <UITextFieldDelegate>

- (instancetype)initReadonlyWithTextField:(UITextField *)field;

- (instancetype)initWithTextField:(UITextField *)field
                allowedCharacters:(NSCharacterSet *)allowedCharacters;

- (instancetype)initWithTextField:(UITextField *)textField
                         readonly:(BOOL)readonly
                allowedCharacters:(NSCharacterSet *)allowedCharacters;

@end

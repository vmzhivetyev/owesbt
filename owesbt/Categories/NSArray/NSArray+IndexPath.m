//
//  NSArray+IndexPath.m
//  owesbt
//
//  Created by Вячеслав Живетьев on 07.02.2018.
//  Copyright © 2018 Вячеслав Живетьев. All rights reserved.
//

#import "NSArray+IndexPath.h"

#import <UIKit/UIKit.h>


@implementation NSArray (IndexPath)

- (id)ip_objectAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.count <= indexPath.section)
    {
        return nil;
    }
    
    if ([self[indexPath.section] isKindOfClass:[NSArray class]])
    {
        if (self.count <= indexPath.row)
        {
            return nil;
        }
        
        return self[indexPath.section][indexPath.row];
    }
    
    return nil;
}

@end

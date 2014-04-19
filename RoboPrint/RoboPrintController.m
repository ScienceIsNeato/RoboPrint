//
//  RoboPrintController.m
//  RoboPrint
//
//  Created by The Dude on 4/11/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import "RoboPrintController.h"

@implementation RoboPrintController
@synthesize menuName;
@synthesize currentColor;

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    
    // This function is the listener for the pop-up menus.
    NSLog(@"Select index was %d and the menu was %@", itemIndex, menuName);
}


@end



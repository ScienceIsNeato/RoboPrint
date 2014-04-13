//
//  RoboPrintController.m
//  RoboPrint
//
//  Created by The Dude on 4/11/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import "RoboPrintController.h"

@implementation RoboPrintController


- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    
    // ...
    NSLog(@"Select index was %d", itemIndex);
}

@end



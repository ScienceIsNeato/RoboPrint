//
//  RoboPrintController.m
//  RoboPrint
//
//  Created by The Dude on 4/11/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import "RoboPrintController.h"

@implementation RoboPrintController

- (int)getDiceRoll
{
    int roll = (arc4random() % 6) + 1;
    
    return roll;
}

@end

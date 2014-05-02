//
//  RoboPrintController.h
//  RoboPrint
//
//  Created by The Dude on 4/11/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RNGridMenu/RNGridMenu.h>


static const int YELLOW = 0;
static const int RED = 1;
static const int PINK = 2;
static const int BLUE = 3;
static const int BLACK = 4;
static const int GREEN = 5;

@class RoboPrintController;
@interface RoboPrintController : NSObject
{
   
}

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex;
- (float)getRed;
- (float)getGreen;
- (float)getBlue;

@property int currentColor;

@end

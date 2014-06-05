//
//  RoboPrintController.m
//  RoboPrint
//
//  Created by The Dude on 4/11/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import "RoboPrintController.h"

@implementation RoboPrintController
@synthesize currentColor;
@synthesize currentMode;

- (void)setMode:(int) Mode
{
    currentMode = Mode;
    
}

- (float)getRed
{
    switch (self.currentColor)
    {
        case YELLOW:
            return 242.0/255.0;
            break;
        case RED:
            return 255.0/255.0;
            break;
        case PINK:
            return 245.0/255.0;
            break;
        case BLUE:
            return 0.0/255.0;
            break;
        case BLACK:
            return 0.0/255.0;
            break;
        case GREEN:
            return 57.0/255.0;
            break;

        default:
            return 0.0/255.0;
            break;
    }
}
- (float)getGreen
{
    switch (self.currentColor)
    {
        case YELLOW:
            return 235.0/255.0;
            break;
        case RED:
            return 0.0/255.0;
            break;
        case PINK:
            return 0.0/255.0;
            break;
        case BLUE:
            return 0.0/255.0;
            break;
        case BLACK:
            return 0.0/255.0;
            break;
        case GREEN:
            return 255.0/255.0;
            break;
            
        default:
            return 0.0/255.0;
            break;
    }
}
- (float)getBlue
{
    switch (self.currentColor)
    {
        case YELLOW:
            return 12.0/255.0;
            break;
        case RED:
            return 4.0/255.0;
            break;
        case PINK:
            return 254.0/255.0;
            break;
        case BLUE:
            return 255.0/255.0;
            break;
        case BLACK:
            return 0.0/255.0;
            break;
        case GREEN:
            return 9.0/255.0;
            break;
            
        default:
            return 0.0/255.0;
            break;
    }
}


@end



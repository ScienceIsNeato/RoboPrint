//
//  RoboPrintController.h
//  RoboPrint
//
//  Created by The Dude on 4/11/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RNGridMenu/RNGridMenu.h>

@class RoboPrintController;
@interface RoboPrintController : NSObject

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex;


@end

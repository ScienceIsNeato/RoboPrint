//
//  RBLViewController.h
//  SimpleChat
//
//  Created by redbear on 14-4-8.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@class BLEInterface;
@interface BLEInterface : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BLEDelegate>
{
    BLE *bleShield;
    UIActivityIndicatorView *activityIndicator;    
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *text;
@property (nonatomic, strong) NSMutableArray *messageQueue;
@property bool isRobotConnected;
@property (nonatomic, assign) id delegate;  

-(void) initBTInterface;
-(BOOL) connectToRobot;
- (int) sendDrawingCommands;



@end

//
//  ViewController.h
//  RoboPrint
//
//  Created by The Dude on 4/5/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoboPrintController.h"


@interface ViewController : UIViewController{
    
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    IBOutlet UIImageView *tempDrawImage;
    IBOutlet UIImageView *mainImage;
    BOOL mouseSwiped;
    RoboPrintController *model;
}

@property (strong, nonatomic) RoboPrintController *model;
//@property (strong, retain) UIImage *tempDrawImage;
//@property (strong, retain) UIImage *mainImage;
@property (weak, nonatomic) IBOutlet UIButton *yellowButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *pinkButton;
@property (weak, nonatomic) IBOutlet UIButton *blueButton;
@property (weak, nonatomic) IBOutlet UIButton *blackButton;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;

- (IBAction)yellowButtonTouchUpInsideAction:(id)sender;
- (IBAction)redButtonTouchUpInsideAction:(id)sender;
- (IBAction)pinkButtonTouchUpInsideAction:(id)sender;
- (IBAction)blueButtonTouchUpInsideAction:(id)sender;
- (IBAction)blackButtonTouchUpInsideAction:(id)sender;
- (IBAction)greenButtonTouchUpInsideAction:(id)sender;
- (BOOL) selectImage: (UIViewController*) controller
       usingDelegate: (id <UIImagePickerControllerDelegate,
                       UINavigationControllerDelegate>) delegate;

@end

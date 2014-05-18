//
//  ViewController.h
//  RoboPrint
//
//  Created by The Dude on 4/5/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoboPrintController.h"

#define START_OVER 1
#define LOAD_DRAWING 2
#define PENCIL_SKETCH 3

#define SHAPES_MENU 1
#define BACKGROUNDS_MENU 2

#define CIRCLE      0
#define TRIANGLE    1
#define LINE        2
#define SQUARE      3
#define STAR        4
#define PENTAGON    5

#define MINIMUM_SCALE .1
#define MAXIMUM_SCALE 10




@interface ViewController : UIViewController <UIGestureRecognizerDelegate, RNGridMenuDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    IBOutlet UIImageView *canvasImageView;
    IBOutlet UIImageView *backgroundImageView;
    BOOL mouseSwiped;
    RoboPrintController *model;
    int imageStackIndex;
    int imageStackSize;
    int imageStackMaxSize;
    BOOL passedMaxImageIndexOnce;
    BOOL exceededImageStackMaxLength;
    BOOL startOverButonResponse;
    UIImage *mostRecentCanvasState;
    int popupMenuName;
    CGFloat defaultShapeWidth;
    CGFloat shapeWidth;
    CGPoint defaultShapeOrigin;
    CGPoint shapeOrigin;
    CGPoint shapeOriginOffset;
    int currentShape;
    int shapeCreationIndex;
    CGPoint lineP1;
    CGPoint lineP2;
    BOOL lineCanBeMoved;
    float cannySliderValue;
    cv::Mat inputArrayForCanny;
    UIImage *cvEdgeOuptut;
    float cannySliderWidth;
    float cannySliderHeigth;
    float cannyButtonWidth;
    float cannyButtonHeight;
    float cannySliderMinVal;
    float cannySliderMaxVal;
    UISlider *cannySlider;
    UIButton *cannyRotateButton;
    UIButton *cannyDoneButton;
    UILabel *cannySliderLabel;
    
    
}

@property (strong, nonatomic) RoboPrintController *model;
@property (strong, retain) UIImageView *canvasImageView;
@property (strong, retain) UIImageView *backgroundImageView;
@property (strong, retain) UIImage *lastImage;
@property (strong, retain) NSMutableArray *imageStack;
@property (weak, nonatomic) IBOutlet UIButton *yellowButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *pinkButton;
@property (weak, nonatomic) IBOutlet UIButton *blueButton;
@property (weak, nonatomic) IBOutlet UIButton *blackButton;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *imagesButton;
@property (weak, nonatomic) IBOutlet UIButton *pencilButton;
@property (weak, nonatomic) IBOutlet UIButton *backgroundsButton;
@property (weak, nonatomic) IBOutlet UIButton *shapesButton;
@property (weak, nonatomic) IBOutlet UIButton *enlargeButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property int popupMenuName;
@property CGFloat xRescale;
@property CGFloat yRescale;


- (IBAction)yellowButtonTouchUpInsideAction:(id)sender;
- (IBAction)redButtonTouchUpInsideAction:(id)sender;
- (IBAction)pinkButtonTouchUpInsideAction:(id)sender;
- (IBAction)blueButtonTouchUpInsideAction:(id)sender;
- (IBAction)blackButtonTouchUpInsideAction:(id)sender;
- (IBAction)greenButtonTouchUpInsideAction:(id)sender;
//- (BOOL) selectImage: (UIViewController*) controller
  //     usingDelegate: (id <UIImagePickerControllerDelegate,
    //                   UINavigationControllerDelegate>) delegate;
-(void)updateImageStack;
-(UIImage*)mergeImage:(UIImage*)mask overImage:(UIImage*)source inSize:(CGSize)size;

- (cv::Mat)cvMatFromUIImage:(UIImage *)image;
- (UIImage *)inverseColor:(UIImage *)image;
//- (void)createCannyImage:(UIImage *)input fromCamera:(bool)fromCamera;

@end

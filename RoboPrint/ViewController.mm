//
//  ViewController.m
//  RoboPrint
//
//  Created by The Dude on 4/5/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import "ViewController.h"
#import "RoboPrintController.h"
#import <RNGridMenu/RNGridMenu.h>
#import <QuartzCore/QuartzCore.h>
#import "BLEInterface.h"

// Aperture value to use for the Canny edge detection
const int kCannyAperture = 3;

@interface ViewController ()

@end

@implementation ViewController

// Color Buttons
@synthesize yellowButton;
@synthesize redButton;
@synthesize pinkButton;
@synthesize blueButton;
@synthesize blackButton;
@synthesize greenButton;

// Mode Buttons
@synthesize imagesButton;
@synthesize pencilButton;
@synthesize backgroundsButton;
@synthesize shapesButton;
@synthesize enlargeButton;
@synthesize textButton;

// Other properties
@synthesize model;
@synthesize canvasImageView;
@synthesize backgroundImageView;
@synthesize lastImage;
@synthesize imageStack;
@synthesize backButton;
@synthesize forwardButton;
@synthesize popupMenuName;
@synthesize connectionView;


// OpenCV properties




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Clear the current background
    [self.backgroundImageView setImage:nil];
    
    // Initialize sub controller
    self.model = [[RoboPrintController alloc] init];
    
    // Initialize bluetooth connection with robot
    self.robotInterface = [[BLEInterface alloc] init];
    self.robotInterface.delegate = self;
    
    // Declare colors as black
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 3.0;
    opacity = 1.0;
    
    // Set start state for color menu
    [self.yellowButton setImage:nil forState:UIControlStateNormal];
    [self.redButton setImage:nil forState:UIControlStateNormal];
    [self.pinkButton setImage:nil forState:UIControlStateNormal];
    [self.blueButton setImage:nil forState:UIControlStateNormal];
    [self.blackButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                      forState:UIControlStateNormal];
    [self.greenButton setImage:nil forState:UIControlStateNormal];
    self.model.currentColor = BLACK;
    imageStackIndex = 0; // most recent image
    
    // Set start state for left menu
    [self.imagesButton setImage:nil forState:UIControlStateNormal];
    [self.pencilButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                       forState:UIControlStateNormal];
    [self.backgroundsButton setImage:nil forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self.enlargeButton setImage:nil forState:UIControlStateNormal];
    [self.textButton setImage:nil forState:UIControlStateNormal];
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects
    self.model.currentMode = PENCIL_DRAW_MODE;
    
    // END TODO
    
    // Initialize image stack and associated bools, ints, and nav buttons
    self.imageStack = [[NSMutableArray alloc] init];
    exceededImageStackMaxLength = false;
    mostRecentCanvasState = nil;
    imageStackMaxSize = 30;     // Set maximum number of go-back actions to be 30 drawing events
    passedMaxImageIndexOnce = false;
    
    // On start, disable back button
    [self.backButton setImage:[UIImage imageNamed:@"back_disabled.png"]
                     forState:UIControlStateNormal];
    // On start, disable forward button
    [self.forwardButton setImage:[UIImage imageNamed:@"forward_disabled.png"]
                     forState:UIControlStateNormal];
    
    startOverButonResponse = false;
    
    // Set up pinch gesture recognizer for Enlarge menu
    self.canvasImageView.userInteractionEnabled = YES;
    UIPinchGestureRecognizer *pgr = [[UIPinchGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handlePinch:)];
    pgr.delegate = self;
    [self.canvasImageView addGestureRecognizer:pgr];
    //[pgr release];
    
    // Set starting shape width and origin
    defaultShapeWidth = 100.0;
    shapeWidth = defaultShapeWidth;
    defaultShapeOrigin = CGPointMake(self.canvasImageView.frame.size.width/2-defaultShapeWidth/2,
                                     self.canvasImageView.frame.size.height/2-defaultShapeWidth/2);
    shapeOrigin = defaultShapeOrigin;
    shapeOriginOffset.x = 0;
    shapeOriginOffset.y = 0;
    currentShape = CIRCLE;
    shapeCreationIndex = 0;
    lineCanBeMoved = TRUE;
    
    cannySliderValue = 10;
    cannySliderMinVal = 1;
    cannySliderMaxVal = 255/3;
    cannySliderWidth = 250;
    cannySliderHeigth = 40;
    cannyButtonWidth = cannySliderWidth/2;
    cannyButtonHeight = cannySliderHeigth;
    cannyButtonsExist = false;
    textLeft = 0;
    textTop = 0;
    textLeftOffset = 0;
    textTopOffset = 0;
    defaultTextLeft = 0;
    defaultTextTop = 0;
    textWidth = 300;
    textHeight = 40;
    defaultFontSize = 25;
    fontSize = defaultFontSize;
    currentTextString = NULL;
    
    // Initializations for bluetooth connection with robot
    listOfDrawingCommands = [NSMutableArray array];
    [listOfDrawingCommands addObject:@"first string"]; // same with float values
    [listOfDrawingCommands addObject:@"second string"];
    [listOfDrawingCommands addObject:@"third string"];
    
    isEditingText = FALSE;
    hasSketchBeenLoaded = FALSE;
    
    [self.robotInterface initBTInterface];
    self.robotInterface.delegate = self;
    
    self.connectionView.hidden = YES; // make hidden by default
    self.connectionView.layer.cornerRadius = 5; // round the corners
    self.connectionView.layer.masksToBounds = YES;
    self.connectionView.layer.borderColor = [UIColor blackColor].CGColor;
    self.connectionView.layer.borderWidth = 3.0f;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/********* BEGIN COLOR MENU ***************/

- (IBAction)yellowButtonTouchUpInsideAction:(id)sender
{
    [self.yellowButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                        forState:UIControlStateNormal];
    [self.redButton setImage:nil forState:UIControlStateNormal];
    [self.pinkButton setImage:nil forState:UIControlStateNormal];
    [self.blueButton setImage:nil forState:UIControlStateNormal];
    [self.blackButton setImage:nil forState:UIControlStateNormal];
    [self.greenButton setImage:nil forState:UIControlStateNormal];
    self.model.currentColor = YELLOW;
    [self parseColorChangeEvent];
}
- (IBAction)redButtonTouchUpInsideAction:(id)sender
{
    [self.yellowButton setImage:nil forState:UIControlStateNormal];
    [self.redButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                       forState:UIControlStateNormal];
    [self.pinkButton setImage:nil forState:UIControlStateNormal];
    [self.blueButton setImage:nil forState:UIControlStateNormal];
    [self.blackButton setImage:nil forState:UIControlStateNormal];
    [self.greenButton setImage:nil forState:UIControlStateNormal];
    self.model.currentColor = RED;
    [self parseColorChangeEvent];
}
- (IBAction)pinkButtonTouchUpInsideAction:(id)sender
{
    [self.yellowButton setImage:nil forState:UIControlStateNormal];
    [self.redButton setImage:nil forState:UIControlStateNormal];
    [self.pinkButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                    forState:UIControlStateNormal];
    [self.blueButton setImage:nil forState:UIControlStateNormal];
    [self.blackButton setImage:nil forState:UIControlStateNormal];
    [self.greenButton setImage:nil forState:UIControlStateNormal];
    self.model.currentColor = PINK;
    [self parseColorChangeEvent];
}
- (IBAction)blueButtonTouchUpInsideAction:(id)sender
{
    [self.yellowButton setImage:nil forState:UIControlStateNormal];
    [self.redButton setImage:nil forState:UIControlStateNormal];
    [self.pinkButton setImage:nil forState:UIControlStateNormal];
    [self.blueButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                     forState:UIControlStateNormal];
    [self.blackButton setImage:nil forState:UIControlStateNormal];
    [self.greenButton setImage:nil forState:UIControlStateNormal];
    self.model.currentColor = BLUE;
    [self parseColorChangeEvent];
}
- (IBAction)blackButtonTouchUpInsideAction:(id)sender
{
    [self.yellowButton setImage:nil forState:UIControlStateNormal];
    [self.redButton setImage:nil forState:UIControlStateNormal];
    [self.pinkButton setImage:nil forState:UIControlStateNormal];
    [self.blueButton setImage:nil forState:UIControlStateNormal];
    [self.blackButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                     forState:UIControlStateNormal];
    [self.greenButton setImage:nil forState:UIControlStateNormal];
    self.model.currentColor = BLACK;
    [self parseColorChangeEvent];
}
- (IBAction)greenButtonTouchUpInsideAction:(id)sender
{
    [self.yellowButton setImage:nil forState:UIControlStateNormal];
    [self.redButton setImage:nil forState:UIControlStateNormal];
    [self.pinkButton setImage:nil forState:UIControlStateNormal];
    [self.blueButton setImage:nil forState:UIControlStateNormal];
    [self.blackButton setImage:nil forState:UIControlStateNormal];
    [self.greenButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                      forState:UIControlStateNormal];
    self.model.currentColor = GREEN;
    [self parseColorChangeEvent];
}

- (void)parseColorChangeEvent
{
    // If text or shapes are being edited when a color button
    // is pressed, we need to update the color of that object
    switch (model.currentMode) {
        case SHAPES_MODE:
            if (([imageStack count] > 0) && (shapeCreationIndex == imageStackIndex))
            {
                shapeOrigin.x = (defaultShapeOrigin.x + shapeOriginOffset.x);
                shapeOrigin.y = (defaultShapeOrigin.y + shapeOriginOffset.y);
                
                // Put the new shape on the canvas
                UIImage *shape;
                switch (currentShape) {
                    case CIRCLE:
                        shape = [self addCircle:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case SQUARE:
                        shape = [self addSquare:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case TRIANGLE:
                        shape = [self addTriangle:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case PENTAGON:
                        shape = [self addPentagon:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case STAR:
                        shape = [self addStar:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case LINE:
                        if (lineCanBeMoved)
                        {
                            // Drag line around (movement phase)
                            CGPoint tempP1 = CGPointMake((lineP1.x + shapeOriginOffset.x), (lineP1.y + shapeOriginOffset.y));
                            CGPoint tempP2 = CGPointMake((lineP2.x + shapeOriginOffset.x), (lineP2.y + shapeOriginOffset.y));
                            shape = [self addLine:(self->canvasImageView.image) P1:tempP1 P2:tempP2];
                            
                        }
                        
                        break;
                    default:
                        break;
                }
                
                // Pop previous circle off the stack
                [imageStack removeObjectAtIndex:0];
                
                // Make sure there was more than one image on the stack
                if ([imageStack count] > 0)
                {
                    // Set the image on the canvas to the one before the shape was added
                    [self.canvasImageView setImage:[self.imageStack objectAtIndex: 0]];
                }
                else
                {
                    [self.canvasImageView setImage:nil];
                }
                // Put the new shape on the canvas
                self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(canvasImageView.frame.size.height, canvasImageView.frame.size.width)];
                // Update image stack
                [self updateImageStack];
            }
            break;
    
        case TEXT_MODE:
            
            if (isEditingText)
            {
                textField.textColor = [UIColor colorWithRed:model.getRed green:model.getGreen blue:model.getBlue alpha:1.0f];
            }
            else
            {
                if (([imageStack count] > 0))
                {
                    
                    textLeft = defaultTextLeft + textLeftOffset;
                    textTop = defaultTextTop + textTopOffset;
                    
                    // Put the new shape on the canvas
                    UIImage *textImage;

                    [imageStack removeObjectAtIndex:0];
                    
                    textImage = [self imageFromText];
                    
                    // Make sure there was more than one image on the stack
                    if ([imageStack count] > 0)
                    {
                        // Set the image on the canvas to the one before the shape was added
                        [self.canvasImageView setImage:[self.imageStack objectAtIndex: 0]];
                    }
                    else
                    {
                        [self.canvasImageView setImage:nil];
                    }
                    // Put the new shape on the canvas
                    self->canvasImageView.image = [self mergeImage:textImage overImage:self.canvasImageView.image inSize:CGSizeMake(canvasImageView.frame.size.height, canvasImageView.frame.size.width)];
                    // Update image stack
                    [self updateImageStack];
                    
                }
            }
            break;
        //
        case BACKGROUNDS_MODE:
        case PENCIL_SKETCH_MODE:
        case ENLARGE_MODE:
            [self.imagesButton setImage:nil forState:UIControlStateNormal];
            [self.pencilButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                               forState:UIControlStateNormal];
            [self.backgroundsButton setImage:nil forState:UIControlStateNormal];
            [self.shapesButton setImage:nil forState:UIControlStateNormal];
            [self.enlargeButton setImage:nil forState:UIControlStateNormal];
            [self.textButton setImage:nil forState:UIControlStateNormal];
            [self cannyExecuteDoneAction]; // cleanup pencil sketch objects
            self.model.currentMode = PENCIL_DRAW_MODE;
            break;
            

            
        default:
            break;
    }
    
}

/********* BEGIN SIDE MENU ***************/

- (IBAction)openImagePicker:(id)sender
{
    [self.imagesButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                       forState:UIControlStateNormal];
    [self.pencilButton setImage:nil forState:UIControlStateNormal];
    [self.backgroundsButton setImage:nil forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self.enlargeButton setImage:nil forState:UIControlStateNormal];
    [self.textButton setImage:nil forState:UIControlStateNormal];
    self.model.currentMode = PENCIL_SKETCH_MODE;

    // First, present dialog to load from file, camera, or canclel
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Pencil Sketch"
                                                   message: @"Clear canvas and generate pencil sketch?"
                                                  delegate: self
                                         cancelButtonTitle:@"From Photo"
                                         otherButtonTitles:@"Cancel",@"From Camera", nil];
    alert.tag = PENCIL_SKETCH_TAG;
    [alert show];

}

- (IBAction)pencilPressed:(id)sender
{
    
    [self.imagesButton setImage:nil forState:UIControlStateNormal];
    [self.pencilButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                       forState:UIControlStateNormal];
    [self.backgroundsButton setImage:nil forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self.enlargeButton setImage:nil forState:UIControlStateNormal];
    [self.textButton setImage:nil forState:UIControlStateNormal];
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects
    self.model.currentMode = PENCIL_DRAW_MODE;
}

-(IBAction)dispatchScenesMenu:(id)sender{
    [self.imagesButton setImage:nil forState:UIControlStateNormal];
    [self.pencilButton setImage:nil forState:UIControlStateNormal];
    [self.backgroundsButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                             forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self.enlargeButton setImage:nil forState:UIControlStateNormal];
    [self.textButton setImage:nil forState:UIControlStateNormal];
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects
    self.model.currentMode = BACKGROUNDS_MODE;
    
    if (hasSketchBeenLoaded)
    {
        // Present user w/ opportunity to bail on erasing image to
        // load new background
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Change Background"
                                                       message: @"Delete sketch and load a new background?"
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Load New",nil];
        alert.tag = BACKGROUNDS_MENU_TAG;
        [alert show];
    }
    else
    {
        NSArray *images = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"bg1_RElephant_SMALL.jpg"],
                           [UIImage imageNamed:@"bg2_Rengine_SMALL.jpg"],
                           [UIImage imageNamed:@"bg3_RGuitar_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg4_Rhclown_face_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg5_RHotAIr_Baloon_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg6_RHouse_SMALL.jpg"],
                           [UIImage imageNamed:@"bg7_Rjeep_SMALL.jpg"],
                           [UIImage imageNamed:@"bg8_RKite_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg9_RTeddyBear_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg10_RTractor_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg11_RTricycle_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg12_none.png"],
                           nil];

        
        RNGridMenu *av = [[RNGridMenu alloc] initWithImages:images];
        
        popupMenuName = BACKGROUNDS_MENU;
        av.delegate = self;
        
        [av showInViewController:self center:CGPointMake(500, 500)];
    }
    
}

-(IBAction)dispatchShapesMenu:(id)sender{
    [self.imagesButton setImage:nil forState:UIControlStateNormal];
    [self.pencilButton setImage:nil forState:UIControlStateNormal];
    [self.backgroundsButton setImage:nil forState:UIControlStateNormal];
    [self.shapesButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                        forState:UIControlStateNormal];
    [self.enlargeButton setImage:nil forState:UIControlStateNormal];
    [self.textButton setImage:nil forState:UIControlStateNormal];
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects
    self.model.currentMode = SHAPES_MODE;
    
    NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"_circle.png"],
                       [UIImage imageNamed:@"_tri.png"],
                       [UIImage imageNamed:@"_line.png"],
                       [UIImage imageNamed:@"_square.png"],
                       [UIImage imageNamed:@"_star.png"],
                       [UIImage imageNamed:@"_pent.png"],
                       nil];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:images];
    //RoboPrintController *menuController = [[RoboPrintController alloc] init];
    
    popupMenuName = SHAPES_MENU;
    av.delegate = self;
    
    //av.highlightColor = [UIColor colorWithRed:66.0f/255.0f green:79.0f/255.0f blue:91.0f/255.0f alpha:1.0f];
    
    [av showInViewController:self center:CGPointMake(500, 500)];
    
}


- (IBAction)enlargePressed:(id)sender
{
    [self.imagesButton setImage:nil forState:UIControlStateNormal];
    [self.pencilButton setImage:nil forState:UIControlStateNormal];
    [self.backgroundsButton setImage:nil forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self.enlargeButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                        forState:UIControlStateNormal];
    [self.textButton setImage:nil forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects
    self.model.currentMode = ENLARGE_MODE;
    
    UIImage *zoomedImage;
    
    // Zoom by a factor of 2 from the center
    zoomedImage = [self croppedImageWithImage:(self->canvasImageView.image) zoom:2.0f];
    
    // Need to resize whatever the image size was
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 0.0);
    [zoomedImage drawInRect:CGRectMake(0, 0, canvasImageView.frame.size.width,canvasImageView.frame.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Put the new shape on the canvas
    self->canvasImageView.image = newImage;
    // Update image stack
    [self updateImageStack];
    
}

- (IBAction)textPressed:(id)sender
{
    [self.imagesButton setImage:nil forState:UIControlStateNormal];
    [self.pencilButton setImage:nil forState:UIControlStateNormal];
    [self.backgroundsButton setImage:nil forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self.enlargeButton setImage:nil forState:UIControlStateNormal];
    [self.textButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                     forState:UIControlStateNormal];
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects
    self.model.currentMode = TEXT_MODE;
    
    defaultTextTop = textHeight;
    defaultTextLeft = canvasImageView.frame.size.width/2 - textWidth/2;
    
    textTop = defaultTextTop;
    textLeft = defaultTextLeft;
    textLeftOffset = 0;
    textTopOffset  = 0;
    fontSize = defaultFontSize;
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(canvasImageView.frame.origin.x + textLeft, canvasImageView.frame.origin.y + textTop, textWidth, textHeight)];

    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:fontSize];
    textField.placeholder = @"Everything is Awesome";
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = [UIColor colorWithRed:model.getRed green:model.getGreen blue:model.getBlue alpha:1.0f];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.delegate = self;
    [self.view addSubview:textField];
    [super viewWillAppear:true];
    [textField becomeFirstResponder];
    
    isEditingText = TRUE;
}


- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    // TODO condense the two switch statements
    //handle pinch...
    switch (self.model.currentMode) {
        case SHAPES_MODE:
            if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded
                || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
            {
                if (pinchGestureRecognizer.scale < 1)
                {
                    // Pinch in
                    shapeWidth-=4;
                }
                else
                {
                    // Pinch out
                    shapeWidth+=4;
                }

                if ([imageStack count] > 0)
                {
                    // Get scale of pinch
                    //shapeWidth *= newScale;
                    UIImage *shape = nil;
                    // Put the new shape on the canvas
                    switch (currentShape)
                    {
                        // Pinches not supported for a line
                            
                        case CIRCLE:
                            shape = [self addCircle:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                            break;
                        case SQUARE:
                            shape = [self addSquare:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                            break;
                        case TRIANGLE:
                            shape = [self addTriangle:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                            break;
                        case PENTAGON:
                            shape = [self addPentagon:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                            break;
                        case STAR:
                            shape = [self addStar:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                            break;
                            
                        default:
                            break;
                    }
                    
                    // Pop previous circle off the stack
                    [imageStack removeObjectAtIndex:0];
                    
                    // Make sure there was more than one image on the stack
                    if ([imageStack count] > 0)
                    {
                        // Set the image on the canvas to the one before the shape was added
                        [self.canvasImageView setImage:[self.imageStack objectAtIndex: 0]];
                    }
                    else
                    {
                        [self.canvasImageView setImage:nil];
                    }
                    // Put the new shape on the canvas
                    self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(canvasImageView.frame.size.height, canvasImageView.frame.size.width)];
                    // Update image stack
                    [self updateImageStack];
                }
                pinchGestureRecognizer.scale = 1;
            }
            break;
            
        case TEXT_MODE:
            if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded
                || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
            {
                
                if (pinchGestureRecognizer.scale < 1)
                {
                    // Pinch in
                    fontSize--;
                }
                else
                {
                    // Pinch out
                    fontSize++;
                }
                
                if ([imageStack count] > 0)
                {
                    UIImage *shape = nil;
                    // Put the new shape on the canvas

                    // Pop previous circle off the stack
                    [imageStack removeObjectAtIndex:0];
                    
                    shape = [self imageFromText];

                    // Make sure there was more than one image on the stack
                    if ([imageStack count] > 0)
                    {
                        // Set the image on the canvas to the one before the shape was added
                        [self.canvasImageView setImage:[self.imageStack objectAtIndex: 0]];
                    }
                    else
                    {
                        [self.canvasImageView setImage:nil];
                    }
                    // Put the new shape on the canvas
                    self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(canvasImageView.frame.size.height, canvasImageView.frame.size.width)];
                    // Update image stack
                    [self updateImageStack];
                }
                pinchGestureRecognizer.scale = 1;
            }
            break;
        case ENLARGE_MODE:
            
            //Pinch not supported in ENLARGE_MODE
            break;
            
        default:
            break;
    }
    
}


/********* BEGIN TOP MENU ***************/

- (IBAction)backPressed:(id)sender
{
    // Handler for back button
    
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects if present
    
    int imagesOnStack = (int)[imageStack count]; // Need to cast to signed int
    
    // Enable forward button if clicked back from existing image and not very first thing
    if ([imageStack count] > 0)
    {
        [self.forwardButton setImage:[UIImage imageNamed:@"forward_button.png"]
                            forState:UIControlStateNormal];
    }
    
    // Check to see if there are previous images on the stack
    if (imageStackIndex < (imagesOnStack))
    {
        // Not at end of stack, so load next image
        if (!(imageStackIndex == imagesOnStack - 1))
        {
            [self.canvasImageView setImage:[self.imageStack objectAtIndex: imageStackIndex + 1]];
            imageStackIndex++;
            
            // Disable back button if next click is beyond max stack size
            if (imageStackIndex == imageStackMaxSize - 1)
            {
                // Disable back button
                [self.backButton setImage:[UIImage imageNamed:@"back_disabled.png"]
                                 forState:UIControlStateNormal];
                passedMaxImageIndexOnce = true;
            }
        }
        else
        {
            // At end of stack, either because of stack size or start of drawing
            [self.backButton setImage:[UIImage imageNamed:@"back_disabled.png"]
                             forState:UIControlStateNormal];
            if (imageStackIndex == imageStackMaxSize - 1)
            {
                // Reached back click limit due to max size limitation
                // No need to do anything
            }
            else
            {
                if (passedMaxImageIndexOnce == false)
                {
                    // Reached end of stack because there's nothing earlier
                    // Since we can't load a non-image, we clear the existing image
                    [self.canvasImageView setImage:nil]; // clear image
                    imageStackIndex = imagesOnStack;
                }
                
            }
            
        }
    }
}

- (IBAction)forwardPressed:(id)sender
{
    // Handler for forward action
    
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects if present
    
    if (imageStackIndex > 0)
    {
        // Back has been pressed prior to the forward button being pressed
        imageStackIndex--;
        [self.canvasImageView setImage:[self.imageStack objectAtIndex: imageStackIndex ]];

        // Re-enable back button
        [self.backButton setImage:[UIImage imageNamed:@"back_button.png"]
                            forState:UIControlStateNormal];
        
        if (imageStackIndex == 0)
        {
            // Disable forward button if got to front of stack
            [self.forwardButton setImage:[UIImage imageNamed:@"forward_disabled.png"]
                                forState:UIControlStateNormal];
        }
    }
    else
    {
        // Forward pressed before back is pressed
        if ([imageStack count] > 0)
        {
            // Just reset to top of stack if there is anything on it
            [self.canvasImageView setImage:[self.imageStack objectAtIndex:0 ]];
        }
    }
}

- (IBAction)startOverPressed:(id)sender
{
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects if present

    // Initially, show an alert letting the user know
    // that this will erase their progress
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Warning"
                                                   message: @"Starting over will erase all current content. Continue?"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Start Over",nil];
    alert.tag = START_OVER_TAG;
    [alert show];
    
    // Handing done in alertView handler
}

- (IBAction)openImagePressed:(id)sender
{
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects if present

    // Initially, show an alert letting the user know
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Warning"
                                                message: @"Opening an image will erase this image. Continue?"
                                                delegate: self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Load Image",nil];
    alert.tag = LOAD_DRAWING_TAG;
    [alert show];
}



- (IBAction)saveImagePressed:(id)sender
{
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects if present

    UIImageWriteToSavedPhotosAlbum(self.canvasImageView.image, nil, nil, nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saving Images"
                                                    message:@"Image saved successfully."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
        
    // TODO - add error catching
}


- (IBAction)printPressed:(id)sender
{
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects if present

    // TODO if not null - may need to reinitialize
    
    // TODO if not connected
    [self.robotInterface connectToRobot];
    
    self.connectionView.hidden = NO;
    
    // Make the progress dialog a bit taller than standard
    // TODO give the progress view a 'analyzing image' state
    [progressView setTransform:CGAffineTransformMakeScale(1.0, 3.0)];
    
    // Add to the connection frame and add a default value
    [self.connectionView addSubview:progressView];
    [progressView setProgress:0.0 animated:NO];
    
    // Break the image into the 6 sub-color images
    std::vector<cv::Mat>binaryImages;
    //cv::Mat M = SomehowGetMatrix();
    for (int color = 0; color <= GREEN; color++)
    {
        // YELLOW     = 0;
        // RED        = 1;
        // PINK       = 2;
        // BLUE       = 3;
        // BLACK      = 4;
        // GREEN      = 5;
        
        // First, create a single channel binary image of this color
        cv::Mat binaryMat = [self cvBinFromRGBUIImage:self->canvasImageView.image colorIn:color];
        
        // TODO extract image commands for this color channel
        
        // Quick test to see if this works
        if (color == PINK)
        {
            self.canvasImageView.image=[self UIImageFromCVMat:binaryMat];
        }

    }
    
    // TODO - send actual image commands
    // Temporary stand in for actual commands
    for (int i=0; i<10; i++)
    {
        
        NSString *strFromInt = [NSString stringWithFormat:@"%d",i];
        [self.robotInterface.messageQueue addObject:strFromInt];

    }
}


- (void)updateProgress:(NSNumber *)number
{
    // Update the percent complete on the progress dialog
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressView setProgress:number.floatValue animated:YES];
    });
    
    // Dismiss the dialog
    if (progressView.progress == 1.0)
    {
        self.connectionView.hidden = YES;
        
        // Display Done Uploading message
        NSString *messageString = @"Robot Should Now Be Printing...";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Done Uploading!"
                                                            message:messageString delegate:self
                                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)openSettingsMenu:(id)sender
{
    
    
    NSArray *settingsMenuOptions = @[@"Robot Connection Settings", @"About", @"Review This App", @"Contact Us"];
    
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithTitles:settingsMenuOptions];
    CGSize temp = CGSizeMake(200, 50);
    av.itemSize = temp;
    
    popupMenuName = SETTINGS_MENU;
    av.delegate = self;
    
    [av showInViewController:self center:CGPointMake(500, 500)];
    
    [self cannyExecuteDoneAction]; // cleanup pencil sketch objects if present
}


/********* BEGIN CANVAS HANDLERS ***************/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    // TODO - Confirm that start of touch is in canvas
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self->canvasImageView];
    lastPoint.x = lastPoint.x;
    lastPoint.y = lastPoint.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // TODO - Condense the switch statements
    
    switch (self.model.currentMode)
    {
        case (PENCIL_DRAW_MODE):
        {
            mouseSwiped = YES; // Indicates that this is not a single point
            UITouch *touch = [touches anyObject];
            
            // Get current absolute location of touch event in the view
            CGPoint currentPoint = [touch locationInView:self->canvasImageView];
            
            // Scale the point so that it matches the height and width of the drawing canvas
            currentPoint.x = currentPoint.x;
            currentPoint.y = currentPoint.y;
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
            [self->canvasImageView.image drawInRect:CGRectMake(0, 0, canvasImageView.frame.size.width, canvasImageView.frame.size.height)];
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
            
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
            
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            self->canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext();
            [self->canvasImageView setAlpha:opacity];
            UIGraphicsEndImageContext();
            
            lastPoint = currentPoint;
            break;
        }
        
        case (SHAPES_MODE):
        {
            if (([imageStack count] > 0) && (shapeCreationIndex == imageStackIndex))
            {
                // Get current absolute location of touch event in the view
                UITouch *touch = [touches anyObject];
                CGPoint currentPoint = [touch locationInView:self->canvasImageView];
                
                // Scale the point so that it matches the height and width of the drawing canvas
                shapeOrigin.x = (defaultShapeOrigin.x + (currentPoint.x - lastPoint.x) + shapeOriginOffset.x);
                shapeOrigin.y = (defaultShapeOrigin.y + (currentPoint.y - lastPoint.y) + shapeOriginOffset.y);
                
                // Put the new shape on the canvas
                UIImage *shape;
                switch (currentShape) {
                    case CIRCLE:
                        shape = [self addCircle:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case SQUARE:
                        shape = [self addSquare:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case TRIANGLE:
                        shape = [self addTriangle:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case PENTAGON:
                        shape = [self addPentagon:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case STAR:
                        shape = [self addStar:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin)];
                        break;
                    case LINE:
                        if (lineCanBeMoved)
                        {
                            // Drag line around (movement phase)
                            CGPoint tempP1 = CGPointMake((lineP1.x + (currentPoint.x - lastPoint.x) + shapeOriginOffset.x), (lineP1.y + (currentPoint.y - lastPoint.y) + shapeOriginOffset.y));
                            CGPoint tempP2 = CGPointMake((lineP2.x + (currentPoint.x - lastPoint.x) + shapeOriginOffset.x), (lineP2.y + (currentPoint.y - lastPoint.y) + shapeOriginOffset.y));
                            shape = [self addLine:(self->canvasImageView.image) P1:tempP1 P2:tempP2];
                            
                        }
                        else
                        {
                            // Set end point of line (creation phase)
                            lineP2 = currentPoint;
                            lineP2.x = currentPoint.x;
                            lineP2.y = currentPoint.y;
                            shape = [self addLine:(self->canvasImageView.image) P1:lineP1 P2:lineP2];
                            lastPoint = currentPoint;
                        }
                        
                        break;
                    default:
                        break;
                }
                
                // Pop previous circle off the stack
                [imageStack removeObjectAtIndex:0];
                
                // Make sure there was more than one image on the stack
                if ([imageStack count] > 0)
                {
                    // Set the image on the canvas to the one before the shape was added
                    [self.canvasImageView setImage:[self.imageStack objectAtIndex: 0]];
                }
                else
                {
                    [self.canvasImageView setImage:nil];
                }
                // Put the new shape on the canvas
                self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(canvasImageView.frame.size.height, canvasImageView.frame.size.width)];
                // Update image stack
                [self updateImageStack];
            }
            
      
            break;
        }
            
        case TEXT_MODE:
        {
            if (([imageStack count] > 0))
            {
                // Get current absolute location of touch event in the view
                UITouch *touch = [touches anyObject];
                CGPoint currentPoint = [touch locationInView:self->canvasImageView];
                
                textLeft = (defaultTextLeft + (currentPoint.x - lastPoint.x) + textLeftOffset);
                textTop = (defaultTextTop + (currentPoint.y - lastPoint.y) + textTopOffset);
                
                // Put the new shape on the canvas
                UIImage *textImage;

                
                
                // Pop previous circle off the stack
                [imageStack removeObjectAtIndex:0];
                
                textImage = [self imageFromText];
                
                // Make sure there was more than one image on the stack
                if ([imageStack count] > 0)
                {
                    // Set the image on the canvas to the one before the shape was added
                    [self.canvasImageView setImage:[self.imageStack objectAtIndex: 0]];
                }
                else
                {
                    [self.canvasImageView setImage:nil];
                }
                // Put the new shape on the canvas
                self->canvasImageView.image = [self mergeImage:textImage overImage:self.canvasImageView.image inSize:CGSizeMake(canvasImageView.frame.size.height, canvasImageView.frame.size.width)];
                // Update image stack
                [self updateImageStack];

            }

            
        }
            
        default:
        {

            break;
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    switch (self.model.currentMode)
    {
        case (PENCIL_DRAW_MODE):
        {
            [self updateImageStack];
        }
            
        case (SHAPES_MODE):
        {
            // Get current absolute location of touch event in the view
            UITouch *touch = [touches anyObject];
            
            // Get current absolute location of touch event in the view
            CGPoint currentPoint = [touch locationInView:self->canvasImageView];

            shapeOriginOffset.x += (currentPoint.x - lastPoint.x);
            shapeOriginOffset.y += (currentPoint.y - lastPoint.y);
            lineCanBeMoved = TRUE;
            break;
        }
            
        case (TEXT_MODE):
        {
            // Get current absolute location of touch event in the view
            UITouch *touch = [touches anyObject];
            
            // Get current absolute location of touch event in the view
            CGPoint currentPoint = [touch locationInView:self->canvasImageView];
            textLeftOffset += (currentPoint.x - lastPoint.x);
            textTopOffset  += (currentPoint.y - lastPoint.y);
            break;
        }
            
        default:
        {

            break;
        }
    }


    
    
}

-(void)updateImageStack
{
    // Ignore events that didn't create images and single points
    if ((self.canvasImageView.image != nil && mouseSwiped) ||
        (self.model.currentMode == SHAPES_MODE) ||
        (self.model.currentMode == PENCIL_SKETCH_MODE) ||
        (self.model.currentMode == ENLARGE_MODE) ||
        (self.model.currentMode == TEXT_MODE) )
    {
        [self.backButton setImage:[UIImage imageNamed:@"back_button.png"]
                         forState:UIControlStateNormal];
        
        // Need to remove things at front of stack and update index
        // Need to clear image stack if back has been pressed and drawing started again
        if (imageStackIndex != 0)
        {
            // In this case, back was pressed, then new drawing began,
            // so we need to clear everything off the stack that the
            // user clicked 'back' through'
            for (int index = 0; index < imageStackIndex; index++)
            {
                [imageStack removeObjectAtIndex:0];
            }
            // Reset stack index as head
            imageStackIndex = 0;
            
            // Save chosen image as current top of stack
            if (self.canvasImageView.image != nil)
            {
                // Then put current image as head
                [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
            }
            
            // Disable forward button
            [self.forwardButton setImage:[UIImage imageNamed:@"forward_disabled.png"]
                                forState:UIControlStateNormal];
            
        }
        else
        {
            // Otherwise, just add this image to the stack
            
            // First ensure that there is room at the back of the stack
            if ([imageStack count] == imageStackMaxSize)
            {
                [imageStack removeObjectAtIndex:(imageStackMaxSize - 1)];
            }
            if (self.canvasImageView.image != nil)
            {
                [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
            }
        }
    }
    
}

/****************       BEGIN OTHER HANDLERS    ****************/
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This function handles the results of any yes/no dialogs that have had the yes
    // button selected.

    // Clicked through warning. Load image.
    if ((alertView.tag == START_OVER_TAG) && buttonIndex)
    {
        // call the start state
        [self viewDidLoad];
        
        // Clear the currently displayed image
        self.canvasImageView.image = nil;
        
        // Clear the current background
        [self.backgroundImageView setImage:nil];
        
        // Clear all images off of the image stack
        while ([imageStack count] > 0)
        {
            [imageStack removeObjectAtIndex:0];
        }
        imageStackIndex = 0;
        
        // Disable forward and back buttons
        [self.forwardButton setImage:[UIImage imageNamed:@"forward_disabled.png"]
                            forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"back_disabled.png"]
                         forState:UIControlStateNormal];
    }
    // Clicked through warning. Load image.
    else if (alertView.tag == LOAD_DRAWING_TAG && buttonIndex)
    {
        // call the start state
        [self viewDidLoad];
        
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        [self presentViewController:picker animated:YES completion:nil];
        
        // Clear all images off of the image stack
        while ([imageStack count] > 0)
        {
            [imageStack removeObjectAtIndex:0];
        }
        imageStackIndex = 0;
        
        // Disable forward and back buttons
        [self.forwardButton setImage:[UIImage imageNamed:@"forward_disabled.png"]
                            forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"back_disabled.png"]
                         forState:UIControlStateNormal];
    }
    else if (alertView.tag == BACKGROUNDS_MENU_TAG && buttonIndex != 0)
    {
        // Since a sketch has been loaded, selection of a new background image
        // will not appear (sketches are opaque). A dialog has just been shown that
        // the user clicked through to delete the current image.
        
        // call the start state
        [self viewDidLoad];
        
        // Clear the currently displayed image
        self.canvasImageView.image = nil;
        
        // Clear the current background
        [self.backgroundImageView setImage:nil];
        
        // Clear all images off of the image stack
        while ([imageStack count] > 0)
        {
            [imageStack removeObjectAtIndex:0];
        }
        imageStackIndex = 0;
        
        // Disable forward and back buttons
        [self.forwardButton setImage:[UIImage imageNamed:@"forward_disabled.png"]
                            forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"back_disabled.png"]
                         forState:UIControlStateNormal];
        
        // Prepare background images
        NSArray *images = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"bg1_RElephant_SMALL.jpg"],
                           [UIImage imageNamed:@"bg2_Rengine_SMALL.jpg"],
                           [UIImage imageNamed:@"bg3_RGuitar_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg4_Rhclown_face_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg5_RHotAIr_Baloon_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg6_RHouse_SMALL.jpg"],
                           [UIImage imageNamed:@"bg7_Rjeep_SMALL.jpg"],
                           [UIImage imageNamed:@"bg8_RKite_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg9_RTeddyBear_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg10_RTractor_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg11_RTricycle_color_SMALL.jpg"],
                           [UIImage imageNamed:@"bg12_none.png"],
                           nil];
        
        // Dispatch menu
        RNGridMenu *av = [[RNGridMenu alloc] initWithImages:images];
        
        popupMenuName = BACKGROUNDS_MENU;
        av.delegate = self;
        
        [av showInViewController:self center:CGPointMake(500, 500)];
    }
    else if (alertView.tag == PENCIL_SKETCH_TAG && buttonIndex != 1)
    {
        // call the start state and reset mode
        [self viewDidLoad];
        [self.imagesButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                           forState:UIControlStateNormal];
        [self.pencilButton setImage:nil forState:UIControlStateNormal];
        self.model.currentMode = PENCIL_SKETCH_MODE;
        
        // Ignore button index of 1 (Cancel)
        if (buttonIndex != 1)
        {
            // Initialize picker
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            
            if(buttonIndex == 2) // Load from camera
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

                    [self presentViewController:picker animated:YES completion:nil];
                    
                    // Clear all images off of the image stack
                    while ([imageStack count] > 0)
                    {
                        [imageStack removeObjectAtIndex:0];
                    }
                    imageStackIndex = 0;
                    
                    // Disable forward and back buttons
                    [self.forwardButton setImage:[UIImage imageNamed:@"forward_disabled.png"]
                                        forState:UIControlStateNormal];
                    [self.backButton setImage:[UIImage imageNamed:@"back_disabled.png"]
                                     forState:UIControlStateNormal];
                    
                    hasSketchBeenLoaded = TRUE;
                }
                else
                {
                    // display device not available error
                    NSString *messageString = @"Cannot access camera.";
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loading Image"
                                                                        message:messageString delegate:self
                                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                }
            }
            else // button index 0 - load from photo gallery
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                {
                    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                    
                    [self presentViewController:picker animated:YES completion:nil];
                    
                    // Clear all images off of the image stack
                    while ([imageStack count] > 0)
                    {
                        [imageStack removeObjectAtIndex:0];
                    }
                    imageStackIndex = 0;
                    
                    // Disable forward and back buttons
                    [self.forwardButton setImage:[UIImage imageNamed:@"forward_disabled.png"]
                                        forState:UIControlStateNormal];
                    [self.backButton setImage:[UIImage imageNamed:@"back_disabled.png"]
                                     forState:UIControlStateNormal];
                    
                    hasSketchBeenLoaded = TRUE;
                }
                else
                {
                    // display device not available error
                    NSString *messageString = @"Cannot access photo library.";
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loading Image"
                                                                        message:messageString delegate:self
                                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                }
            }
        }
    }
}




- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    
    UIImage *shape = [UIImage imageNamed:@"color_selected_mask.png"]; // Initialization
    UIImage *background = [UIImage imageNamed:@"color_selected_mask.png"]; // Initialization
    
    // Must declare variables outside of switch menu
    CGPoint p1;
    CGPoint p2;

    // This function is the listener for the pop-up menus.
    
    switch (popupMenuName)
    {
        case SHAPES_MENU:
            currentShape = (int)itemIndex;
            switch (itemIndex)
            {
                case CIRCLE:
                    shape = [self addCircle:(self->canvasImageView.image) radius:(defaultShapeWidth/2) origin:(defaultShapeOrigin)];
                    break;
                case TRIANGLE:
                    shape = [self addTriangle:(self->canvasImageView.image) radius:(defaultShapeWidth/2) origin:(defaultShapeOrigin)];
                    break;
                case LINE:
                    // Set default start and end points for line
                    p1 = CGPointMake(defaultShapeOrigin.x, defaultShapeOrigin.y);
                    p2 = CGPointMake(defaultShapeOrigin.x+defaultShapeWidth, defaultShapeOrigin.y+defaultShapeWidth);
                    lineP1 = p1;
                    lineP2 = p2;
                    shape = [self addLine:(self->canvasImageView.image) P1:p1 P2:p2];
                    lineCanBeMoved = FALSE;
                    break;
                case SQUARE:
                    shape = [self addSquare:(self->canvasImageView.image) radius:(defaultShapeWidth/2) origin:(defaultShapeOrigin)];
                    break;
                case STAR:
                    shape = [self addStar:(self->canvasImageView.image) radius:(defaultShapeWidth/2) origin:(defaultShapeOrigin)];
                    break;
                case PENTAGON:
                    shape = [self addPentagon:(self->canvasImageView.image) radius:(defaultShapeWidth/2) origin:(defaultShapeOrigin)];
                    break;
                default:
                    break;
                    
                
            }
            // Reset all defaults for this shape since it is new
            shapeOrigin = defaultShapeOrigin;
            shapeOriginOffset.x = 0;
            shapeOriginOffset.y = 0;
            shapeWidth = defaultShapeWidth;

            // Put the new shape on the canvas
            self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(canvasImageView.frame.size.height, canvasImageView.frame.size.width)];
            // Update image stack
            [self updateImageStack];
            
            // Set the index for the shape as the current index
            shapeCreationIndex = imageStackIndex;
            
            break;
        case BACKGROUNDS_MENU:
            switch (itemIndex)
            {
                case 0:
                    background =  [UIImage imageNamed:@"bg1_RElephant.jpg"];
                    break;
                case 1:
                    background =  [UIImage imageNamed:@"bg2_Rengine.jpg"];
                    break;
                case 2:
                    background =  [UIImage imageNamed:@"bg3_RGuitar_color.jpg"];
                    break;
                case 3:
                    background =  [UIImage imageNamed:@"bg4_Rhclown_face_color.jpg"];
                    break;
                case 4:
                    background =  [UIImage imageNamed:@"bg5_HotAIr_Baloon_color.jpg"];
                    break;
                case 5:
                    background =  [UIImage imageNamed:@"bg6_RHouse.jpg"];
                    break;
                case 6:
                    background =  [UIImage imageNamed:@"bg7_Rjeep.jpg"];
                    break;
                case 7:
                    background =  [UIImage imageNamed:@"bg8_RKite_color.jpg"];
                    break;
                case 8:
                    background =  [UIImage imageNamed:@"bg9_RTeddyBear_color.jpg"];
                    break;
                case 9:
                    background =  [UIImage imageNamed:@"bg10_RTractor_color.jpg"];
                    break;
                case 10:
                    background =  [UIImage imageNamed:@"bg11_RTricycle_color.jpg"];
                    break;
                case 11:
                    [self.backgroundImageView setImage:nil];
                    background =  self.backgroundImageView.image;
                    break;
                default:
                    break;
                
            }
            
            UIGraphicsBeginImageContext(self.view.frame.size);
            [self->backgroundImageView.image drawInRect:CGRectMake(0, 0, canvasImageView.frame.size.width, canvasImageView.frame.size.height)];
            //self->canvasImageView.image = [self maskImage:self->canvasImageView.image withMask:background];
            [self->backgroundImageView setImage:background];

            UIGraphicsEndImageContext();
            //[self updateImageStack];

            break;
            
        case SETTINGS_MENU:
            UIAlertView *alert;
            switch (itemIndex)
            {
                case 0:
                    // connection settings
                    
                    
                    
                    alert = [[UIAlertView alloc]initWithTitle: @"Connection Settings"
                                                                   message: @"To be implemented in Phase 3."
                                                                  delegate: self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                    //alert.tag = PENCIL_SKETCH_TAG;
                    break;
                case 1:
                    // About
                    alert = [[UIAlertView alloc] initWithTitle:@"About"
                                                                    message:@"Property of Anwar Farooq."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    break;
                case 2:
                    // Review this app
                    alert = [[UIAlertView alloc] initWithTitle:@"Review This App"
                                                                    message:@"Link to be provided in Phase 3."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    break;
                case 3:
                    // Contact Us
                    alert = [[UIAlertView alloc] initWithTitle:@"Contact"
                                                                    message:@"Contact us at http://www.mrfarooq.com"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    http://www.mrfarooq.com
                    break;
                
                default:
                    break;
                    
            }
            [alert show];

    }

    
}


-(UIImage*)mergeImage:(UIImage*)mask overImage:(UIImage*)source inSize:(CGSize)size
{
    //Capture image context ref
    
    // TODO - try a different tactic for memory management here. Don't alloc on every call
    
    UIImageView *totalimage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.height, size.width)];
    
    UIImageView *firstImage=[[UIImageView alloc] initWithImage:mask];
    UIImageView *secondImage=[[UIImageView alloc] initWithImage:source];
    
    [totalimage addSubview:firstImage];
    [totalimage addSubview:secondImage];
    
    UIGraphicsBeginImageContext(totalimage.bounds.size);
    [totalimage.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //Draw images onto the context
    [source drawInRect:CGRectMake(0, 0, source.size.width, source.size.height)];
    [mask drawInRect:CGRectMake(0, 0, mask.size.width, mask.size.height)];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (self.model.currentMode == PENCIL_SKETCH_MODE)
    {
        // Send this image to the canny edge detector
        
        // Handles loader for choices from image library
        [self dismissViewControllerAnimated:YES completion:nil];
        UIImage *cannyInput = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        // Need to resize whatever the image size was
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 0.0);
        [cannyInput drawInRect:CGRectMake(0, 0, canvasImageView.frame.size.width,canvasImageView.frame.size.height)];
        UIImage *resizedCanny = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self createCannyImage:resizedCanny fromCamera:FALSE replace:FALSE];
        
        // Add controller objects for the edge detector
        [self cannySlider];
        [self addCannyRotateButton];
        [self addCannyDoneButton];
        [self cannySliderText];
        
        hasSketchBeenLoaded = TRUE;
        
    }
    else
    {
        // Handles loader for choices from image library
        [self dismissViewControllerAnimated:YES completion:nil];
        canvasImageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        // Save chosen image as current top of stack
        if (self.canvasImageView.image != nil)
        {
            [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
        }
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    // Forces orientation to be landscape mode
    return UIInterfaceOrientationMaskAll;
}

-(UIImage *)addCircle:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextStrokeEllipseInRect(context, CGRectMake((origin.x+radius), (origin.y+radius), 2*radius, 2*radius));
    CGContextStrokeEllipseInRect(context, CGRectMake((origin.x+radius+1), (origin.y+radius+1), 2*radius-2, 2*radius-2));
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}
/***************** BEGIN TEXT HANDLING ********************/

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textFieldIn{
    textFieldIn.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textFieldIn{
    textFieldIn.borderStyle = UITextBorderStyleNone;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
    //CGContextRef context = UIGraphicsGetCurrentContext();

    currentTextString = textField.text;
    UIImage *imageOfText = [self imageFromText];
    
    // Merge image of text with existing image on canvas
    imageOfText = [self mergeImage:imageOfText overImage:self.canvasImageView.image inSize:CGSizeMake(canvasImageView.frame.size.height, canvasImageView.frame.size.width)];
    
    self->canvasImageView.image = imageOfText;
    
    // Add finalized image to the image stack
    [self updateImageStack];
    
    [textField removeFromSuperview];
    
    isEditingText = FALSE;
    
}

-(UIImage *)imageFromText
{
    

    // set the font type and size
    UIFont *font = [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:fontSize];
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height),NO,1);
    }
    else
    {
        // iOS is < 4.0
        UIGraphicsBeginImageContext(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height));
    }
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),
                                   [UIColor colorWithRed:model.getRed green:model.getGreen blue:model.getBlue alpha:1.0f].CGColor);
    
    [currentTextString drawAtPoint:CGPointMake(textLeft, textTop) withFont:font];
    
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGRect rect = CGRectMake(0, 0, canvasImageView.frame.size.width, canvasImageView.frame.size.height);
    [image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];

    UIImage *testImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return testImg;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFieldIn{
    [textFieldIn resignFirstResponder];
    return TRUE;
}

/***************** BEGIN SHAPE ADDERS *********************/

-(UIImage *)addSquare:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 2);
    
    // Top edge
    CGContextMoveToPoint(context, (origin.x),(origin.y));
    CGContextAddLineToPoint(context, (origin.x+2*radius), (origin.y));
    
    // Left Edge
    CGContextMoveToPoint(context, (origin.x),(origin.y));
    CGContextAddLineToPoint(context, (origin.x), (origin.y+2*radius));
    
    // Right Edge
    CGContextMoveToPoint(context, (origin.x+2*radius),(origin.y+2*radius));
    CGContextAddLineToPoint(context, (origin.x+2*radius), (origin.y));
    
    // Bottom Edge
    CGContextMoveToPoint(context, (origin.x),(origin.y+2*radius));
    CGContextAddLineToPoint(context, (origin.x+2*radius), (origin.y+2*radius));
    
    CGContextStrokePath(context);
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage *)addTriangle:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 2);
    
    // Left edge
    CGContextMoveToPoint(context, (origin.x+radius),(origin.y-radius/2));
    CGContextAddLineToPoint(context, (origin.x), (origin.y+radius));
    
    // Right Edge
    CGContextMoveToPoint(context, (origin.x+radius),(origin.y-radius/2));
    CGContextAddLineToPoint(context, (origin.x+2*radius), (origin.y+radius));
    
    // Bottom Edge
    CGContextMoveToPoint(context, (origin.x),(origin.y+radius));
    CGContextAddLineToPoint(context, (origin.x+2*radius), (origin.y+radius));
    
    CGContextStrokePath(context);

    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage *)addPentagon:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 2);
    
    float fudgeFactor = 0.2;
    // Pentagon Points
    CGPoint topPoint = CGPointMake((origin.x+radius),
                                   (origin.y + (radius*fudgeFactor)));
    CGPoint topLeftPoint = CGPointMake((origin.x),
                                   (origin.y + radius));
    CGPoint topRightPoint = CGPointMake((origin.x+2*radius),
                                   (origin.y + radius));
    CGPoint bottomLeftPoint = CGPointMake((origin.x + radius*2*fudgeFactor),
                                   (origin.y + 2*radius));
    CGPoint bottomRightPoint = CGPointMake((origin.x + 2*radius - radius*2*fudgeFactor),
                                   (origin.y + 2*radius));
    
    // Connect the dots
    
    // top to top left
    CGContextMoveToPoint(context, topPoint.x, topPoint.y);
    CGContextAddLineToPoint(context, topLeftPoint.x, topLeftPoint.y);
    
    // top left to bottom left
    CGContextMoveToPoint(context, topLeftPoint.x, topLeftPoint.y);
    CGContextAddLineToPoint(context, bottomLeftPoint.x, bottomLeftPoint.y);
    
    // bottom left to bottom right
    CGContextMoveToPoint(context, bottomLeftPoint.x, bottomLeftPoint.y);
    CGContextAddLineToPoint(context, bottomRightPoint.x, bottomRightPoint.y);
    
    // bottom right to top right
    CGContextMoveToPoint(context, bottomRightPoint.x, bottomRightPoint.y);
    CGContextAddLineToPoint(context, topRightPoint.x, topRightPoint.y);
    
    // top right to top
    CGContextMoveToPoint(context, topRightPoint.x, topRightPoint.y);
    CGContextAddLineToPoint(context, topPoint.x, topPoint.y);
    
    CGContextStrokePath(context);
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage *)addStar:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 2);
    
    // In this function, it will be easier to work in the polar coordinate system.
    CGFloat outerRadius = radius;
    CGFloat innerRadius = radius/4;
    CGFloat outerTheta = 0;
    CGFloat innerTheta = 0;
    CGFloat PI = 3.14;
    CGFloat offset = PI/8; // degrees
    CGFloat delta = PI/4; // degrees
    CGPoint tempInner;
    CGPoint tempOuter;
    CGPoint innerLast;
    CGPoint actualOrigin = CGPointMake((origin.x + radius),
                                       (origin.y + radius));

    // Initialize first inner point
    innerTheta = offset;
    innerLast = CGPointMake((actualOrigin.x + innerRadius*cosf(innerTheta)),
                            (actualOrigin.y + innerRadius*sinf(innerTheta)));
    
    for (innerTheta = offset; innerTheta < 2*PI; innerTheta += delta)
    {
        // Create the inner and outer points
        tempInner = CGPointMake((actualOrigin.x + innerRadius*cosf(innerTheta)),
                    (actualOrigin.y + innerRadius*sinf(innerTheta)));
        tempOuter = CGPointMake((actualOrigin.x + outerRadius*cosf(outerTheta)),
                                (actualOrigin.y + outerRadius*sinf(outerTheta)));
        
        // Connect the last inner point to the new outer point
        CGContextMoveToPoint(context, innerLast.x,innerLast.y);
        CGContextAddLineToPoint(context, tempOuter.x, tempOuter.y);
        
        // Connect the outer point to the new inner point
        CGContextMoveToPoint(context, tempInner.x,tempInner.y);
        CGContextAddLineToPoint(context, tempOuter.x, tempOuter.y);
        
        innerLast = tempInner;
        
        // increment angle of outer circle
        outerTheta += delta;
    }
    
    // Connect last dot
    tempOuter = CGPointMake((actualOrigin.x + outerRadius*cosf(outerTheta)),
                            (actualOrigin.y + outerRadius*sinf(outerTheta)));
    CGContextMoveToPoint(context, tempInner.x,tempInner.y);
    CGContextAddLineToPoint(context, tempOuter.x, tempOuter.y);
    
    CGContextStrokePath(context);
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage *)addLine:(UIImage *)img P1:(CGPoint)P1 P2:(CGPoint)P2
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 2);
    
    // Draw a single line
    CGContextMoveToPoint(context, (P1.x),(P1.y));
    CGContextAddLineToPoint(context, (P2.x), (P2.y+2));
    
    CGContextStrokePath(context);
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage*)croppedImageWithImage:(UIImage *)image zoom:(CGFloat)zoom
{
    //CGFloat zoom = 2.0f;
    CGFloat zoomReciprocal = 1.0f / zoom;
    
    CGPoint offset = CGPointMake(image.size.width * ((1.0f - zoomReciprocal) / 2.0f), image.size.height * ((1.0f - zoomReciprocal) / 2.0f));
    CGRect croppedRect = CGRectMake(offset.x, offset.y, image.size.width * zoomReciprocal, image.size.height * zoomReciprocal);
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], croppedRect);
    
    UIImage* croppedImage = [[UIImage alloc] initWithCGImage:croppedImageRef scale:[image scale] orientation:[image imageOrientation]];
    
    CGImageRelease(croppedImageRef);
    
    return croppedImage;
}

/*********** BEGIN OPEN CV SUPPORT ********************/
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)cvBinFromRGBUIImage:(UIImage *)image colorIn:(int)colorIn
{
    // Get the current current color
    int currentColor = self.model.currentColor;
    
    // Temporarily set the color to the input color
    self.model.currentColor = colorIn;
    
    // Get the threshold values
    float redComponent = self.model.getRed*255;
    float greenComponent = self.model.getGreen*255;
    float blueComponent = self.model.getBlue*255;
    
    // Initailize out output value
    cv::Mat binaryOut(image.size.height, image.size.width, CV_8UC1); // 8 bits per component, single channel
    
    // TODO - add some buffer room from the input values for backgrounds
    //float halfRange = 1;
    
    if(image == nil)
    {
        // TODO add error handling for no input image
        NSLog(@"You're in trouble, buddy");
        cv::Mat someNil;
        return someNil;
    }
    
    // Convert from UIImage (xcode) to Mat (opencv)
    cv::Mat img=[self cvMatFromUIImage:image];

    // Create pointers to the 4 channel input data and pixel arrays
    uint8_t* pixelPtr = (uint8_t*)img.data;
    int cn = img.channels();
    
    // Create simple 3 int arrays for the input image pixel data and the threshold values
    cv::Scalar_<uint8_t> bgrPixel; // input image - determined pixel by pixel
    cv::Scalar_<uint8_t> inColors; // threshold vals - determined statically below
    inColors.val[0] = (int)redComponent;
    inColors.val[1] = (int)greenComponent;
    inColors.val[2] = (int)blueComponent;
    
    // Create pointer to the single hannel output image
    uint8_t* outBinPtr = (uint8_t*)binaryOut.data;
    
    // Cycle through each row in the 4 channel input image
    for(int i = 0; i < img.rows; i++)
    {
        // Cycle through each pixel in each column of this row
        for(int j = 0; j < img.cols; j++)
        {
            // Determine the RGB values of this pixel
            bgrPixel.val[0] = pixelPtr[i*img.cols*cn + j*cn + 0]; // B
            bgrPixel.val[1] = pixelPtr[i*img.cols*cn + j*cn + 1]; // G
            bgrPixel.val[2] = pixelPtr[i*img.cols*cn + j*cn + 2]; // R
            
            // Perform thresholding on a match
            if ((bgrPixel.val[0] == inColors.val[0]) &&
                (bgrPixel.val[1] == inColors.val[1]) &&
                (bgrPixel.val[2] == inColors.val[2]))

            {
                outBinPtr[i*binaryOut.cols + j] = 255;
            }
            else
            {
                outBinPtr[i*binaryOut.cols + j] = 0;
            }
        }
    }

    // Reset the current color back to the original
    self.model.currentColor = currentColor;
    
    //return the thresholded binary image
    return binaryOut;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (UIImage *)inverseColor:(UIImage *)image
{
    CIImage *coreImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:coreImage forKey:kCIInputImageKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    return [UIImage imageWithCIImage:result];
}

- (void)createCannyImage:(UIImage *)input fromCamera:(bool)fromCamera replace:(bool)replace
{
    if (!replace)
    {
        // Create (greyscale) cvMat input for edge detector
        inputArrayForCanny = [self cvMatFromUIImage:input];
    }

    // Initialize output
    cv::Mat output;
    
    // Perform Canny edge detection using slide values for thresholds
    cv::Canny(inputArrayForCanny, output,
              cannySliderValue * kCannyAperture,
              cannySliderValue * 3,
              kCannyAperture);
    
    // convert output of canny transform to UIImage
    cvEdgeOuptut = [self UIImageFromCVMat:output];
    
    // Invert the color
    cvEdgeOuptut = [self inverseColor:cvEdgeOuptut];
    
    // Display the image
    [self.canvasImageView setImage:cvEdgeOuptut];

}

-(IBAction)cannySlider
{
    // Creates the slider for the pencil sketch and sets up listener
    CGRect frame = CGRectMake(canvasImageView.frame.size.width/2,
                              canvasImageView.frame.size.height - cannySliderHeigth,
                              cannySliderWidth,
                              cannySliderHeigth);
    cannySlider = [[UISlider alloc] initWithFrame:frame];
    [cannySlider addTarget:self action:@selector(cannySliderAction:) forControlEvents:UIControlEventValueChanged];
    [cannySlider setBackgroundColor:[UIColor lightGrayColor]];
    [cannySlider setMinimumTrackTintColor:[UIColor redColor]];
    cannySlider.minimumValue = cannySliderMinVal;
    cannySlider.maximumValue = cannySliderMaxVal;
    cannySlider.continuous = NO;
    cannySlider.value = (cannySliderMaxVal - cannySliderMinVal);
    cannySlider.layer.cornerRadius = 10.0f;
    [self.view addSubview:cannySlider];
}

-(void)cannySliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    cannySliderValue = slider.value;

    [self createCannyImage:self.canvasImageView.image fromCamera:FALSE replace:TRUE];
}

-(IBAction)addCannyRotateButton
{
    cannyRotateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cannyRotateButton addTarget:self
               action:@selector(cannyRotateAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [cannyRotateButton setBackgroundColor:[UIColor lightGrayColor]];
    [cannyRotateButton setTitle:@"Rotate Image" forState:UIControlStateNormal];
    cannyRotateButton.tintColor = [UIColor redColor];
    cannyRotateButton.frame = CGRectMake(canvasImageView.frame.size.width/2 - cannySliderWidth*.25 - cannyButtonWidth,
                                    canvasImageView.frame.size.height - cannySliderHeigth,
                                    cannyButtonWidth,
                                    cannyButtonHeight);
    cannyRotateButton.layer.cornerRadius = 10.0f;
    [self.view addSubview:cannyRotateButton];
}

-(IBAction)uploadCancelPressed:(id)sender
{
    // TODO other parsing for when the cancel button is pressed
    // TODO make the button switch to DONE once done
    self.connectionView.hidden = YES;
}

-(void)cannyRotateAction:(id)sender
{
    // Flip across X axis then Y to rotate 90 degrees
    cv::transpose(inputArrayForCanny,inputArrayForCanny);
    cv::flip(inputArrayForCanny,inputArrayForCanny, 1);
    
    // Update the display issue
    [self createCannyImage:self.canvasImageView.image fromCamera:FALSE replace:TRUE];
    
}

-(IBAction)addCannyDoneButton
{
    cannyDoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cannyDoneButton addTarget:self
                     action:@selector(cannyDoneAction:)
           forControlEvents:UIControlEventTouchUpInside];
    [cannyDoneButton setBackgroundColor:[UIColor lightGrayColor]];
    [cannyDoneButton setTitle:@"Done Editing" forState:UIControlStateNormal];
    cannyDoneButton.tintColor = [UIColor redColor];
    cannyDoneButton.frame = CGRectMake(canvasImageView.frame.size.width/2 + cannySliderWidth*.75 + cannyButtonWidth,
                                    canvasImageView.frame.size.height - cannySliderHeigth,
                                    cannyButtonWidth,
                                    cannyButtonHeight);
    cannyDoneButton.layer.cornerRadius = 10.0f;
    [self.view addSubview:cannyDoneButton];
    cannyButtonsExist = true;
}

-(void)cannyDoneAction:(id)sender
{
    // Redirect to cleanup function
    [self cannyExecuteDoneAction];
}

-(IBAction)cannyExecuteDoneAction
{
    if (cannyButtonsExist)
    {
    // Clean up all programatically added screen helper elements for the pencil sketch
    [cannySliderLabel removeFromSuperview];
    [cannyRotateButton removeFromSuperview];
    [cannyDoneButton removeFromSuperview];
    [cannySlider removeFromSuperview];
    
    // TODO - low priority - figure out why I need these four lines to avoid major lag on first action after canny
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(canvasImageView.frame.size.width,canvasImageView.frame.size.height), NO, 1);
    [self->canvasImageView.image drawInRect:CGRectMake(0, 0, canvasImageView.frame.size.width, canvasImageView.frame.size.height)];
    self->canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self->canvasImageView setAlpha:opacity];
    UIGraphicsEndImageContext();
        
    // Add finalized image to the image stack
    [self updateImageStack];
    cannyButtonsExist = false;
    }
}

-(IBAction)cannySliderText
{
    cannySliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(
            canvasImageView.frame.size.width/2,
            canvasImageView.frame.size.height - 2*cannySliderHeigth,
            cannyButtonWidth*2,
            cannyButtonHeight)];
    cannySliderLabel.backgroundColor = [UIColor clearColor];
    cannySliderLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter, UITextAlignmentLeft
    cannySliderLabel.textColor=[UIColor redColor];
    cannySliderLabel.font = [UIFont systemFontOfSize:25];
    cannySliderLabel.text = @"Fine Tune Sketch...";
    [self.view addSubview:cannySliderLabel];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end




/****************       SUPPLEMENTAL    ****************/

// The following functions are only used for the image picker in landscape mode
@implementation UIViewController (OrientationFix)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end

@implementation UIImagePickerController (OrientationFix)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end







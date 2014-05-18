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
@synthesize xRescale;
@synthesize yRescale;

// OpenCV properties




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize sub controller
    self.model = [[RoboPrintController alloc] init];
    
    // Declare colors as black
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 1.0;
    opacity = 1.0;
    
    // TODO - replace this block with function call
    [self.yellowButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                       forState:UIControlStateNormal];
    [self.redButton setImage:nil forState:UIControlStateNormal];
    [self.pinkButton setImage:nil forState:UIControlStateNormal];
    [self.blueButton setImage:nil forState:UIControlStateNormal];
    [self.blackButton setImage:nil forState:UIControlStateNormal];
    [self.greenButton setImage:nil forState:UIControlStateNormal];
    self.model.currentColor = YELLOW;
    imageStackIndex = 0; // most recent image
    
    self.model.currentMode = PENCIL_MODE;
    [self.pencilButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                       forState:UIControlStateNormal];
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
    
    // Set up scale factors
    xRescale = (self.view.frame.size.width/self->canvasImageView.frame.size.width);
    yRescale = (self.view.frame.size.height/self->canvasImageView.frame.size.height);
    
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
    cannySliderWidth = 200;
    cannySliderHeigth = 20;
    cannyButtonWidth = cannySliderWidth/2;
    cannyButtonHeight = cannySliderHeigth*2;
    
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
    self.model.currentMode = PENCIL_SKETCH;
    // TODO
    // SEE HERE FOR INSTRUCTIONS FOR GETTING IMAGE FROM CAMERA
    // http://www.icodeblog.com/2009/07/28/getting-images-from-the-iphone-photo-library-or-camera-using-uiimagepickercontroller/
    
    // TODO
    // there is a bug where, if you load a pencil sketch, the very next thing you do suffers from
    // sever memory lag. 

    // First, present dialog to load from file, camera, or canclel
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Pencil Sketch"
                                                   message: @"Clear canvas and generate pencil sketch?"
                                                  delegate: self
                                         cancelButtonTitle:@"From Photo"
                                         otherButtonTitles:@"Cancel",@"From Camera", nil];
    alert.tag = PENCIL_SKETCH;
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
    self.model.currentMode = PENCIL_MODE;
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
    //RoboPrintController *menuController = [[RoboPrintController alloc] init];
    
    popupMenuName = BACKGROUNDS_MENU;
    av.delegate = self;
    
    //av.highlightColor = [UIColor colorWithRed:66.0f/255.0f green:79.0f/255.0f blue:91.0f/255.0f alpha:1.0f];
    
    [av showInViewController:self center:CGPointMake(500, 500)];
    
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
    
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Adding Text"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}


- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    //handle pinch...
    switch (self.model.currentMode) {
        case SHAPES_MODE:
            if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded
                || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
            {
                
                CGFloat currentScale = self.canvasImageView.frame.size.width / self.canvasImageView.bounds.size.width;
                CGFloat newScale = currentScale * pinchGestureRecognizer.scale;
                
                if (newScale < MINIMUM_SCALE) {
                    newScale = MINIMUM_SCALE;
                }
                if (newScale > MAXIMUM_SCALE) {
                    newScale = MAXIMUM_SCALE;
                }
                if ([imageStack count] > 0)
                {
                    // Get scale of pinch
                    shapeWidth *= newScale;
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
                    self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(self.view.frame.size.height, self.view.frame.size.width)];
                    // Update image stack
                    [self updateImageStack];
                }
                pinchGestureRecognizer.scale = 1;
            }
            break;
            
        case TEXT_MODE:
            //NSLog(@"should be resizing text now");
            break;
        case ENLARGE_MODE:
            if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded
                || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
                //NSLog(@"gesture.scale = %f", pinchGestureRecognizer.scale);
                
                CGFloat currentScale = self.canvasImageView.frame.size.width / self.canvasImageView.bounds.size.width;
                CGFloat newScale = currentScale * pinchGestureRecognizer.scale;
                
                if (newScale < MINIMUM_SCALE) {
                    newScale = MINIMUM_SCALE;
                }
                if (newScale > MAXIMUM_SCALE) {
                    newScale = MAXIMUM_SCALE;
                }
                
                CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
                self.canvasImageView.transform = transform;
                //CGFloat tx = 5.0f;
                //CGFloat ty = 1500.0f;
                // transform = CGAffineTransformMakeTranslation(tx, ty);
                
                self.canvasImageView.transform = transform;
                [self.canvasImageView setCenter:CGPointMake(self.canvasImageView.center.x, self.canvasImageView.center.y + 44)];
                pinchGestureRecognizer.scale = 1;
            }
            //NSLog(@"should be resizing image now");
            break;
            
            
        default:
            //NSLog(@"should be doing nothing now");
            break;
    }
    
}


/********* BEGIN TOP MENU ***************/

- (IBAction)backPressed:(id)sender
{
    // Handler for back button
    
    int imagesOnStack = [imageStack count]; // Need to cast to signed int
    
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
    // Initially, show an alert letting the user know
    // that this will erase their progress
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Warning"
                                                   message: @"Starting over will erase all current content. Continue?"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Start Over",nil];
    alert.tag = START_OVER;
    [alert show];
    
    // Handing done in alertView handler
}

- (IBAction)openImagePressed:(id)sender
{
    // Initially, show an alert letting the user know
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Warning"
                                                message: @"Opening an image will erase this image. Continue?"
                                                delegate: self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Load Image",nil];
    alert.tag = LOAD_DRAWING;
    [alert show];
}



- (IBAction)saveImagePressed:(id)sender
{
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Robo Print!"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}

- (IBAction)openSettingsMenu:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Manage Settings"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}


/********* BEGIN CANVAS HANDLERS ***************/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    // TODO - Confirm that start of touch is in canvas
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self->canvasImageView];
    lastPoint.x = lastPoint.x*xRescale;
    lastPoint.y = lastPoint.y*yRescale;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // TODO - Confirm that start of touch is in canvas
    
    
    switch (self.model.currentMode)
    {
        case (PENCIL_MODE):
        {
            mouseSwiped = YES; // Indicates that this is not a single point
            UITouch *touch = [touches anyObject];
            
            // Get current absolute location of touch event in the view
            CGPoint currentPoint = [touch locationInView:self->canvasImageView];
            
            // Scale the point so that it matches the height and width of the drawing canvas
            currentPoint.x = currentPoint.x*xRescale;
            currentPoint.y = currentPoint.y*yRescale;
            
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 1);
            [self->canvasImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
            //NSLog(@"RGB are (%f,%f,%f", self.model.getRed,self.model.getGreen,self.model.getBlue);
            
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
                currentPoint.x = currentPoint.x*xRescale;
                currentPoint.y = currentPoint.y*yRescale;
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
                            //NSLog(@"Offsets are %f, %f",shapeOriginOffset.x, shapeOriginOffset.y);
                            CGPoint tempP1 = CGPointMake((lineP1.x + (currentPoint.x - lastPoint.x) + shapeOriginOffset.x), (lineP1.y + (currentPoint.y - lastPoint.y) + shapeOriginOffset.y));
                            CGPoint tempP2 = CGPointMake((lineP2.x + (currentPoint.x - lastPoint.x) + shapeOriginOffset.x), (lineP2.y + (currentPoint.y - lastPoint.y) + shapeOriginOffset.y));
                            shape = [self addLine:(self->canvasImageView.image) P1:tempP1 P2:tempP2];
                            
                        }
                        else
                        {
                            // Set end point of line (creation phase)
                            lineP2 = currentPoint;
                            lineP2.x = currentPoint.x/xRescale;
                            lineP2.y = currentPoint.y/yRescale;
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
                self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(self.view.frame.size.height, self.view.frame.size.width)];
                // Update image stack
                [self updateImageStack];
            }
            
      
            break;
        }
            
        default:
        {
            //NSLog(@"Mode other than pencil");
            break;
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    switch (self.model.currentMode)
    {
        case (PENCIL_MODE):
        {
            [self updateImageStack];
        }
            
        case (SHAPES_MODE):
        {
            // Get current absolute location of touch event in the view
            UITouch *touch = [touches anyObject];
            
            // Get current absolute location of touch event in the view
            CGPoint currentPoint = [touch locationInView:self->canvasImageView];
            // Scale the point so that it matches the height and width of the drawing canvas
            currentPoint.x = currentPoint.x*xRescale;
            currentPoint.y = currentPoint.y*yRescale;
            shapeOriginOffset.x += (currentPoint.x - lastPoint.x);
            shapeOriginOffset.y += (currentPoint.y - lastPoint.y);
            lineCanBeMoved = TRUE;
            break;
        }
            
        default:
        {
            //NSLog(@"Mode other than pencil");
            break;
        }
    }


    
    
}

-(void)updateImageStack
{
    // Ignore events that didn't create images and single points
    if ((self.canvasImageView.image != nil && mouseSwiped) ||
        (self.model.currentMode == SHAPES_MODE) ||
        (self.model.currentMode == PENCIL_SKETCH) )
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
            NSLog(@"need to clear stack in future");
            for (int index = 0; index < imageStackIndex; index++)
            {
                NSLog(@"Image removed");
                [imageStack removeObjectAtIndex:0];
            }
            // Reset stack index as head
            imageStackIndex = 0;
            
            // Then put current image as head
            [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
            
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
            [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
        }
    }
    
}

/****************       BEGIN OTHER HANDLERS    ****************/
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This function handles the results of any yes/no dialogs that have had the yes
    // button selected.

    // Clicked through warning. Load image.
    if ((alertView.tag == START_OVER) && buttonIndex)
    {
        // Clear the currently displayed image
        self.canvasImageView.image = nil;
        
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
    else if (alertView.tag == LOAD_DRAWING && buttonIndex)
    {
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
    else if (alertView.tag == PENCIL_SKETCH && buttonIndex != 1)
    {
        if (buttonIndex == 0)
        {
            // Load photo from gallery
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
        else if (buttonIndex == 2)
        {
            // Load image from camera
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
            currentShape = itemIndex;
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
            NSLog(@"Select ccc index was %d and the menu was %d", itemIndex, popupMenuName);

            // Put the new shape on the canvas
            self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(self.view.frame.size.height, self.view.frame.size.width)];
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
                    
                // TODO
                    // Update save image to merge with background
                    
                
            }
            
            NSLog(@"Select ccc index was %d and the menu was %d", itemIndex, popupMenuName);
            UIGraphicsBeginImageContext(self.view.frame.size);
            [self->backgroundImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            //self->canvasImageView.image = [self maskImage:self->canvasImageView.image withMask:background];
            [self->backgroundImageView setImage:background];
            
            //NSLog(@"width height: %f, %f", self.view.frame.size.width, self.view.frame.size.height);
            //self->canvasImageView.image = [UIImage imageNamed:@"back_disabled.png"];
            //[self->canvasImageView setAlpha:opacity];
            UIGraphicsEndImageContext();
            //[self updateImageStack];

            break;
            
        default:
            break;
    }

    
}


-(UIImage*)mergeImage:(UIImage*)mask overImage:(UIImage*)source inSize:(CGSize)size
{
    //Capture image context ref
    
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
    
    if (self.model.currentMode == PENCIL_SKETCH)
    {
        // Send this image to the canny edge detector
        
        // Handles loader for choices from image library
        [self dismissViewControllerAnimated:YES completion:nil];
        UIImage *cannyInput = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        [self createCannyImage:cannyInput fromCamera:FALSE replace:FALSE];
        
        // Add controller objects for the edge detector
        [self cannySlider];
        [self addCannyRotateButton];
        [self addCannyDoneButton];
        [self cannySliderText];
        
    }
    else
    {
        // Handles loader for choices from image library
        [self dismissViewControllerAnimated:YES completion:nil];
        canvasImageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        // Save chosen image as current top of stack
        [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    // Forces orientation to be landscape mode
    return UIInterfaceOrientationMaskAll;
}

-(UIImage *)addCircle:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,self.view.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextStrokeEllipseInRect(context, CGRectMake((origin.x+radius)*xRescale, (origin.y+radius)*yRescale, 2*radius*xRescale, 2*radius*yRescale));
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage *)addSquare:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,self.view.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 1);
    
    // Top edge
    CGContextMoveToPoint(context, (origin.x)*xRescale,(origin.y)*yRescale);
    CGContextAddLineToPoint(context, (origin.x+2*radius)*xRescale, (origin.y)*yRescale);
    
    // Left Edge
    CGContextMoveToPoint(context, (origin.x)*xRescale,(origin.y)*yRescale);
    CGContextAddLineToPoint(context, (origin.x)*xRescale, (origin.y+2*radius)*yRescale);
    
    // Right Edge
    CGContextMoveToPoint(context, (origin.x+2*radius)*xRescale,(origin.y+2*radius)*yRescale);
    CGContextAddLineToPoint(context, (origin.x+2*radius)*xRescale, (origin.y)*yRescale);
    
    // Bottom Edge
    CGContextMoveToPoint(context, (origin.x)*xRescale,(origin.y+2*radius)*yRescale);
    CGContextAddLineToPoint(context, (origin.x+2*radius)*xRescale, (origin.y+2*radius)*yRescale);
    
    CGContextStrokePath(context);
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage *)addTriangle:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,self.view.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 1);
    
    // Left edge
    CGContextMoveToPoint(context, (origin.x+radius)*xRescale,(origin.y-radius/2)*yRescale);
    CGContextAddLineToPoint(context, (origin.x)*xRescale, (origin.y+radius)*yRescale);
    
    // Right Edge
    CGContextMoveToPoint(context, (origin.x+radius)*xRescale,(origin.y-radius/2)*yRescale);
    CGContextAddLineToPoint(context, (origin.x+2*radius)*xRescale, (origin.y+radius)*yRescale);
    
    // Bottom Edge
    CGContextMoveToPoint(context, (origin.x)*xRescale,(origin.y+radius)*yRescale);
    CGContextAddLineToPoint(context, (origin.x+2*radius)*xRescale, (origin.y+radius)*yRescale);
    
    CGContextStrokePath(context);

    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage *)addPentagon:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,self.view.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 1);
    
    float fudgeFactor = 0.2;
    // Pentagon Points
    CGPoint topPoint = CGPointMake((origin.x+radius)*xRescale,
                                   (origin.y + (radius*fudgeFactor))*yRescale);
    CGPoint topLeftPoint = CGPointMake((origin.x)*xRescale,
                                   (origin.y + radius)*yRescale);
    CGPoint topRightPoint = CGPointMake((origin.x+2*radius)*xRescale,
                                   (origin.y + radius)*yRescale);
    CGPoint bottomLeftPoint = CGPointMake((origin.x + radius*2*fudgeFactor)*xRescale,
                                   (origin.y + 2*radius)*yRescale);
    CGPoint bottomRightPoint = CGPointMake((origin.x + 2*radius - radius*2*fudgeFactor)*xRescale,
                                   (origin.y + 2*radius)*yRescale);
    
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
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,self.view.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 1);
    
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
    innerLast = CGPointMake((actualOrigin.x + innerRadius*cosf(innerTheta))*xRescale,
                            (actualOrigin.y + innerRadius*sinf(innerTheta))*yRescale);
    
    for (innerTheta = offset; innerTheta < 2*PI; innerTheta += delta)
    {
        // Create the inner and outer points
        tempInner = CGPointMake((actualOrigin.x + innerRadius*cosf(innerTheta))*xRescale,
                    (actualOrigin.y + innerRadius*sinf(innerTheta))*yRescale);
        tempOuter = CGPointMake((actualOrigin.x + outerRadius*cosf(outerTheta))*xRescale,
                                (actualOrigin.y + outerRadius*sinf(outerTheta))*yRescale);
        
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
    tempOuter = CGPointMake((actualOrigin.x + outerRadius*cosf(outerTheta))*xRescale,
                            (actualOrigin.y + outerRadius*sinf(outerTheta))*yRescale);
    CGContextMoveToPoint(context, tempInner.x,tempInner.y);
    CGContextAddLineToPoint(context, tempOuter.x, tempOuter.y);
    
    CGContextStrokePath(context);
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
}

-(UIImage *)addLine:(UIImage *)img P1:(CGPoint)P1 P2:(CGPoint)P2
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,self.view.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextSetLineWidth(context, 1);
    
    // Draw a single line
    CGContextMoveToPoint(context, (P1.x)*xRescale,(P1.y)*yRescale);
    CGContextAddLineToPoint(context, (P2.x)*xRescale, (P2.y+2)*yRescale);
    
    CGContextStrokePath(context);
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
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
    CGRect frame = CGRectMake(self.view.frame.size.width/2,
                              self.view.frame.size.height - 3 * cannySliderHeigth,
                              cannySliderWidth,
                              cannySliderHeigth);
    cannySlider = [[UISlider alloc] initWithFrame:frame];
    [cannySlider addTarget:self action:@selector(cannySliderAction:) forControlEvents:UIControlEventValueChanged];
    [cannySlider setBackgroundColor:[UIColor lightGrayColor]];
    cannySlider.minimumValue = cannySliderMinVal;
    cannySlider.maximumValue = cannySliderMaxVal;
    cannySlider.continuous = NO;
    cannySlider.value = (cannySliderMaxVal - cannySliderMinVal)/2;
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
    cannyRotateButton.frame = CGRectMake(self.view.frame.size.width/2 - cannySliderWidth*.25 - cannyButtonWidth,
                                    self.view.frame.size.height - 3.5 * cannySliderHeigth,
                                    cannyButtonWidth,
                                    cannyButtonHeight);
    cannyRotateButton.layer.cornerRadius = 10.0f;
    [self.view addSubview:cannyRotateButton];
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
    cannyDoneButton.frame = CGRectMake(self.view.frame.size.width/2 + cannySliderWidth*.75 + cannyButtonWidth,
                                    self.view.frame.size.height - 3.5 * cannySliderHeigth,
                                    cannyButtonWidth,
                                    cannyButtonHeight);
    cannyDoneButton.layer.cornerRadius = 10.0f;
    [self.view addSubview:cannyDoneButton];
}

-(void)cannyDoneAction:(id)sender
{
    // Redirect to cleanup function
    [self cannyExecuteDoneAction];
}

-(IBAction)cannyExecuteDoneAction
{
    // Clean up all programatically added screen helper elements for the pencil sketch
    [cannySliderLabel removeFromSuperview];
    [cannyRotateButton removeFromSuperview];
    [cannyDoneButton removeFromSuperview];
    [cannySlider removeFromSuperview];
    
    // Add finalized image to the image stack
    [self updateImageStack];
}

-(IBAction)cannySliderText
{
    cannySliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(
            self.view.frame.size.width/2,
            self.view.frame.size.height - 5 * cannySliderHeigth,
            cannyButtonWidth*2,
            cannyButtonHeight)];
    cannySliderLabel.backgroundColor = [UIColor clearColor];
    cannySliderLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter, UITextAlignmentLeft
    cannySliderLabel.textColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    cannySliderLabel.text = @"Fine Tune Sketch...";
    [self.view addSubview:cannySliderLabel];
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







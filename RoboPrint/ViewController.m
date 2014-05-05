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
@synthesize lastImage;
@synthesize imageStack;
@synthesize backButton;
@synthesize forwardButton;
@synthesize popupMenuName;
@synthesize xRescale;
@synthesize yRescale;



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
    
    self.model.currentMode = PENCIL;
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
    self.model.currentMode = IMAGE;
    // TODO
    // SEE HERE FOR INSTRUCTIONS FOR GETTING IMAGE FROM CAMERA
    // http://www.icodeblog.com/2009/07/28/getting-images-from-the-iphone-photo-library-or-camera-using-uiimagepickercontroller/
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Pencil Sketch Conversion"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}

- (IBAction)pencilSketchPressed:(id)sender
{
    
    [self.imagesButton setImage:nil forState:UIControlStateNormal];
    [self.pencilButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                       forState:UIControlStateNormal];
    [self.backgroundsButton setImage:nil forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self.enlargeButton setImage:nil forState:UIControlStateNormal];
    [self.textButton setImage:nil forState:UIControlStateNormal];
    self.model.currentMode = PENCIL;
}

-(IBAction)dispatchScenesMenu:(id)sender{
    [self.imagesButton setImage:nil forState:UIControlStateNormal];
    [self.pencilButton setImage:nil forState:UIControlStateNormal];
    [self.backgroundsButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                             forState:UIControlStateNormal];
    [self.shapesButton setImage:nil forState:UIControlStateNormal];
    [self.enlargeButton setImage:nil forState:UIControlStateNormal];
    [self.textButton setImage:nil forState:UIControlStateNormal];
    self.model.currentMode = BACKGROUNDS;
    
    NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"1.png"],
                       [UIImage imageNamed:@"2.png"],
                       [UIImage imageNamed:@"3.png"],
                       [UIImage imageNamed:@"4.png"],
                       nil];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:images];
    //RoboPrintController *menuController = [[RoboPrintController alloc] init];
    
    popupMenuName = BACKGROUNDS;
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
    self.model.currentMode = SHAPES;
    
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
    
    popupMenuName = SHAPES;
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
    self.model.currentMode = ENLARGE;
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
    self.model.currentMode = TEXT;
    
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
        case SHAPES:
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
                    
                    // Put the new shape on the canvas
                    UIImage *shape = [self addCircle:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin) replace:TRUE];
                    
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
            
        case TEXT:
            NSLog(@"should be resizing text now");
            break;
        case ENLARGE:
            if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded
                || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
                NSLog(@"gesture.scale = %f", pinchGestureRecognizer.scale);
                
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
            NSLog(@"should be resizing image now");
            break;
            
            
        default:
            NSLog(@"should be doing nothing now");
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
        case (PENCIL):
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
        
        case (SHAPES):
        {
            if ([imageStack count] > 0)
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
                UIImage *shape = [self addCircle:(self->canvasImageView.image) radius:(shapeWidth/2) origin:(shapeOrigin) replace:TRUE];
                
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
            NSLog(@"Mode other than pencil");
            break;
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    switch (self.model.currentMode)
    {
        case (PENCIL):
        {
            [self updateImageStack];
        }
            
        case (SHAPES):
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
            break;
        }
            
        default:
        {
            NSLog(@"Mode other than pencil");
            break;
        }
    }


    
    
}

-(void)updateImageStack
{
    // Ignore events that didn't create images and single points
    if ((self.canvasImageView.image != nil && mouseSwiped) || (self.model.currentMode == SHAPES))
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
    if (buttonIndex == 0)
    {
        //NSLog(@"User decided to cancel Image Load");
    }
    else
    {
        // Clicked through warning. Load image.
        if (alertView.tag == START_OVER)
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
        else if (alertView.tag == LOAD_DRAWING)
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
    }
}




- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    
    UIImage *shape = [UIImage imageNamed:@"color_selected_mask.png"]; // Initialization
    UIImage *background = [UIImage imageNamed:@"color_selected_mask.png"]; // Initialization

    // This function is the listener for the pop-up menus.
    
    switch (popupMenuName)
    {
        case SHAPES:
        
            switch (itemIndex)
            {
                case CIRCLE:
                    shape = [self addCircle:(self->canvasImageView.image) radius:(defaultShapeWidth/2) origin:(defaultShapeOrigin) replace:FALSE];
                    
                    // Reset all defaults for this shape since it is new
                    shapeOrigin = defaultShapeOrigin;
                    shapeOriginOffset.x = 0;
                    shapeOriginOffset.y = 0;
                    shapeWidth = defaultShapeWidth;
                    break;
                case TRIANGLE:
                    shape =  [UIImage imageNamed:@"_tri.png"];
                    break;
                case LINE:
                    shape =  [UIImage imageNamed:@"_line.png"];
                    break;
                case SQUARE:
                    shape =  [UIImage imageNamed:@"_square.png"];
                    break;
                case STAR:
                    shape =  [UIImage imageNamed:@"_star.png"];
                    break;
                case PENTAGRAM:
                    shape =  [UIImage imageNamed:@"_pent.png"];
                    break;
                default:
                    break;
                    
                
            }
            NSLog(@"Select ccc index was %d and the menu was %d", itemIndex, popupMenuName);

            // Put the new shape on the canvas
            self->canvasImageView.image = [self mergeImage:shape overImage:self.canvasImageView.image inSize:CGSizeMake(self.view.frame.size.height, self.view.frame.size.width)];
            // Update image stack
            [self updateImageStack];
            
            break;
        case BACKGROUNDS:
            switch (itemIndex)
            {
                case 0:
                    background =  [UIImage imageNamed:@"1.png"];
                    break;
                case 1:
                    background =  [UIImage imageNamed:@"2.png"];
                    break;
                case 2:
                    background =  [UIImage imageNamed:@"3.png"];
                    break;
                case 3:
                    background =  [UIImage imageNamed:@"4.png"];
                    break;
                default:
                    break;
                
            }
            
            NSLog(@"Select ccc index was %d and the menu was %d", itemIndex, popupMenuName);
            UIGraphicsBeginImageContext(self.view.frame.size);
            [self->canvasImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            //self->canvasImageView.image = [self maskImage:self->canvasImageView.image withMask:background];
            self->canvasImageView.image = [self mergeImage:self.canvasImageView.image overImage:background inSize:CGSizeMake(self.view.frame.size.height, self.view.frame.size.width)];
            //self->canvasImageView.image = [UIImage imageNamed:@"back_disabled.png"];
            [self->canvasImageView setAlpha:opacity];
            UIGraphicsEndImageContext();
            [self updateImageStack];

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
    // Handles loader for choices from image library
    [self dismissViewControllerAnimated:YES completion:nil];
	canvasImageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Save chosen image as current top of stack
    [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    // Forces orientation to be landscape mode
    return UIInterfaceOrientationMaskAll;
}

-(UIImage *)addCircle:(UIImage *)img radius:(CGFloat)radius origin:(CGPoint)origin replace:(BOOL)replace
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,self.view.frame.size.height), NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, self.model.getRed, self.model.getGreen, self.model.getBlue, 1.0f);
    CGContextStrokeEllipseInRect(context, CGRectMake((origin.x+radius)*xRescale, (origin.y+radius)*yRescale, 2*radius*xRescale, 2*radius*yRescale));
    
    UIImage *tempShape = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tempShape;
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






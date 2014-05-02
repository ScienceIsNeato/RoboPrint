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

@interface ViewController ()

@end

@implementation ViewController
@synthesize yellowButton;
@synthesize redButton;
@synthesize pinkButton;
@synthesize blueButton;
@synthesize blackButton;
@synthesize greenButton;
@synthesize model;
@synthesize canvasImageView;
@synthesize lastImage;
@synthesize imageStack;
@synthesize backButton;
@synthesize forwardButton;
@synthesize popupMenuName;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize sub controller
    self.model = [[RoboPrintController alloc] init];
    
    // Declare colors as black
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 2.0;
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Loading Images"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}

- (IBAction)pencilSketchPressed:(id)sender
{
    // TODO
    // SEE HERE FOR INSTRUCTIONS FOR GETTING IMAGE FROM CAMERA
    // http://www.icodeblog.com/2009/07/28/getting-images-from-the-iphone-photo-library-or-camera-using-uiimagepickercontroller/
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Pencil Sketches"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}

-(IBAction)dispatchScenesMenu:(id)sender{
    
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

- (IBAction)textPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Adding Text"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}

- (IBAction)enlargePressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Enlarge 2X"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
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
    // Put the current state of the drawing on the stack
    // Assign current image to last image before making changes
    //[self.imageStack addObject:self.canvasImageView.image];
    /*if (self.canvasImageView.image != nil)
    {
        [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
    }*/
    
    
    // TODO - Confirm that start of touch is in canvas
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self->canvasImageView];
    lastPoint.x = lastPoint.x*(self.view.frame.size.width/self->canvasImageView.frame.size.width);
    lastPoint.y = lastPoint.y*(self.view.frame.size.height/self->canvasImageView.frame.size.height);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // TODO - Confirm that start of touch is in canvas
    
    mouseSwiped = YES; // Indicates that this is not a single point
    UITouch *touch = [touches anyObject];
    
    // Get current absolute location of touch event in the view
    CGPoint currentPoint = [touch locationInView:self->canvasImageView];
    
    // Scale the point so that it matches the height and width of the drawing canvas
    currentPoint.x = currentPoint.x*(self.view.frame.size.width/self->canvasImageView.frame.size.width);
    currentPoint.y = currentPoint.y*(self.view.frame.size.height/self->canvasImageView.frame.size.height);
    //NSLog(@"Origin x, y is: (%f, %f)", canvasOrigin.x, canvasOrigin.y);
    //NSLog(@"Point x, y is: (%f, %f)", currentPoint.x, currentPoint.y);
    //NSLog(@"Bounds are: (%f, %f)", self.view.frame.size.width, self.view.frame.size.height);

    UIGraphicsBeginImageContext(self.view.frame.size);
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
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touvhes ended");
    // Enable the back button

    
    // Ignore events that didn't create images and single points
    if (self.canvasImageView.image != nil && mouseSwiped)
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
                    shape =  [UIImage imageNamed:@"_circle.png"];
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
            UIGraphicsBeginImageContext(self.view.frame.size);
            [self->canvasImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            self->canvasImageView.image = [self maskImage:self->canvasImageView.image withMask:shape];
            //self->canvasImageView.image = [UIImage imageNamed:@"back_disabled.png"];
            [self->canvasImageView setAlpha:opacity];
            UIGraphicsEndImageContext();
            
            // Update image stack
            // Ignore events that didn't create images and single points
            if (self.canvasImageView.image != nil && mouseSwiped)
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
            self->canvasImageView.image = [self maskImage:self->canvasImageView.image withMask:background];
            //self->canvasImageView.image = [UIImage imageNamed:@"back_disabled.png"];
            [self->canvasImageView setAlpha:opacity];
            UIGraphicsEndImageContext();
            // Update image stack
            // Ignore events that didn't create images and single points
            if (self.canvasImageView.image != nil && mouseSwiped)
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

            break;
            
        default:
            break;
    }

    
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Handles loader for choices from image library
    [self dismissViewControllerAnimated:YES completion:nil];
	canvasImageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Save chosen image as current top of stack
    [self.imageStack insertObject:self.canvasImageView.image atIndex:0];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    // Forces orientation to be landscape mode
    return UIInterfaceOrientationMaskAll;
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






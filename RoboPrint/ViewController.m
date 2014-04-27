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



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.model = [[RoboPrintController alloc] init];
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 2.0;
    opacity = 1.0;
    model = [[RoboPrintController alloc] init];
    
    // TODO - replace this block with function call
    [self.yellowButton setImage:[UIImage imageNamed:@"color_selected_mask.png"]
                       forState:UIControlStateNormal];
    [self.redButton setImage:nil forState:UIControlStateNormal];
    [self.pinkButton setImage:nil forState:UIControlStateNormal];
    [self.blueButton setImage:nil forState:UIControlStateNormal];
    [self.blackButton setImage:nil forState:UIControlStateNormal];
    [self.greenButton setImage:nil forState:UIControlStateNormal];
    self.model.currentColor = YELLOW;
    // END TODO
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
    //NSLog(@"yellow button selected and prev color was %d", self.model.currentColor);
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
    
    model.menuName = @"scenes";
    av.delegate = model;
    
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
    
    model.menuName = @"shapes";
    av.delegate = model;
    
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
    [self.canvasImageView setImage:self.lastImage];
    /*UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Back Pressed"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];*/
}

- (IBAction)forwardPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Forward Pressed"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}

- (IBAction)startOverPressed:(id)sender
{
    self.canvasImageView.image = nil;
}

- (IBAction)openImagePressed:(id)sender
{
    // Initially, show an alert letting the user know
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Warning"
                                                message: @"Opening an image will erase this image. Continue?"
                                                delegate: self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Load Image",nil];

    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //NSLog(@"User decided to cancel Image Load");
    }
    else
    {
        // Clicked through warning. Load image.
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
	canvasImageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
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
    
    
   // [alert show];
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
    self.lastImage = self.canvasImageView.image;
    
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
    
    // Only called for a single point
    /*
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.canvasImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    */
    //UIGraphicsBeginImageContext(self.canvasImageView.frame.size);
    //[self.canvasImageView.image drawInRect:CGRectMake(0, 0, self.canvasImageView.frame.size.width, self.canvasImageView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    //self.canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //self.canvasImageView.image = nil;
    //UIGraphicsEndImageContext();
    //[self->canvasImageView setBackgroundColor:[UIColor greenColor]];
    //[self->canvasImageView setBackgroundColor:[UIColor blackColor]];
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

// test






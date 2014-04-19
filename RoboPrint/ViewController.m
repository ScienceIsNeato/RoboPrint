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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.model = [[RoboPrintController alloc] init];
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 1.0;
    opacity = 1.0;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)dispatchScenesMenu:(id)sender{
    
     NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"1.png"],
                       [UIImage imageNamed:@"2.png"],
                       [UIImage imageNamed:@"3.png"],
                       [UIImage imageNamed:@"4.png"],
                       nil];

    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:images];
    RoboPrintController *menuController = [[RoboPrintController alloc] init];
    
    menuController.menuName = @"scenes";
    av.delegate = menuController;

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
    RoboPrintController *menuController = [[RoboPrintController alloc] init];
    
    menuController.menuName = @"shapes";
    av.delegate = menuController;
    
    //av.highlightColor = [UIColor colorWithRed:66.0f/255.0f green:79.0f/255.0f blue:91.0f/255.0f alpha:1.0f];
    
    [av showInViewController:self center:CGPointMake(500, 500)];
    
}


- (IBAction)yellowButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor whiteColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
    //[self.yellowButton setImage:[UIImage imageNamed:@"yellowSelected.png"] forState:UIControlStateNormal];
    //NSLog(@"yellow button selected and prev color was %d", self.model.currentColor);
    self.model.currentColor = YELLOW;
}
- (IBAction)redButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor whiteColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
    self.model.currentColor = RED;
}
- (IBAction)pinkButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor whiteColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
    self.model.currentColor = PINK;
}
- (IBAction)blueButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor whiteColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
    self.model.currentColor = BLUE;
}
- (IBAction)blackButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor whiteColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
    self.model.currentColor = BLACK;
}
- (IBAction)greenButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor whiteColor];
    self.model.currentColor = GREEN;
}

- (IBAction)openImagePicker:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Loading Images"
                                                   message: @"Not Yet Implemented"
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self->tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self->tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self->tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self->tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self->tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self->mainImage.frame.size);
    [self->mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self->tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self->mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self->tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}


@end





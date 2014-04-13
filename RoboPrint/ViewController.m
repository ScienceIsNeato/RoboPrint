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

-(IBAction)redSelected:(id)sender{
    

    RoboPrintController *menuController = [[RoboPrintController alloc] init];
    NSLog(@"Select index was and the menu was %@", sender);
    
    
    
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
    //NSLog(@"yellow button selected");
}
- (IBAction)redButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor whiteColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
}
- (IBAction)pinkButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor whiteColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
}
- (IBAction)blueButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor whiteColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
}
- (IBAction)blackButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor whiteColor];
    self.greenButton.backgroundColor = [UIColor clearColor];
}
- (IBAction)greenButtonTouchUpInsideAction:(id)sender
{
    self.yellowButton.backgroundColor = [UIColor clearColor];
    self.redButton.backgroundColor = [UIColor clearColor];
    self.pinkButton.backgroundColor = [UIColor clearColor];
    self.blueButton.backgroundColor = [UIColor clearColor];
    self.blackButton.backgroundColor = [UIColor clearColor];
    self.greenButton.backgroundColor = [UIColor whiteColor];
}


@end





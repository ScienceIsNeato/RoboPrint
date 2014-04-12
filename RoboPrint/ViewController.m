//
//  ViewController.m
//  RoboPrint
//
//  Created by The Dude on 4/5/14.
//  Copyright (c) 2014 William Martin Engineering. All rights reserved.
//

#import "ViewController.h"
#import <RNGridMenu/RNGridMenu.h>

@interface ViewController ()

@end

@implementation ViewController

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


-(IBAction)showHelloWorld:(id)sender{
    
     NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"1.png"],
                       [UIImage imageNamed:@"2.png"],
                       [UIImage imageNamed:@"3.png"],
                       [UIImage imageNamed:@"4.png"],
                       nil];

   

    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:images];
    [av showInViewController:self center:CGPointMake(500, 500)];
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"hello World" message:@"Hi! from my First iPhone App" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

}


@end

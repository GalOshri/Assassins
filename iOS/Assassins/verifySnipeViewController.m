//
//  verifySnipeViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "verifySnipeViewController.h"

@interface verifySnipeViewController ()


@end

@implementation verifySnipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)ConfirmedSnipe:(id)sender {
}
- (IBAction)DeclinedSnipe:(id)sender {
}

@end

//
//  SnipeSubmitView.m
//  Assassins
//
//  Created by Gal Oshri on 7/24/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "SnipeSubmitView.h"

@interface SnipeSubmitView ()

@end

@implementation SnipeSubmitView

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
    
    self.snipeImageView.image = self.snipeImage;
    NSLog(@"WE AREHERE");
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

@end

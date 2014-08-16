//
//  CompletedImageViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/15/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "CompletedContractViewController.h"

@interface CompletedContractViewController ()

@end

@implementation CompletedContractViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.contractImage setImage: self.contract.image];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // set commentField
    if (![self.contract.comment isEqualToString:@""])
    {
        [self.contractComment setHidden:NO];
        [self.contractComment setText:self.contract.comment];
        self.contractComment.frame = CGRectMake(0,self.contract.commentYCoord, self.contractComment.frame.size.width, self.contractComment.frame.size.height);
    }
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

//
//  CSHowToController.m
//  camscram
//
//  Created by David Weber on 9/13/12.
//
//

#import "CSHowToController.h"
#import "UIViewController+ExtendedBehavior.h"
@interface CSHowToController ()

@end

@implementation CSHowToController

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
    
    self.step1.font = [UIFont fontWithName:@"Furore" size:14];
    self.step2.font = [UIFont fontWithName:@"Furore" size:14];
    self.step3.font = [UIFont fontWithName:@"Furore" size:14];

    [self obscure];
    [self fadeIn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

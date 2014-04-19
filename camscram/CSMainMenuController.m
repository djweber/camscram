//
//  CSMainMenuController.m
//  CamScram
//
//  Created by David Weber on 7/10/12.
//  Copyright (c) 2012 David Weber. All rights reserved.
//

#import "CSMainMenuController.h"
#import "CSSetupController.h"
#import "CSGameCenterManager.h"
#import "CSOptionsController.h"
#import "CSHowToController.h"
#import "QuartzCore/QuartzCore.h"
#import "UIViewController+ExtendedBehavior.h"

@implementation CSMainMenuController
@synthesize buttonPress;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString * soundLoc = [[NSBundle mainBundle] pathForResource:@"menu_tap" ofType:@"mp3"];
    
    NSURL * soundURL = [NSURL fileURLWithPath:soundLoc];
    
    NSError * error;
    
    currentDevice = [UIDevice currentDevice].model;
    
    CSGameCenterManager * sharedInstance = [CSGameCenterManager sharedInstance];
    [sharedInstance loadAchievements];
    
    self.buttonPress = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    self.buttonPress.delegate = (id)self;
    [self obscure];
    [self fadeIn];
}

- (IBAction)goToSetupView:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    
    CSSetupController * setupController;
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGFloat screenHeight = screenSize.size.height;

    
    if([currentDevice isEqualToString:@"iPad"])
    {
        setupController = [[CSSetupController alloc] initWithNibName:@"CSSetupController_iPad" bundle:[NSBundle mainBundle]];
    }
    else if(screenHeight == 568)
    {
        setupController = [[CSSetupController alloc] initWithNibName:@"CSSetupController_iPhone5" bundle:[NSBundle mainBundle]];
    }
    else
    {
        setupController = [[CSSetupController alloc] initWithNibName:@"CSSetupController" bundle:[NSBundle mainBundle]];
    }

    //Fade view out then push setup controller onto stack
    for(UIView * view in self.view.subviews)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0 
                            options:UIViewAnimationOptionTransitionNone 
                         animations:^(void){
                                             [view setAlpha:0.0];
                                           }
                         completion:^(BOOL finished) {
                                        if([self.view.subviews indexOfObject:view] == self.view.subviews.count - 1)
                                        {
                                            //If the last view is animated, push the view controller onto the stack
                                            [self.navigationController pushViewController:setupController animated:NO];
                                        }
        }];
    }
}

-(IBAction)goToOptionsView:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    CSOptionsController * optionsController;
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGFloat screenHeight = screenSize.size.height;
    
    if([currentDevice isEqualToString:@"iPad"])
    {
        optionsController = [[CSOptionsController alloc] initWithNibName:@"CSOptionsController_iPad" bundle:[NSBundle mainBundle]];
    }
    else if(screenHeight == 568)
    {
        optionsController = [[CSOptionsController alloc] initWithNibName:@"CSOptionsController_iPhone5" bundle:[NSBundle mainBundle]];
    }
    else
    {
        optionsController = [[CSOptionsController alloc] initWithNibName:@"CSOptionsController" bundle:[NSBundle mainBundle]];
    }
    
    //Fade view out then push setup controller onto stack
    for(UIView * view in self.view.subviews)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^(void){
                             [view setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             if([self.view.subviews indexOfObject:view] == self.view.subviews.count - 1)
                             {
                                 //If the last view is animated, push the view controller onto the stack
                                 [self.navigationController pushViewController:optionsController animated:NO];
                             }
                         }];
    }

}

-(IBAction)goToAwardsView:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
     }
    [self showAchievementsView];
}

- (void)showAchievementsView
{
    GKAchievementViewController * achievements = [[GKAchievementViewController alloc] init];
    if (achievements != nil)
    {
        achievements.achievementDelegate = self;
        [self presentViewController: achievements animated: YES completion:nil];
    }
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)goToHowToView:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    
    CSHowToController * howToController;
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGFloat screenHeight = screenSize.size.height;

    
    if([currentDevice isEqualToString:@"iPad"])
    {
        howToController = [[CSHowToController alloc] initWithNibName:@"CSHowToController_iPad" bundle:[NSBundle mainBundle]];
    }
    else if(screenHeight == 568)
    {
          howToController = [[CSHowToController alloc] initWithNibName:@"CSHowToController_iPhone5" bundle:[NSBundle mainBundle]];
    }
    else
    {
        howToController = [[CSHowToController alloc] initWithNibName:@"CSHowToController" bundle:[NSBundle mainBundle]];
    }
    

    //Fade view out then push setup controller onto stack
    for(UIView * view in self.view.subviews)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^(void){
                             [view setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             if([self.view.subviews indexOfObject:view] == self.view.subviews.count - 1)
                             {
                                 //If the last view is animated, push the view controller onto the stack
                                 [self.navigationController pushViewController:howToController animated:NO];
                             }
                         }];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

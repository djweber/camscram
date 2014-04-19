//
//  CS_OptionsController.m
//  camscram
//
//  Created by David Weber on 8/16/12.
//
//

#import "CSOptionsController.h"
#import "UIViewController+ExtendedBehavior.h"

@interface CSOptionsController ()

@end

@implementation CSOptionsController
@synthesize soundToggle;
- (IBAction)resetAchievements:(id)sender
{
    UIActionSheet * confirm = [[UIActionSheet alloc] initWithTitle:@"Reset Achievements?" delegate:(id)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil, nil];
    
    NSString * device = [UIDevice currentDevice].model;
    
    if([device isEqualToString:@"iPhone"])
    {
        [confirm showFromRect:[self.view frame] inView:self.view animated:YES];
    }
    else
    {
        [confirm showFromRect:[sender frame] inView:self.view animated:YES];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        // Clear all locally saved achievement objects.
        CSGameCenterManager * sharedInstance = [CSGameCenterManager sharedInstance];
        sharedInstance.achievementsDictionary = [[NSMutableDictionary alloc] init];
        // Clear all progress saved on Game Center.
        [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"%@",error);
             }
         }];
        
        [sharedInstance loadAchievements];
    }
}

-(IBAction)toggleSound:(id)sender
{
    NSNumber * soundOn = [[NSUserDefaults standardUserDefaults] valueForKey:@"use_sounds"];
        
    soundOn = ([soundOn boolValue] == FALSE)? [NSNumber numberWithBool:TRUE] : [NSNumber numberWithBool:FALSE];
    
    NSString * buttonText = ([soundOn boolValue] == TRUE)? @"Sounds: On" : @"Sounds: Off";
    
    [sender setTitle:buttonText forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] setValue:soundOn forKey:@"use_sounds"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
    [self obscure];
    [self fadeIn];
    
    NSNumber * soundOn = [[NSUserDefaults standardUserDefaults] valueForKey:@"use_sounds"];
        
    NSString * buttonText = ([soundOn boolValue] == TRUE)? @"Sounds: On" : @"Sounds: Off";
    
    [soundToggle setTitle:buttonText forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

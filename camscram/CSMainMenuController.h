//
//  CSMainMenuController.h
//  CamScram
//
//  Created by David Weber on 7/10/12.
//  Copyright (c) 2012 David J. Weber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <GameKit/GameKit.h>
@interface CSMainMenuController : UIViewController <GKAchievementViewControllerDelegate>
{
    NSString * currentDevice;
}
@property (nonatomic, retain) AVAudioPlayer * buttonPress;
-(IBAction)goToSetupView:(id)sender;
-(IBAction)goToOptionsView:(id)sender;
-(IBAction)goToAwardsView:(id)sender;
-(IBAction)goToHowToView:(id)sender;
@end

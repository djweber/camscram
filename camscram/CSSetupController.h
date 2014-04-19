//
//  CS_SetupController.h
//  camscram
//
//  Created by David Weber on 7/10/12.
//  Copyright (c) David J. Weber. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Quartzcore/Quartzcore.h>
#import <AVFoundation/AVFoundation.h>
@class CSMainMenuController;
@class CSGameController;

@interface CSSetupController : UIViewController <UIPopoverControllerDelegate>
{
    int diffCounter;
    int timerCounter;
    int rotationCounter;
    BOOL useCamera;
    BOOL timerOn;
    BOOL rotationOn;
    int gridSize;
    UIImage * theImage;
    NSString * currentDevice;
}
@property (nonatomic, strong) UIPopoverController * popover;
@property (nonatomic, retain) AVAudioPlayer * buttonPress;
@property (nonatomic, retain) IBOutlet UIButton * dButton;
@property (nonatomic, retain) IBOutlet UIButton * tButton;
@property (nonatomic, retain) IBOutlet UIButton * rButton;
@property (nonatomic, retain) IBOutlet UIButton * backButton;
@property (nonatomic, retain) IBOutlet UIView * step1View;
@property (nonatomic, retain) IBOutlet UIView * step2View;
@property (nonatomic, retain) IBOutlet UILabel * step1Label;
@property (nonatomic, retain) IBOutlet UILabel * step2Label;
@property (nonatomic, retain) IBOutlet UIButton * difficultyButton;
@property (nonatomic, retain) IBOutlet UIButton * timerButton;
@property (nonatomic, retain) IBOutlet UIButton * rotationButton;
@property (nonatomic, retain) IBOutlet UIButton * startButton;
@property (nonatomic, retain) IBOutlet UIView * difficultyPane;
@property (nonatomic, retain) IBOutlet UIImageView * previewPane;
@property (nonatomic, retain) IBOutlet UIImageView * difficultyGrid;
-(IBAction)startGame:(id)sender;
-(IBAction)useCameraPressed:(id)sender;
-(IBAction)useCameraRollPressed:(id)sender;
-(IBAction)undo:(id)sender;
-(IBAction)difficultyButtonPressed:(id)sender;
-(IBAction)timerButtonPressed:(id)sender;
-(IBAction)rotationButtonPressed:(id)sender;
-(void)chooseImage:(id)sender;
@end
    
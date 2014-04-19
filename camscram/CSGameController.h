//
//  CS_GameController.h
//  camscram
//
//  Created by David Weber on 8/15/12.
//
//

#import <UIKit/UIKit.h>
#import "UIViewController+ExtendedBehavior.h"
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import "CSGameCenterManager.h"
#import <AVFoundation/AVFoundation.h>
@class CSTile;
@interface CSGameController : UIViewController
{
    int countdownVal;
}
@property int gridSize;
@property (nonatomic, retain) AVAudioPlayer * player;
@property BOOL timerOn;
@property BOOL timerPaused;
@property BOOL rotationOn;
@property int seconds;
@property CSGameCenterManager * gcManager;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) NSTimer * timer;
@property (nonatomic, retain) IBOutlet UILabel * timerLabel;
@property CGRect box;
@property CGImageRef imageRef;
@property UIView * pauseScreen;
@property UIView * winScreen;
@property UIView * countdownScreen;
@property NSTimer * countdown;
@property IBOutlet UIButton * pauseButton;
@property UIView * loseScreen;
@property UILabel * countdownTimer;
@property UIButton * exitButton;
@property UIButton * resumeButton;
@property UIImage * theNewImage;
@property UIImage * resizedImage;
@property NSMutableArray * tiles;
@property IBOutlet UIView * gameBoard;
@property BOOL swapped;
-(void)generateTileArray:(UIImage *)image;
-(void)rotateGameView: (NSNotification *) notif;
-(void)shuffleAndPlace:(NSArray *)tileArray;
-(void)setSeconds;
-(void)updateTimer;
-(IBAction)quitGame:(id)sender;
-(IBAction)gameWon;
-(IBAction)gameOver;
-(IBAction)pause:(id)sender;
-(IBAction)resume:(id)sender;
-(id)initWithImage:(UIImage *)image gridSize:(int)gridSize andTimerOn:(BOOL)timer andRotationOn:(BOOL)rotation;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)img gridSize:(int)gSize andTimerOn:(BOOL)t andRotationOn:(BOOL)r;
@end

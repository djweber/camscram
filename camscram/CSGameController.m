//
//  CS_GameController.m
//  camscram
//
//  Created by David Weber on 8/15/12.
//
//
 
#import "UIViewController+ExtendedBehavior.h"
#import "CSGameController.h"
#import "CSTile.h"
@interface CSGameController ()

@end

@implementation CSGameController
@synthesize image,
        gcManager,
       timerLabel,
         gridSize,
      pauseButton,
          timerOn,
       rotationOn,
            timer,
              box,
         imageRef,
      pauseScreen,
      theNewImage,
           player,
        countdown,
  countdownScreen,
    countdownTimer,
     resizedImage,
     resumeButton,
          swapped,
            tiles,
       exitButton,
          seconds,
        timerPaused,
        winScreen,
        loseScreen,
        gameBoard;

#pragma mark - Game operation

-(id)initWithImage:(UIImage *)img gridSize:(int)g andTimerOn:(BOOL)t andRotationOn:(BOOL)r
{
    self = [super init];
    if (self) {
        image = img;
        gridSize = g;
        timerOn = t;
        rotationOn = r;
    
        self.player.delegate = (id)self;
        
       
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)img gridSize:(int)gSize andTimerOn:(BOOL)t andRotationOn:(BOOL)r
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        image = img;
        gridSize = gSize;
        timerOn = t;
        rotationOn = r;
    }
    return self;
}

-(void)generateTileArray:(UIImage *)img
{
    tiles = [[NSMutableArray alloc] init];
    
    //Adjust context of image
    UIGraphicsBeginImageContext(img.size);
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    int tileSize = ceilf(img.size.height/gridSize);
        
    //Generate tiles
    for(int i = 0; i < gridSize;i++)
    {        
        for(int j = 0; j < gridSize;j++){
            
            //ADD LOGIC TO IDENTIFY BOUNDARY TILES
            box = CGRectMake(j*tileSize, i*tileSize, tileSize, tileSize);
            imageRef = CGImageCreateWithImageInRect(img.CGImage, box);
            theNewImage = [UIImage imageWithCGImage:imageRef];
            CSTile * tile = [[CSTile alloc] initWithFrame:box];
            [tile setUserInteractionEnabled:YES];
            [tile setImage:theNewImage];
            [tile setController:self];
            [tiles addObject:tile];
            theNewImage = nil;
            [self.gameBoard addSubview:tile];
        }
    }
    
    //Use GCD to delay swap/animation
    //double delay = 1.0;
    //dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    //dispatch_after(time, dispatch_get_main_queue(), ^(void){
        for(int i = 0; i < 10; i++)
        {
            [self shuffleAndPlace:tiles];
        }
    //});
}

-(void)shuffleAndPlace:(NSArray *)tileArray
{
    int randomIndex;
    int randomRotation;
    
    NSMutableArray * randomNumbers = [[NSMutableArray alloc] initWithCapacity:[tileArray count]];
    
    //Fisher-Yates shuffle
    for(int i = 0; i < [tileArray count]; i++)
    {
        [randomNumbers addObject:[NSNumber numberWithInt:i]];
    }
    
    for(int i = [tileArray count]-1; i > 1; --i)
    {
        int randomNumber = arc4random() % [tileArray count];
        [randomNumbers exchangeObjectAtIndex:i withObjectAtIndex:randomNumber];
    }
    
    for(CSTile * tile in tileArray)
    {
        randomRotation = arc4random() % 3;
        randomIndex = [[randomNumbers objectAtIndex:[tileArray indexOfObject:tile]] intValue];
        CSTile * t = [tileArray objectAtIndex:randomIndex];
        
        if(!CGPointEqualToPoint(tile.currentPosition,t.currentPosition))
        {
            [tile swapWith:[tileArray objectAtIndex:randomIndex] isInitial:YES];
        }
        
        if(rotationOn == TRUE)
        {
            [tile rotateTile:randomRotation];
        }
    }
}

-(IBAction)pause:(id)sender
{
    self.timerPaused = YES;
            
    [self.gameBoard addSubview:pauseScreen];
    
    [self.exitButton setHidden: NO];
    [self.gameBoard addSubview:exitButton];

    [self.resumeButton setHidden: NO];
    [self.gameBoard addSubview:resumeButton];
}
-(IBAction)resume:(id)sender
{
    self.timerPaused = NO;
    [self.exitButton removeFromSuperview];
    [self.resumeButton removeFromSuperview];
    [self.pauseScreen removeFromSuperview];
}

#pragma mark - ViewController delegate/setup methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)quitGame:(id)sender
{
    //Fade out subviews one by one in view
    for(UIView * view in self.view.subviews)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^(void){
                             [view setAlpha:0.0];
                         }
                         completion:nil];
    }
    
    //Use GCD to delay transition
    double delay = 0.5;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [[self.navigationController.viewControllers objectAtIndex:0] fadeIn];
        [self.navigationController popToRootViewControllerAnimated:NO];
    });

}

-(IBAction)gameWon
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        NSString * soundLoc = [[NSBundle mainBundle] pathForResource:@"win" ofType:@"mp3"];
        NSURL * soundURL = [NSURL fileURLWithPath:soundLoc];
        NSError * error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        [self.player play];
    }
    [timer invalidate];
    [self checkForAchievements];
    self.timerPaused = YES;
    [self.gameBoard addSubview:winScreen];
    [self.exitButton setHidden: NO];
    [self.gameBoard addSubview:exitButton];
}

//Method to check for achievements
-(void)checkForAchievements
{
    NSString * identifier;
    NSMutableDictionary * achievements = gcManager.achievementsDictionary;
    NSLog(@"Achievements count: %i",achievements.count);
    
    //4x4 no rotation/no time attack
    if(gridSize == 4 && timerOn == NO && rotationOn == NO)
    {
        identifier = @"1";
        
        GKAchievement * achievement = [achievements
 objectForKey:identifier];
        if(achievement != NULL)
        {
            NSLog(@"Achievement 1 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 1 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"5"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"5" percentComplete:ach.percentComplete];
        }
    }
    //4x4 rotation/no time attack
    if(gridSize == 4 && timerOn == NO && rotationOn == YES)
    {
        identifier = @"2";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)

        {
            NSLog(@"Achievement 2 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 2 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"5"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"5" percentComplete:ach.percentComplete];
        }
    }
    //4x4 no rotation/time attack
    if(gridSize == 4 && timerOn == YES && rotationOn == NO)
    {
        identifier = @"3";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)

        {
            NSLog(@"Achievement 3 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 3 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"5"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"5" percentComplete:ach.percentComplete];
        }
    }
    //4x4 rotation/time attack
    if(gridSize == 4 && timerOn == YES && rotationOn == YES)
    {
        identifier = @"4";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
 
        {
            NSLog(@"Achievement 4 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 4 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"5"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"5" percentComplete:ach.percentComplete];
        }
    }
    //8x8 no rotation/no time attack
    if(gridSize == 8 && timerOn == NO && rotationOn == NO)
    {
        identifier = @"6";
        
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
        {
            NSLog(@"Achievement 6 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 6 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"10"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"10" percentComplete:ach.percentComplete];
        }
    }
    //8x8 rotation/no time attack
    if(gridSize == 8 && timerOn == NO && rotationOn == YES)
    {
        identifier = @"7";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
            
        {
            NSLog(@"Achievement 7 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 7 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"10"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"10" percentComplete:ach.percentComplete];
        }
    }
    //8x8 no rotation/time attack
    if(gridSize == 8 && timerOn == YES && rotationOn == NO)
    {
        identifier = @"8";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
            
        {
            NSLog(@"Achievement 8 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 8 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"10"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"10" percentComplete:ach.percentComplete];
        }
    }
    //8x8 rotation/time attack
    if(gridSize == 8 && timerOn == YES && rotationOn == YES)
    {
        identifier = @"9";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
            
        {
            NSLog(@"Achievement 9 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 9 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"10"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"10" percentComplete:ach.percentComplete];
        }
    }
    //10x10 no rotation/no time attack
    if(gridSize == 10 && timerOn == NO && rotationOn == NO)
    {
        identifier = @"11";
        
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
        {
            NSLog(@"Achievement 11 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 11 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"15"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"15" percentComplete:ach.percentComplete];
        }
    }
    //10x10 rotation/no time attack
    if(gridSize == 10 && timerOn == NO && rotationOn == YES)
    {
        identifier = @"12";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
            
        {
            NSLog(@"Achievement 12 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 12 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"15"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"15" percentComplete:ach.percentComplete];
        }
    }
    //10x10 no rotation/time attack
    if(gridSize == 10 && timerOn == YES && rotationOn == NO)
    {
        identifier = @"13";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
            
        {
            NSLog(@"Achievement 13 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 13 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"15"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"15" percentComplete:ach.percentComplete];
        }
    }
    //10x10 rotation/time attack
    if(gridSize == 10 && timerOn == YES && rotationOn == YES)
    {
        identifier = @"14";
        GKAchievement * achievement = [achievements
                                       objectForKey:identifier];
        if(achievement != NULL)
            
        {
            NSLog(@"Achievement 14 already unlocked");
        }
        else
        {
            [gcManager reportAchievementIdentifier:identifier percentComplete:100.0];
            NSLog(@"Achievement 14 unlocked!");
            //Modify percentage for 4x4 master
            GKAchievement * ach = [gcManager getAchievementForIdentifier:@"15"];
            ach.percentComplete = ach.percentComplete + 25.0;
            NSLog(@"%f", ach.percentComplete);
            [gcManager reportAchievementIdentifier:@"15" percentComplete:ach.percentComplete];
        }
    }
}

-(IBAction)gameOver
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        NSString * soundLoc = [[NSBundle mainBundle] pathForResource:@"fail" ofType:@"mp3"];
        NSURL * soundURL = [NSURL fileURLWithPath:soundLoc];
        NSError * error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        [self.player play];
    }
     self.timerPaused = YES;
    [self.gameBoard addSubview:loseScreen];
    [self.exitButton setHidden: NO];
    [self.gameBoard addSubview:exitButton];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    countdownVal = 3;
    
    //Set seconds based on grid size + game settings
    [self setSeconds];
    
    gcManager = [CSGameCenterManager sharedInstance];
    
    [gcManager loadAchievements];

    //Create pause screen and buttons
    CGRect rect = CGRectMake(0.0, 0.0, self.gameBoard.frame.size.width, self.gameBoard.frame.size.height);
   
    pauseScreen = [[UIView alloc] initWithFrame:rect];
    [pauseScreen setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
    
    winScreen = [[UIView alloc] initWithFrame:rect];
    [winScreen setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
    UIImage * winImage = [UIImage imageNamed:@"win.png"];
    UIImageView * winPic = [[UIImageView alloc] initWithImage:winImage];
    [winPic setContentMode:UIViewContentModeScaleAspectFill];
    [winPic setFrame:CGRectMake(self.gameBoard.frame.size.width/2 - winImage.size.width/2, self.gameBoard.frame.size.height/4, winImage.size.width, winImage.size.height)];
    [winScreen addSubview:winPic];

    loseScreen = [[UIView alloc] initWithFrame:rect];
    [loseScreen setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
    UIImage * lossImage = [UIImage imageNamed:@"fail.png"];
    UIImageView * losePic = [[UIImageView alloc] initWithImage:lossImage];
    [losePic setFrame:CGRectMake(self.gameBoard.frame.size.width/2 - lossImage.size.width/2, self.gameBoard.frame.size.height/4, lossImage.size.width, lossImage.size.height)];
    [losePic setContentMode:UIViewContentModeScaleAspectFill];
    [loseScreen addSubview:losePic];

    exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [exitButton setFrame:CGRectMake(0.0, self.gameBoard.frame.size.height/2, self.view.frame.size.width, 50.0)];
    [exitButton.titleLabel setContentMode:UIViewContentModeCenter];
    [exitButton setTitle:@"Main Menu" forState:UIControlStateNormal];
    self.exitButton.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.exitButton.layer.shadowRadius = 15.0f;
    self.exitButton.layer.shadowOpacity = 1.0;
    self.exitButton.layer.shadowOffset = CGSizeZero;
    self.exitButton.layer.masksToBounds = NO;
    [exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitButton.titleLabel setFont:[UIFont fontWithName:@"Furore" size:24]];
    [exitButton addTarget:self action:@selector(quitGame:) forControlEvents:UIControlEventTouchUpInside];
    [exitButton setHidden:YES];
    
    UIImage * pauseImage = [UIImage imageNamed:@"pause_screen.png"];
    UIImageView * pausePic = [[UIImageView alloc] initWithImage:pauseImage];
    [pausePic setFrame:CGRectMake(self.gameBoard.frame.size.width/2 - lossImage.size.width/2, self.gameBoard.frame.size.height/4, lossImage.size.width, lossImage.size.height)];
    [pausePic setContentMode:UIViewContentModeScaleAspectFill];
    [pauseScreen addSubview:pausePic];

    resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resumeButton setFrame:CGRectMake(0.0, (self.gameBoard.frame.size.height/2) + 70, self.view.frame.size.width, 50.0)];
    [resumeButton.titleLabel setContentMode:UIViewContentModeCenter];
    [resumeButton setTitle:@"Resume" forState:UIControlStateNormal];
    [resumeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resumeButton.titleLabel setFont:[UIFont fontWithName:@"Furore" size:24]];
    [resumeButton addTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
    [resumeButton setHidden:YES];
    self.resumeButton.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.resumeButton.layer.shadowRadius = 15.0f;
    self.resumeButton.layer.shadowOpacity = 1.0;
    self.resumeButton.layer.shadowOffset = CGSizeZero;
    self.resumeButton.layer.masksToBounds = NO;
    
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    //Set up view controller to listen for coming back from the background
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rotateGameView:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self obscure];
    [self fadeIn];
    countdownScreen = [[UIView alloc] initWithFrame:rect];
    [countdownScreen setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
    countdownTimer = [[UILabel alloc] init];
    [countdownTimer setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    [countdownTimer setFrame:CGRectMake(0.0, self.gameBoard.frame.size.height/2-40, self.view.frame.size.width, 50.0)];
    [countdownTimer setTextAlignment:NSTextAlignmentCenter];
    [countdownTimer setTextColor:[UIColor whiteColor]];
    [countdownTimer setFont:[UIFont fontWithName:@"Furore" size:48]];
    [countdownTimer setText:[NSString stringWithFormat:@"%i",countdownVal]];
    self.countdownTimer.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.countdownTimer.layer.shadowRadius = 15.0f;
    self.countdownTimer.layer.shadowOpacity = 1.0;
    self.countdownTimer.layer.shadowOffset = CGSizeZero;
    self.countdownTimer.layer.masksToBounds = NO;
    [countdownScreen addSubview:countdownTimer];
    [self.gameBoard addSubview:countdownScreen];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        NSString * soundLoc = [[NSBundle mainBundle] pathForResource:@"menu_tone" ofType:@"mp3"];
        NSURL * soundURL = [NSURL fileURLWithPath:soundLoc];
        NSError * error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        [self.player play];
    }
    
    countdown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    



}
-(void)countDown
{
    if(self.timerPaused != YES)
    {
    if(countdownVal == 1)
    {
        [countdown invalidate];
        
        [UIView animateWithDuration:2.0 animations:^{
            countdownScreen.alpha = 0;
        } completion:^(BOOL finished) {
            [countdownScreen removeFromSuperview];
        }];
        
        [self generateTileArray:image];
        if(timerOn != FALSE)
        {
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
            
            self.timerLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.timerLabel.layer.shadowRadius = 15.0f;
            self.timerLabel.layer.shadowOpacity = 1.0;
            self.timerLabel.layer.shadowOffset = CGSizeZero;
            self.timerLabel.layer.masksToBounds = NO;
            
            if([[UIDevice currentDevice].model isEqualToString:@"iPad"])
            {
                NSLog(@"Setting font for iPad!!");
                [self.timerLabel setFont: [UIFont fontWithName:@"Furore" size:48]];
                NSLog(@"%@", timerLabel.font);
            }
            else
            {
                NSLog(@"Setting font for iPhone!");
                [self.timerLabel setFont: [UIFont fontWithName:@"Furore" size:24]];
                NSLog(@"%@", timerLabel.font);
            }
        }
        return;
    }

    countdownVal--;
   
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        NSString * soundLoc = [[NSBundle mainBundle] pathForResource:@"menu_tone" ofType:@"mp3"];
        NSURL * soundURL = [NSURL fileURLWithPath:soundLoc];
        NSError * error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        [self.player play];
    } 

    [countdownTimer setText:[NSString stringWithFormat:@"%i",countdownVal]];
    }
}

-(void)setSeconds
{
    //4x4 with no rotation = 30 seconds
    //4x4 with rotation = 1 minute
    
    //8x8 with no rotation = 5 minutes
    //8x8 with rotation = 10 minutes
    
    //10x10 with no rotation = 15 minutes
    //10x10 with no rotation = 20 minutes
    
    switch(gridSize)
    {
        case(4):
            seconds = (rotationOn == NO)? 30 : 60;
            break;
        case(8):
            seconds = (rotationOn == NO)? 300 : 600;
            break;
        case(10):
            seconds = (rotationOn == NO)? 900 : 1200;
            break;
        default: break;
    }

}

-(void)updateTimer
{
    int min = floorf(seconds/60.0);
    int rem = seconds % 60;
    int sec = rem % 60;
    //NSLog(@"%i", min);
    //NSLog(@"%i", sec);
    if(sec >= 10)
    {
        timerLabel.text = [NSString stringWithFormat:@"%i:%i", min, sec];
    }
    else
    {
        timerLabel.text = [NSString stringWithFormat:@"%i:0%i", min, sec];
    }
    if(timerPaused == FALSE)
    {
        seconds--;
    }
    if(seconds <= 15)
    {
        timerLabel.textColor = [UIColor redColor];
        self.timerLabel.layer.shadowColor = [[UIColor redColor] CGColor];
    }
    if(seconds < 1)
    {
        timerLabel.text = [NSString stringWithFormat:@"0:00"];
        [timer invalidate];
        [self gameOver];
    }
}

-(void)rotateGameView: (NSNotification *) notif
{
    UIDeviceOrientation ori = [[notif object] orientation];
    
    CGAffineTransform theTransform;
    
    switch(ori)
    {
        case UIDeviceOrientationPortrait:
            theTransform = CGAffineTransformMakeRotation(0);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            theTransform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationLandscapeLeft:
            theTransform = CGAffineTransformMakeRotation(M_PI/2);
            break;
        case UIDeviceOrientationLandscapeRight:
            theTransform = CGAffineTransformMakeRotation(-M_PI/2);
            break;
        case UIDeviceOrientationFaceUp:
            theTransform = CGAffineTransformMakeRotation(0);
            break;
        case UIDeviceOrientationFaceDown:
            theTransform = CGAffineTransformMakeRotation(0);
        case UIDeviceOrientationUnknown:
            theTransform = CGAffineTransformMakeRotation(0);
            break;

        default:
            break;
    }
    
    [UIView animateWithDuration:1.0 animations:^{
        self.gameBoard.transform = theTransform;
    } completion:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

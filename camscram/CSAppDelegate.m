//
//  CS_AppDelegate.m
//  camscram
//
//  Created by David Weber on 7/10/12.
//  Copyright (c) David J. Weber. All rights reserved.
//

#import "CSAppDelegate.h"
#import "CSMainMenuController.h"

@implementation CSAppDelegate

@synthesize window = _window;
@synthesize navController;
@synthesize mainMenuController = _viewController;
@synthesize gameCenterAvailable;
@synthesize scrollView;
 -(void)isGameCenterAPIAvailable;
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    gameCenterAvailable = (gcClass && osVersionSupported);
}

//Method to authenticate the player
- (void)authenticateLocalPlayer
{
    GKLocalPlayer * localPlayer = [GKLocalPlayer localPlayer];
    
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if(error != nil)
        {
            NSLog(@"%@", error);
        }
        if(localPlayer.authenticated)
        {
            NSLog(@"Authenticated");
        }
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSString * device = [UIDevice currentDevice].model;
   
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGFloat screenHeight = screenSize.size.height;
    
    //Is an iPad/iPad simulator
    if([device hasPrefix:@"iPad"])
    {
        self.mainMenuController = [[CSMainMenuController alloc] initWithNibName:@"CSMainMenuController_iPad" bundle:[NSBundle mainBundle]];
    }
    
    //Is an iPhone 5
    else if(screenHeight == 568)
    {
        self.mainMenuController = [[CSMainMenuController alloc] initWithNibName:@"CSMainMenuController_iPhone5" bundle:[NSBundle mainBundle]];
    }
    //Is an older iPhone/iPod touch
    else
    {
        self.mainMenuController = [[CSMainMenuController alloc] initWithNibName:@"CSMainMenuController" bundle:[NSBundle mainBundle]];
    }
    
    //Make navigation controller's root controller the menu
    navController = [[UINavigationController alloc] initWithRootViewController:self.mainMenuController];
    [navController setNavigationBarHidden:YES];
    
    [[AVAudioSession sharedInstance] setCategory:@"AVAudioSessionCategoryAmbient" error:nil];
    
    //Initialize application options
    [CSAppDelegate initializeOptions];
    
    //Set app window's root view controller as navigation controller
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    [self startGridScroll];
    
    [self isGameCenterAPIAvailable];
    
    if(gameCenterAvailable)
    {
        [self authenticateLocalPlayer];        
    }
    return YES;
}

+(void)initializeOptions
{
    //Set up user defaults if they don't exist already
    NSUserDefaults * defaultOptions = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * pendingAchievements = [[NSMutableDictionary alloc] init];
    
    NSDictionary * defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:TRUE], @"use_sounds", pendingAchievements, @"pending_achievements",nil];

    [defaultOptions registerDefaults:defaults];
    [defaultOptions synchronize];
}

-(void)startGridScroll
{
    if(scrollView != nil)
    {
        [scrollView removeFromSuperview];
    }
    
    //Create layer and pattern it with the grid image as a color
    UIImage * gridImage = [UIImage imageNamed:@"scrolling_grid.png"];
    UIColor * gridPattern = [UIColor colorWithPatternImage:gridImage];
    CALayer * gridLayer = [CALayer layer];
    [gridLayer setZPosition:-1];
    gridLayer.backgroundColor = gridPattern.CGColor;
    
    //Transform the image on its Y-axis
    gridLayer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0);
    gridLayer.anchorPoint = CGPointMake(0.0,1.0);
    CGSize scrollSize = self.window.bounds.size;
    
    //Make the layer's frame twice the width of the image
    gridLayer.frame = CGRectMake(0.0, 0.0, gridImage.size.width + scrollSize.width, scrollSize.height);
    scrollView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.window.frame.size.width, self.window.frame.size.height)];
    [scrollView.layer addSublayer:gridLayer];
    [scrollView.layer setZPosition:-1];
    [self.window addSubview:scrollView];
    [self.window sendSubviewToBack:scrollView];
    //Define start position and end coordinates for grid image
    CGPoint start = CGPointZero;
    CGPoint end = CGPointMake(-gridImage.size.width, 0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGPoint:start];
    animation.toValue = [NSValue valueWithCGPoint:end];
    animation.repeatCount = HUGE_VALF;
    
    //Set animation duration and begin
    animation.duration = 7.0;
    [gridLayer addAnimation:animation forKey:@"position"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //Called when the application becomes active after coming back from the background
    [self startGridScroll];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

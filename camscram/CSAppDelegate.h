//
//  CS_AppDelegate.h
//  camscram
//
//  Created by David Weber on 7/10/12.
//  Copyright (c) 2012 David J. Weber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CSGameCenterManager.h"
@class CSMainMenuController;
@interface CSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CSMainMenuController *mainMenuController;
@property (strong, nonatomic) UINavigationController * navController;
@property (strong, nonatomic) UIView * scrollView;
@property BOOL gameCenterAvailable;
+(void)initializeOptions;
-(void)isGameCenterAPIAvailable;
-(void)startGridScroll;
-(void)authenticateLocalPlayer;
@end

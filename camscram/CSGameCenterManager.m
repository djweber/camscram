//
//  CSAchievements.m
//  camscram
//
//  Created by David Weber on 9/22/12.
//
//

#import "CSGameCenterManager.h"

@implementation CSGameCenterManager

static CSGameCenterManager * sharedInstance = nil;

@synthesize achievementsDictionary;

+ (CSGameCenterManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

//Method to load currently completed achievements for player
- (void) loadAchievements
{
    achievementsDictionary = [[NSMutableDictionary alloc] init];
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error == nil)
         {
             for (GKAchievement * achievement in achievements)
             {
                 [achievementsDictionary setObject: achievement forKey: achievement.identifier];
             }
             NSLog(@"Count: %i", achievementsDictionary.count);
             if(achievementsDictionary.count == 15)
             {
                 GKAchievement * ach = [self getAchievementForIdentifier:@"16"];
                 ach.percentComplete = 100.0;
                 NSLog(@"%f", ach.percentComplete);
                 [self reportAchievementIdentifier:@"16" percentComplete:ach.percentComplete];
             }

         }
    }];
}

//Method returns achievement by using identifer
- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier
{
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        achievement.showsCompletionBanner = YES;
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }
    return achievement;
}


//Method to report completed achievements to Game Center
- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if (achievement)
    {
        achievement.percentComplete = percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 // Log the error.
             }
         }];
    }
}

@end

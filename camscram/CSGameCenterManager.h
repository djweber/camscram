//
//  CSAchievements.h
//  camscram
//
//  Created by David Weber on 9/22/12.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
@interface CSGameCenterManager : NSObject
@property (nonatomic, retain) NSMutableDictionary * achievementsDictionary;
+(id)sharedInstance;
-(void)loadAchievements;
-(void)reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;
-(GKAchievement*)getAchievementForIdentifier: (NSString*)identifier;
@end

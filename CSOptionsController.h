//
//  CS_OptionsController.h
//  camscram
//
//  Created by David Weber on 8/16/12.
//
//

#import <UIKit/UIKit.h>
#import "CSGameCenterManager.h"
#import "CSGameCenterManager.h"
@interface CSOptionsController : UIViewController <UIActionSheetDelegate>
@property (nonatomic, retain) IBOutlet UIButton * soundToggle;
-(IBAction)resetAchievements:(id)sender;
-(IBAction)toggleSound:(id)sender;
@end

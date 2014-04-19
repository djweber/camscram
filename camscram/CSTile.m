//
//  CS_Tile.m
//  camscram
//
//  Created by David Weber on 8/16/12.
//
//

#import "CSTile.h"
#import "QuartzCore/QuartzCore.h"
#import "CSGameController.h"

@implementation CSTile
@synthesize targetTile;
@synthesize boundaryMask;
@synthesize controller;
@synthesize homePosition;
@synthesize currentPosition;
@synthesize rotation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setRotation:0];
        [self setHomePosition:self.center];
        [self setCurrentPosition:self.center];
    }
    return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.center = [[touches anyObject] locationInView:self.superview];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.controller.gameBoard bringSubviewToFront:self];
    UIColor * color = [UIColor whiteColor];
    self.layer.shadowColor = [color CGColor];
    self.layer.shadowRadius = 15.0f;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.masksToBounds = NO;
}

-(void)rotateTile:(int)rotValue
{
    int r = rotValue;
   
    //Get current angle and rotate 90 degrees
    //CGFloat currentAngle = atan2f(self.transform.b,self.transform.a);
    //NSLog(@"%f", currentAngle*(180/M_PI));
    
    CGFloat newAngle = r * 90.0*(M_PI/180);
    
    self.transform = CGAffineTransformMakeRotation(newAngle);
    if(r > 3)
    {
        r = 0;
    }
    [self setRotation:r];

    //NSLog(@"Rotation: %i", self.rotation);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[touches anyObject] tapCount] == 1)
    {
        if(controller.rotationOn == TRUE)
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                [self rotateTile:self.rotation + 1];
                                [self checkForComplete];
                             }
            completion:nil
         ];
        }
    }
    //Look to see if the current tile is within range of a target
    for(CSTile * tile in controller.tiles)
        if(CGPointEqualToPoint(self.currentPosition, tile.currentPosition) == FALSE && CGRectContainsPoint(tile.frame, self.center))
        {
            self.targetTile = tile;
        }
    
    //If the target tile is not unset, swap
    if(targetTile != nil)
    {
        [self swapWith:targetTile isInitial:NO];
    }
    //Otherwise, snap tile back to where it was if there is no target tile
    else
    {
        self.center = currentPosition;
    }
    self.layer.shadowRadius = 0.0f;
    self.layer.shadowOpacity = 0.0;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.masksToBounds = NO;
}

-(void)swapWith:(CSTile *)target isInitial:(BOOL)isInit
{
    double duration;
    
    duration = (isInit)? 1.0 : 0.25;
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.center = target.currentPosition;
        target.center = self.currentPosition;
    } completion:nil];
    
    [self.controller.gameBoard bringSubviewToFront:target];
    self.currentPosition = self.center;
    target.currentPosition = target.center;

    self.targetTile = nil;
    
    if(isInit == YES)
    {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeRotation(M_PI * 10);
        }
        completion:nil];
    }
    else
    {
        [self checkForComplete];
    }
}

-(void)checkForComplete
{
    int passed = 0;
    for(CSTile * tile in controller.tiles)
    {
        if(CGPointEqualToPoint(tile.homePosition, tile.currentPosition) == TRUE)
        {
            if(tile.rotation == 0)
            {
                passed++;
            }
        }
    }
    NSLog(@"Passed count: %i", passed);
    if(passed == controller.tiles.count)
    {
        [controller gameWon];
    }
}
@end

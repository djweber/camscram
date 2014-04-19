//
//  CS_Tile.h
//  camscram
//
//  Created by David Weber on 8/16/12.
//
//

#import <UIKit/UIKit.h>
@class CSGameController;
@interface CSTile : UIImageView

@property UIImageView * boundaryMask;
@property CSTile * targetTile;
@property CSGameController * controller;
@property CGPoint homePosition;
@property CGPoint currentPosition;
@property int rotation;

-(void)rotateTile:(int)rotValue;
-(void)checkForComplete;
-(void)swapWith:(CSTile *)target isInitial:(BOOL)isInit;
@end

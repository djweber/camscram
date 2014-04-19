//
//  UIViewController+ExtendedBehavior.h
//  camscram
//
//  Created by David Weber on 8/16/12.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    MGImageResizeCrop,	
    MGImageResizeCropStart,
    MGImageResizeCropEnd,
    MGImageResizeScale	
} MGImageResizingMethod;

@interface UIViewController (ExtendedBehavior)
- (UIImage *)image:(UIImage *)image ToFitSize:(CGSize)size method:(MGImageResizingMethod)resizeMethod;
- (IBAction)back:(id)sender;
-(void)fadeIn;
-(void)obscure;
@end

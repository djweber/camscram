//
//  UIViewController+ExtendedBehavior.m
//  camscram
//
//  Created by David Weber on 8/16/12.
//
//

#import "UIViewController+ExtendedBehavior.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIViewController (ExtendedBehavior)

-(void)fadeIn
{
    //Iterate through and fade in each subview in the viewcontroller's view hierarchy
    for(UIView * view in self.view.subviews)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^(void){
                             [view setAlpha:1.0];
                         }
                         completion:nil];
    }
}

-(void)obscure
{
    //Iterate through and fade out each subview in the viewcontroller's view hierarchy
    for(UIView * view in self.view.subviews)
    {
            [view setAlpha:0.0];
    }
}

#pragma mark - Image Processing Method

//MGImageUtilities resizing code by Matt Gemmell (www.mattgemmell.com).

- (UIImage *)image:(UIImage *)image ToFitSize:(CGSize)size method:(MGImageResizingMethod)resizeMethod
{
	float imageScaleFactor = 1.0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	if ([self respondsToSelector:@selector(scale)]) {
		imageScaleFactor = [image scale];
	}
#endif
	
    float sourceWidth = [image size].width * imageScaleFactor;
    float sourceHeight = [image size].height * imageScaleFactor;
    float targetWidth = size.width;
    float targetHeight = size.height;
    BOOL cropping = !(resizeMethod == MGImageResizeScale);
	
    // Calculate aspect ratios
    float sourceRatio = sourceWidth / sourceHeight;
    float targetRatio = targetWidth / targetHeight;
    
    // Determine what side of the source image to use for proportional scaling
    BOOL scaleWidth = (sourceRatio <= targetRatio);
    // Deal with the case of just scaling proportionally to fit, without cropping
    //scaleWidth = (cropping) ? scaleWidth : !scaleWidth;
    
    // Proportionally scale source image
    float scalingFactor, scaledWidth, scaledHeight;
    if (scaleWidth) {
        scalingFactor = 1.0 / sourceRatio;
        scaledWidth = targetWidth;
        scaledHeight = round(targetWidth * scalingFactor);
    } else {
        scalingFactor = sourceRatio;
        scaledWidth = round(targetHeight * scalingFactor);
        scaledHeight = targetHeight;
    }
    float scaleFactor = scaledHeight / sourceHeight;
    
    // Calculate compositing rectangles
    CGRect sourceRect, destRect;
    if (cropping) {
        destRect = CGRectMake(0, 0, targetWidth, targetHeight);
        float destX, destY;
        if (resizeMethod == MGImageResizeCrop) {
            // Crop center
            destX = round((scaledWidth - targetWidth) / 2.0);
            destY = round((scaledHeight - targetHeight) / 2.0);
        } else if (resizeMethod == MGImageResizeCropStart) {
            // Crop top or left (prefer top)
            if (scaleWidth) {
				// Crop top
				destX = 0.0;
				destY = 0.0;
            } else {
				// Crop left
                destX = 0.0;
				destY = round((scaledHeight - targetHeight) / 2.0);
            }
        } else if (resizeMethod == MGImageResizeCropEnd) {
            // Crop bottom or right
            if (scaleWidth) {
				// Crop bottom
				destX = round((scaledWidth - targetWidth) / 2.0);
				destY = round(scaledHeight - targetHeight);
            } else {
				// Crop right
				destX = round(scaledWidth - targetWidth);
				destY = round((scaledHeight - targetHeight) / 2.0);
            }
        }
        sourceRect = CGRectMake(destX / scaleFactor, destY / scaleFactor,
                                targetWidth / scaleFactor, targetHeight / scaleFactor);
    } else {
        sourceRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
        destRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
    }
    
    // Create appropriately modified image.
	UIImage * newImage = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
		UIGraphicsBeginImageContextWithOptions(destRect.size, NO, 0.0); // 0.0 for scale means "correct scale for device's main screen".
		CGImageRef sourceImg = CGImageCreateWithImageInRect([image CGImage], sourceRect); // cropping happens here.
		newImage = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:image.imageOrientation]; // create cropped UIImage.
		[image drawInRect:destRect]; // the actual scaling happens here, and orientation is taken care of automatically.
		CGImageRelease(sourceImg);
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
#endif
	if (!newImage) {
		// Try older method.
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, (size.width * 4),
													 colorSpace, kCGImageAlphaPremultipliedLast);
		CGImageRef sourceImg = CGImageCreateWithImageInRect([image CGImage], sourceRect);
		CGContextDrawImage(context, destRect, sourceImg);
		CGImageRelease(sourceImg);
		CGImageRef finalImage = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		image = [UIImage imageWithCGImage:finalImage];
		CGImageRelease(finalImage);
	}
	
    return image;
}

-(IBAction)back:(id)sender
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
        int count = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
        [[self.navigationController.viewControllers objectAtIndex:(count - 1)] fadeIn];
        [self.navigationController popViewControllerAnimated:NO];
    });
}


@end

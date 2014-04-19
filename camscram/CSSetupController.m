//
//  CS_SetupController.m
//  camscram
//
//  Created by David Weber on 7/10/12.
//  Copyright (c) David J. Weber. All rights reserved.
//

#import "CSSetupController.h"
#import "CSMainMenuController.h"
#import "CSGameController.h"
#import "UIViewController+ExtendedBehavior.h"

@implementation CSSetupController
@synthesize dButton, tButton, rButton, backButton, step1Label, step2Label, startButton,difficultyGrid, difficultyPane, difficultyButton, timerButton, rotationButton, previewPane, step1View, step2View, popover, buttonPress;

#pragma mark - Setup screen methods

-(IBAction)useCameraPressed:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    useCamera = YES;
    [self chooseImage:sender];
}
-(IBAction)useCameraRollPressed:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    useCamera = NO;
    [self chooseImage:sender];
}

-(void)chooseImage:(id)sender
{
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setDelegate:(id)self];
    
    if(useCamera == YES)
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    if(([currentDevice isEqualToString:@"iPhone"] && imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) || ([currentDevice isEqualToString:@"iPad"] && imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera))
    {
         [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if([currentDevice isEqualToString:@"iPad"] && imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        popover.delegate=(id)self;
        [popover presentPopoverFromRect:CGRectMake(400.0,300.0, 300.0, 40.0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if([currentDevice isEqualToString:@"iPhone"] && imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editInfo {
    if(popover != nil)
    {
        [popover dismissPopoverAnimated:YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //Get size of picked image
    CGSize size = image.size;
    
    //Crop Image
    float sideLength = fminf(size.width, size.height);
    
    float rectXOrigin;
    float rectYOrigin;
    
    CGRect newImageBox;
    
    
    rectXOrigin = (size.width - sideLength) / 2.0f;
    rectYOrigin = (size.height - sideLength) / 2.0f;

    if(image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight)
    {
        newImageBox = CGRectMake(rectYOrigin, rectXOrigin, sideLength, sideLength);
        
    }
    else
    {
        newImageBox = CGRectMake(rectXOrigin, rectYOrigin, sideLength, sideLength);
    }
    
    CGImageRef newImage = CGImageCreateWithImageInRect([image CGImage], newImageBox);
    
    //Set correct orientation
    
    UIImageOrientation orientation;
    
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            orientation = UIImageOrientationLeft;
            break;
            
        case UIImageOrientationRight:
            orientation = UIImageOrientationRight;
            break;
            
        case UIImageOrientationUp:
            orientation = UIImageOrientationUp;
            break;
            
        case UIImageOrientationDown:
            orientation = UIImageOrientationDown;
            break;
            
        case UIImageOrientationLeftMirrored:
            orientation = UIImageOrientationLeftMirrored;
            break;
            
        case UIImageOrientationRightMirrored:
            orientation = UIImageOrientationRightMirrored;
            break;
            
        case UIImageOrientationUpMirrored:
            orientation = UIImageOrientationUpMirrored;
            break;
            
        case UIImageOrientationDownMirrored:
            orientation = UIImageOrientationDownMirrored;
            break;
        default:
            break;
    }
    
    UIImage * processedImage = [UIImage imageWithCGImage:newImage scale:[UIImage imageWithCGImage:newImage].scale orientation:orientation];
        
    theImage = processedImage;
    
    UIImage * thumbnail = [self image:theImage ToFitSize:CGSizeMake(self.previewPane.frame.size.width, self.previewPane.frame.size.height) method:MGImageResizeScale];
    
    [self.previewPane setImage:thumbnail];
    
    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.step2View setAlpha:1.0];
    } completion:nil];
}

//Method to go back if undo button is clicked
-(IBAction)undo:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.step2View setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.difficultyPane setTransform:CGAffineTransformIdentity];
        self->theImage = nil;
        [self.difficultyGrid setImage:nil];
    }];
}

#pragma mark - Scrolling animation methods

-(IBAction)startGame:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    UIImage * resizedImage = [self image:theImage ToFitSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width) method:MGImageResizeScale];
    
    CSGameController * gameView;
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGFloat screenHeight = screenSize.size.height;
    
    if([currentDevice isEqualToString:@"iPad"])
    {
        gameView = [[CSGameController alloc] initWithNibName:@"CSGameController_iPad" bundle:[NSBundle mainBundle] image:resizedImage gridSize:gridSize andTimerOn:timerOn andRotationOn:rotationOn];
    }
    else if(screenHeight == 568)
    {
        gameView = [[CSGameController alloc] initWithNibName:@"CSGameController_iPhone5" bundle:[NSBundle mainBundle] image:resizedImage gridSize:gridSize andTimerOn:timerOn andRotationOn:rotationOn];
    }
    else
    {
        gameView = [[CSGameController alloc] initWithNibName:@"CSGameController" bundle:[NSBundle mainBundle] image:resizedImage gridSize:gridSize andTimerOn:timerOn andRotationOn:rotationOn];
        
    }

    
    for(UIView * view in self.view.subviews)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^(void){
                             [view setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             if([self.view.subviews indexOfObject:view] == self.view.subviews.count - 1)
                             {
                                 //If the last view is animated, push the view controller onto the stack
                                 [self.navigationController pushViewController:gameView animated:NO];
                             }
                         }];
    }
}

#pragma mark - Setup Methods
-(IBAction)difficultyButtonPressed:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    diffCounter++;
    
    if(diffCounter == 3)
    {
        diffCounter = 0;
    }

    NSArray * difficulties = @[@"Mode: 4x4", @"Mode: 8x8", @"Mode: 10x10"];
    
   [dButton setTitle:difficulties[diffCounter] forState:UIControlStateNormal];
    
    switch(diffCounter){
        case 0:
            gridSize = 4;
            [difficultyGrid setImage:[UIImage imageNamed:@"easy_grid.png"]];
            break;
            
        case 1:
            gridSize = 8;
            [difficultyGrid setImage:[UIImage imageNamed:@"medium_grid.png"]];
            break;
            
        case 2:
            gridSize = 10;
            [difficultyGrid setImage:[UIImage imageNamed:@"hard_grid.png"]];
            break;
            
        default:
            break;
    }
}

-(IBAction)timerButtonPressed:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    timerCounter++;
    
    if(timerCounter > 1)
    {
        timerCounter = 0;
    }

    
    NSArray * timerStatus = @[@"Time Attack: Off", @"Time Attack: On"];
    
    [tButton setTitle:timerStatus[timerCounter] forState:UIControlStateNormal];
    
    switch(timerCounter){
        case 0:
            timerOn = FALSE;
            break;
        case 1:
            timerOn = TRUE;
            break;
        default:
            break;
    }
}

-(IBAction)rotationButtonPressed:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"use_sounds"] == 1)
    {
        [self.buttonPress play];
    }
    rotationCounter++;
    
    if(rotationCounter > 1)
    {
        rotationCounter = 0;
    }

    NSArray * rotationStatus = @[@"Rotation: Off", @"Rotation: On"];
    
    [rButton setTitle:rotationStatus[rotationCounter] forState:UIControlStateNormal];
    
    switch(rotationCounter){
        case 0:
            rotationOn = FALSE;
            break;
            
        case 1:
            rotationOn = TRUE;
            break;
        default:
            break;
    }
}

#pragma mark - View controller methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString * soundLoc = [[NSBundle mainBundle] pathForResource:@"menu_tap" ofType:@"mp3"];
    NSURL * soundURL = [NSURL fileURLWithPath:soundLoc];
    NSError * error;
    
    currentDevice = [UIDevice currentDevice].model;
    
    self.buttonPress = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    self.buttonPress.delegate = (id)self;

    //Get current device model
    currentDevice = [UIDevice currentDevice].model;
    
    //Initialize gridSize to 4
    gridSize = 4;
    diffCounter = 0;
    rotationCounter = 0;
    rotationOn = FALSE;
    timerOn = FALSE;
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGFloat screenHeight = screenSize.size.height;
    
    //Set up fonts for text
    if([currentDevice isEqualToString:@"iPhone"] || screenHeight == 568)
    {
        self.step1Label.font = [UIFont fontWithName:@"Furore" size:14];
        self.step2Label.font = [UIFont fontWithName:@"Furore" size:14];
        self.difficultyButton.titleLabel.font = [UIFont fontWithName:@"Furore" size:14];
        self.timerButton.titleLabel.font = [UIFont fontWithName:@"Furore" size:14];
        self.rotationButton.titleLabel.font = [UIFont fontWithName:@"Furore" size:14];
    }
    else if([currentDevice isEqualToString:@"iPad"])
    {
         NSLog(@"Font set!");
        self.step1Label.font = [UIFont fontWithName:@"Furore" size:20];
        self.step2Label.font = [UIFont fontWithName:@"Furore" size:20];
        self.difficultyButton.titleLabel.font = [UIFont fontWithName:@"Furore" size:16];
        self.timerButton.titleLabel.font = [UIFont fontWithName:@"Furore" size:16];
        self.rotationButton.titleLabel.font = [UIFont fontWithName:@"Furore" size:16];
    }
    
   
    //Set the view's frame to be the same as the applications to correct spacing at the bottom
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
       //Obscure views initially, then fade them in
    [self obscure];
    [self fadeIn];
    
    [self.step1View setAlpha:0.0];
    [self.step2View setAlpha:0.0];

    //Fade in initial step
    [UIView animateWithDuration:0.2 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.step1View setAlpha:1.0];
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

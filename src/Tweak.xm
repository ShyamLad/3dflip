#import "yourmum.h"
#import <AudioToolbox/AudioToolbox.h>

static BOOL hasBeenForceTapped = NO;
static BOOL hasBeenBlurTapped = NO;
static float currentForceSaved = 0;



%hook SBIconView


%property(nonatomic,retain) UIImageView *imageView;
%property(nonatomic, retain) _UIBackdropView *blurView;
%property(nonatomic, retain) _UIBackdropViewSettings *noBlurSettings;
%property(nonatomic, retain) _UIBackdropViewSettings *fullBlurSettings;

-(void)setEditing:(BOOL)var1 animated:(BOOL)var2{

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  _UIBackdropViewSettings *localNoBlurSettings = [_UIBackdropViewSettings settingsForStyle:-2];
    self.noBlurSettings = localNoBlurSettings;
    localNoBlurSettings.blurRadius = 0;
    localNoBlurSettings.grayscaleTintAlpha = 0;
    localNoBlurSettings.colorTint = [UIColor blackColor];
    localNoBlurSettings.colorTintAlpha = 0;
    _UIBackdropViewSettings *localFullBlurSettings = [NSClassFromString(@"_UIBackdropViewSettings") settingsForStyle:-2];
    self.fullBlurSettings = localFullBlurSettings;
    localFullBlurSettings.blurRadius = 15;
    localFullBlurSettings.grayscaleTintAlpha = 0;
    localFullBlurSettings.colorTint = [UIColor blackColor];
    localFullBlurSettings.colorTintAlpha = 0;
    localFullBlurSettings.saturationDeltaFactor = 1.8;


  NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];//Get the Bundle
  NSString *rightArrowPath = [bundle pathForResource:@"right_arrow" ofType:@"png"];//Get Path to Image
  UIImage *rightArrowImage = [UIImage imageWithContentsOfFile:rightArrowPath];

  UIImage *scaledImage = [UIImage imageWithCGImage:[rightArrowImage CGImage]
                              scale:(rightArrowImage.scale * 2.0)
                                 orientation:(rightArrowImage.imageOrientation)];
  self.imageView = [[UIImageView alloc] initWithImage:scaledImage];

  SBRootFolderController *rfc = [%c(SBIconController) sharedInstance]._rootFolderController;
  SBRootFolderView *rfv = rfc.contentView;
  SBDockIconListView *dlv = MSHookIvar<SBDockIconListView *>(rfv, "_dockListView");
  [self.imageView setFrame:CGRectMake((rfv.frame.size.width/2)-(self.imageView.frame.size.width/2), (rfv.frame.size.height/2)-(self.imageView.frame.size.height/2) - dlv.frame.size.height/2, self.imageView.frame.size.width, self.imageView.frame.size.height)];

  self.blurView=[[_UIBackdropView alloc] initWithFrame:rfv.frame autosizesToFitSuperview:NO settings:self.noBlurSettings];
  [rfv addSubview:self.blurView];
  [self.blurView release];
  self.imageView.alpha = 0;
  [rfv addSubview:self.imageView];


  [bundle release];
  %orig;

}




- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([%c(SBIconController) sharedInstance].isEditing) {
    UITouch *currentTouch = [touches anyObject];
    CGFloat currentForce = currentTouch.force;

    // HBLogDebug(@"The force is: %f", currentForce);
    SBRootFolderController *rfc = [%c(SBIconController) sharedInstance]._rootFolderController;
    SBRootFolderView *rfv = rfc.contentView;
    UIView *viewForLocation = MSHookIvar<UIView *>(rfv, "_scalingView");
    CGPoint location = [currentTouch locationInView:viewForLocation];

    SBIconListPageControl *pc = MSHookIvar<SBIconListPageControl *>(rfv, "_pageControl");
    NSInteger currentPage = pc.currentPage;
    CGFloat currentForcePercentage = ((currentForce-1)/2);
    CGFloat midX = CGRectGetMidX(viewForLocation.frame);
    // HBLogDebug(@"Midpoint X: %@", @(midX));
    BOOL shiftRight = location.x >= midX;
    // HBLogDebug(@"The Current X Location is : %@", @(location.x));
    // HBLogDebug(@"The Current Page is: %@", @(currentPage));

    if(currentForce<1)
    {
      hasBeenBlurTapped = NO;
      [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
      [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];

    }
    if((currentForceSaved != currentForce) && !(hasBeenBlurTapped) && currentForce >= 1){



        [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:currentForcePercentage];

      currentForceSaved = currentForce;
    }




    if(currentForce < 4) {
      hasBeenForceTapped = NO;
    }

    // HBLogDebug(@"hasBeenForceTapped: %d", hasBeenForceTapped);
    if (currentForce >= 4 && !(hasBeenForceTapped)) {
      // HBLogDebug(@"fuck");

      hasBeenForceTapped = YES;
      hasBeenBlurTapped = YES;



      // Make sure we're not at the far left or right page already.
      if ((shiftRight && currentPage + 1 < pc.numberOfPages) || (!shiftRight && currentPage > 1)) {
        AudioServicesPlaySystemSound(1520); // Pop feedback.

        // This switches pages but fails to update icon location in changed icon list.
        // [rfv pageControl:pc didRecieveTouchInDirection:shiftRight ? 1 : 0];

        // This updates icon location after page it changes pages.

          self.imageView.transform = CGAffineTransformMakeRotation(shiftRight ? 0 : M_PI);

        [rfc _doAutoScrollByPageCount:shiftRight ? 1 : -1];
        [UIView animateWithDuration:.75 animations:^{
          [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:1];
          self.imageView.alpha = 2.5;

          }];
          [UIView animateWithDuration:.4 animations:^{
            [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
            self.imageView.alpha = 0;

            }];



      }
      else {

        AudioServicesPlaySystemSound(1521);
        [UIView animateWithDuration:.25 animations:^{
          [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
          self.imageView.alpha = 0;

          }];

        // Error feedback.
        // [UIView animateWithDuration:0.15 animations:^{
        //   [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
        //   [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
        //
        //   }];



      }

    }
  }

  %orig(touches,event);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.imageView removeFromSuperview];
  [self.blurView removeFromSuperview];
  self.imageView=nil;
  self.blurView = nil;
  %orig;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.imageView removeFromSuperview];
  [self.blurView removeFromSuperview];
  self.imageView=nil;
  self.blurView = nil;
  %orig;
}



%end

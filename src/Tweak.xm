#import "yourmum.h"
#import <AudioToolbox/AudioToolbox.h>

static BOOL hasBeenForceTapped = NO;
static float currentForceSaved = 0;
// static NSInteger deviceWidth = 375;
// static _UIBackdropViewSettings *settings;
// static _UIBackdropView *blurView;



%hook SBIconView

%property(nonatomic, retain) _UIBackdropView *blurView;
%property(nonatomic, retain) _UIBackdropViewSettings *noBlurSettings;
%property(nonatomic, retain) _UIBackdropViewSettings *fullBlurSettings;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([%c(SBIconController) sharedInstance].isEditing){
      self.noBlurSettings = [_UIBackdropViewSettings settingsForStyle:-2];
      self.noBlurSettings.blurRadius = 0;
      self.noBlurSettings.grayscaleTintAlpha = 0;
      self.noBlurSettings.colorTint = [UIColor blackColor];
      self.noBlurSettings.colorTintAlpha = 0;
      self.fullBlurSettings = [NSClassFromString(@"_UIBackdropViewSettings") settingsForStyle:2020];
      self.blurView=[[_UIBackdropView alloc] initWithSettings:self.noBlurSettings];
      SBRootFolderController *rfc = [%c(SBIconController) sharedInstance]._rootFolderController;
      SBRootFolderView *rfv = rfc.contentView;
      [rfv addSubview:self.blurView];
      [self.blurView release];

      // [self.blurView transitionToStyle:2060];

    }

    %orig(touches,event);

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
    CGFloat currentForcePercentage = (currentForce/3);

    // HBLogDebug(@"The Current X Location is : %@", @(location.x));
    // HBLogDebug(@"The Current Page is: %@", @(currentPage));
    // if(currentForce >2){
    if(currentForceSaved != currentForce){
      [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:currentForcePercentage];
    }
    //
    // }
    if(currentForce < 3) {
      hasBeenForceTapped = NO;
    }

    // HBLogDebug(@"hasBeenForceTapped: %d", hasBeenForceTapped);
    if (currentForce >= 3 && !(hasBeenForceTapped)) {
      // HBLogDebug(@"fuck");

      hasBeenForceTapped = YES;

      CGFloat midX = CGRectGetMidX(viewForLocation.frame);
      // HBLogDebug(@"Midpoint X: %@", @(midX));
      BOOL shiftRight = location.x >= midX;

      // Make sure we're not at the far left or right page already.
      if ((shiftRight && currentPage + 1 < pc.numberOfPages) || (!shiftRight && currentPage > 1)) {
        AudioServicesPlaySystemSound(1520); // Pop feedback.

        // This switches pages but fails to update icon location in changed icon list.
        // [rfv pageControl:pc didRecieveTouchInDirection:shiftRight ? 1 : 0];

        // This updates icon location after page it changes pages.
        [rfc _doAutoScrollByPageCount:shiftRight ? 1 : -1];
        [self.blurView removeFromSuperview];
        self.blurView=nil;

      }
      else {

        AudioServicesPlaySystemSound(1521);// Error feedback.
        [self.blurView removeFromSuperview];
        self.blurView=nil;
      }

    }
  }

  %orig(touches,event);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
  %orig;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.blurView transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
  %orig;
}



%end

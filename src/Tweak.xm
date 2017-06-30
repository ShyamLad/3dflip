#import "yourmum.h"
#import <AudioToolbox/AudioToolbox.h>

static BOOL hasBeenForceTapped = NO;
static BOOL hasBeenBlurTapped = NO;
static float currentForceSaved = 0;
// static NSInteger deviceWidth = 375;
// static _UIBackdropViewSettings *settings;
// static _UIBackdropView *blurView;



%hook SBIconView

%property(nonatomic, retain) _UIBackdropView *blurViewRight;
%property(nonatomic, retain) _UIBackdropView *blurViewLeft;
%property(nonatomic, retain) _UIBackdropViewSettings *noBlurSettings;
%property(nonatomic, retain) _UIBackdropViewSettings *fullBlurSettings;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([%c(SBIconController) sharedInstance].isEditing){
    _UIBackdropViewSettings *localNoBlurSettings = [_UIBackdropViewSettings settingsForStyle:-2];
      self.noBlurSettings = localNoBlurSettings;
      localNoBlurSettings.blurRadius = 0;
      localNoBlurSettings.grayscaleTintAlpha = 0;
      localNoBlurSettings.colorTint = [UIColor blackColor];
      localNoBlurSettings.colorTintAlpha = 0;
      _UIBackdropViewSettings *localFullBlurSettings = [NSClassFromString(@"_UIBackdropViewSettings") settingsForStyle:-2];
      self.fullBlurSettings = localFullBlurSettings;
      localFullBlurSettings.blurRadius = 3;
      localFullBlurSettings.grayscaleTintAlpha = 0;
      localFullBlurSettings.colorTint = [UIColor blackColor];
      localFullBlurSettings.colorTintAlpha = .25;
      SBRootFolderController *rfc = [%c(SBIconController) sharedInstance]._rootFolderController;
      SBRootFolderView *rfv = rfc.contentView;
      CGFloat midXLocation = CGRectGetMidX(rfv.frame);
      NSLog(@"The Midx is: %f",midXLocation);
      CGFloat midYLocation = 0;
      NSLog(@"The Midy is: %f",midYLocation);
      CGFloat xWidth = (rfv.frame.size.width)/2;
      CGFloat yHeight = rfv.frame.size.height;
      CGRect rightFrame = CGRectMake(midXLocation,midYLocation,xWidth,yHeight);
      CGRect leftFrame = CGRectMake(0,midYLocation,xWidth,yHeight);


      self.blurViewRight=[[_UIBackdropView alloc] initWithFrame:rightFrame autosizesToFitSuperview:NO settings:self.noBlurSettings];
      self.blurViewLeft=[[_UIBackdropView alloc] initWithFrame:leftFrame autosizesToFitSuperview:NO settings:self.noBlurSettings];

      [rfv addSubview:self.blurViewRight];
      [self.blurViewRight release];
      [rfv addSubview:self.blurViewLeft];
      [self.blurViewLeft release];

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
    CGFloat currentForcePercentage = ((currentForce-1)/2);
    CGFloat midX = CGRectGetMidX(viewForLocation.frame);
    // HBLogDebug(@"Midpoint X: %@", @(midX));
    BOOL shiftRight = location.x >= midX;
    // HBLogDebug(@"The Current X Location is : %@", @(location.x));
    // HBLogDebug(@"The Current Page is: %@", @(currentPage));
    if(currentForce<1)
    {
      hasBeenBlurTapped = NO;
      [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
      [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];

    }
    if((currentForceSaved != currentForce) && !(hasBeenBlurTapped) && currentForce >= 1){
      if(shiftRight){
        [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:currentForcePercentage];
      }
      else{
        [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:currentForcePercentage];
      }



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
        [rfc _doAutoScrollByPageCount:shiftRight ? 1 : -1];
        // [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
        // [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
        // if(!hasBeenBlurTapped)
        // {
        //   [UIView animateWithDuration:0.3 animations:^{
        //     [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:1];
        //     // [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:1];
        //
        //     }];
        // }
        [UIView animateWithDuration:0.15 animations:^{
          [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
          [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];

          }];



      }
      else {

        AudioServicesPlaySystemSound(1521);// Error feedback.
        // [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
        // [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
        [UIView animateWithDuration:0.15 animations:^{
          [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
          [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];

          }];



      }

    }
  }

  %orig(touches,event);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {


  // [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
  [self.blurViewRight removeFromSuperview];
  self.blurViewRight=nil;
  // [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
  [self.blurViewLeft removeFromSuperview];
  self.blurViewLeft=nil;
  %orig;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.blurViewRight transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
  [self.blurViewRight removeFromSuperview];
  self.blurViewRight=nil;
  [self.blurViewLeft transitionIncrementallyToSettings:self.fullBlurSettings weighting:0];
  [self.blurViewLeft removeFromSuperview];
  self.blurViewLeft=nil;
  %orig;
}



%end

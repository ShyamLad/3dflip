#import "yourmum.h"
#import <AudioToolbox/AudioToolbox.h>
static BOOL hasBeenForceTapped = NO;

%hook SBIconView
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

    // HBLogDebug(@"The Current X Location is : %@", @(location.x));
    // HBLogDebug(@"The Current Page is: %@", @(currentPage));


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
        // [rfv pageControl:pc didRecieveTouchInDirection:shiftRight ? 1 : 0];  //This switches pages but fails to update icon location in changed icon list
        if(shiftRight){
          [rfc _doAutoScrollByPageCount:1]; //this updates icon location after page has been changed.
        }
        else{
          [rfc _doAutoScrollByPageCount:-1];
        }
      } else {
        AudioServicesPlaySystemSound(1521); // Error feedback.
      }
    }
  }
  %orig(touches,event);
}
%end

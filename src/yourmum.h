// @interface _UIBackdropViewSettings : NSObject
// 	+ (id)settingsForStyle:(int)arg1;
// @end
#import "_UIBackdropViewSettings.h"

@interface _UIBackdropView : UIView
- (id)initWithStyle:(int)arg1;
- (id)initWithSettings:(_UIBackdropViewSettings *)arg1;
- (void)transitionIncrementallyToPrivateStyle:(int)arg1 weighting:(CGFloat)arg2;
- (void)transitionIncrementallyToStyle:(int)arg1 weighting:(CGFloat)arg2;
- (void)transitionIncrementallyToSettings:(_UIBackdropViewSettings *)arg1 weighting:(CGFloat)arg2;
- (void)setAppliesOutputSettingsAnimationDuration:(CGFloat)duation;
- (void)transitionToSettings:(id)arg1;
- (id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3;
- (id)initWithPrivateStyle:(int)arg1;
- (void)setBlurFilterWithRadius:(float)arg1 blurQuality:(id)arg2 blurHardEdges:(int)arg3;
- (void)setBlurFilterWithRadius:(float)arg1 blurQuality:(id)arg2;
- (void)setBlurHardEdges:(int)arg1;
- (void)setInputSettings:(id)arg1;
- (void)setBlurQuality:(id)arg1;
- (void)setBlurRadius:(float)arg1;
- (void)setBlurRadiusSetOnce:(BOOL)arg1;
- (void)setBlursBackground:(BOOL)arg1;
- (void)setBlursWithHardEdges:(BOOL)arg1;

@end



@interface SBIconScrollView: UIView
@end

@interface SBIcon
@end

@interface SBIconListPageControl :UIPageControl
  @property(nonatomic,assign) NSInteger currentPage;

@end

@interface SBRootFolderView: UIView

  @property(nonatomic, assign) NSUInteger dockEdge;
  @property(nonatomic, assign) NSInteger currentPageIndex;
  @property(nonatomic,assign,readwrite) CGRect frame;
  -(void)pageControl:(id)var1 didRecieveTouchInDirection:(int)var2;
  -(void)addSubview:(id)var1;

@end

@interface SBRootFolderController: NSObject
  @property(nonatomic, assign) SBRootFolderView *contentView;
  -(void)_doAutoScrollByPageCount:(NSInteger) var1;
@end

@interface SBIconController: UIViewController

  @property(nonatomic, readonly) CGFloat force;
  + (SBIconController *)sharedInstance;
  @property(nonatomic, assign) BOOL isEditing;
  @property(nonatomic, assign) NSInteger currentIconListIndex;
  @property(nonatomic, assign) SBRootFolderController *_rootFolderController;

@end

@interface SBIconView:UIView
	@property(nonatomic, retain) _UIBackdropView *blurViewRight;
  @property(nonatomic, retain) _UIBackdropView *blurViewLeft;
	@property(nonatomic, retain) _UIBackdropViewSettings *noBlurSettings;
	@property(nonatomic, retain) _UIBackdropViewSettings *fullBlurSettings;


@end

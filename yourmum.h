

@interface SBIconScrollView: UIView
@end

@interface SBIcon
@end

@interface SBIconListPageControl :UIPageControl
  @property(nonatomic,assign) NSInteger currentPage;

@end

@interface SBRootFolderView: NSObject

  @property(nonatomic, assign) NSUInteger dockEdge;
  @property(nonatomic, assign) NSInteger currentPageIndex;
  -(void)pageControl:(id)var1 didRecieveTouchInDirection:(int)var2;

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

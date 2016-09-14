SYSegmentedControl
=================

Custom component to recreate `UISegmentedControl` features on iOS and tvOS plus the following ones:

- deselect all items
- select multiple items
- custom height
- custom font
- custom colors (on tvOS)

All may not be perfect, if you find a bug or need another feature feel free to send a pull request!

	@protocol SYSegmentedControlDelegate <NSObject>
	
	- (void)segmentedControl:(SYSegmentedControl *)segmentedControl
	  changedSelectedIndexes:(NSIndexSet *)selectedIndexes;
	
	@end
	
	IB_DESIGNABLE
	@interface SYSegmentedControl : UIView
	
	@property (nonatomic, weak) IBOutlet id<SYSegmentedControlDelegate> delegate;
	@property (nonatomic, strong)               NSArray <NSString *> *titles;
	@property (nonatomic, strong) IBInspectable UIFont      *font;
	@property (nonatomic)         IBInspectable NSString    *titlesAsString;
	@property (nonatomic, strong) IBInspectable NSIndexSet  *selectedIndexes;
	@property (nonatomic, assign) IBInspectable CGFloat     height;
	@property (nonatomic, assign) IBInspectable CGFloat     lineWidth;
	@property (nonatomic, assign) IBInspectable BOOL        equalWidths;
	@property (nonatomic, assign) IBInspectable BOOL        allowMultipleSelection;
	@property (nonatomic, assign) IBInspectable BOOL        allowNoSelection;
	
	#if TARGET_OS_TV
	@property (nonatomic, strong) IBInspectable UIColor *textColor;
	@property (nonatomic, strong) IBInspectable UIColor *focusedTextColor;
	@property (nonatomic, strong) IBInspectable UIColor *focusedBackgroundColor;
	@property (nonatomic, strong) IBInspectable UIColor *selectedTextColor;
	@property (nonatomic, strong) IBInspectable UIColor *selectedBackgroundColor;
	#endif
	
	@end


License
-------

Once again, do as you wish with this code, but if you like it drop me an email to say thanks ;)

//
//  SYSegmentedControl.h
//  SYSegmentedControl
//
//  Created by Stan Chevallier on 10/09/2016.
//  Copyright © 2016 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYSegmentedControl;

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
@property (nonatomic, assign) IBInspectable CGFloat     margin;
@property (nonatomic, assign) IBInspectable BOOL        equalWidths;
@property (nonatomic, assign) IBInspectable BOOL        allowMultipleSelection;
@property (nonatomic, assign) IBInspectable BOOL        allowNoSelection;

- (NSArray <NSString *> *)selectedTitles;

#if TARGET_OS_TV
@property (nonatomic, strong) IBInspectable UIColor *textColor;
@property (nonatomic, strong) IBInspectable UIColor *focusedTextColor;
@property (nonatomic, strong) IBInspectable UIColor *focusedBackgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *selectedTextColor;
@property (nonatomic, strong) IBInspectable UIColor *selectedBackgroundColor;
#endif

@end


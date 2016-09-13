//
//  SYSegmentedControl.h
//  Wild
//
//  Created by Stan Chevallier on 10/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYSegmentedControl;

@protocol SYSegmentedControlDelegate <NSObject>

- (void)segmentedControl:(SYSegmentedControl *)segmentedControl
          didSelectIndex:(NSUInteger)index;

@end

IB_DESIGNABLE

#if TARGET_OS_TV
@interface SYSegmentedControl : UIView
#else
@interface SYSegmentedControl : UISegmentedControl
#endif

@property (nonatomic, weak) IBOutlet id<SYSegmentedControlDelegate> delegate;
@property (nonatomic, strong) NSArray <NSString *> *titles;
@property (nonatomic, strong) IBInspectable UIFont      *textFont;
@property (nonatomic)         IBInspectable NSString    *titlesAsString;
@property (nonatomic)         IBInspectable NSUInteger  selectedIndex;
@property (nonatomic, assign) IBInspectable CGFloat     height;

#if TARGET_OS_TV
@property (nonatomic, strong) IBInspectable UIColor *focusedBackgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *focusedTextColor;
@property (nonatomic, strong) IBInspectable UIColor *selectedTextColor;
@property (nonatomic, strong) IBInspectable UIColor *textColor;
#else
@property (nonatomic) IBInspectable UIColor *frontColor;
@property (nonatomic) IBInspectable UIColor *backColor;

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex NS_UNAVAILABLE;
- (NSInteger)selectedSegmentIndex NS_UNAVAILABLE;
#endif

@end


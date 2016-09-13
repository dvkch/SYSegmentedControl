//
//  SYSegmentedControl.m
//  Wild
//
//  Created by Stan Chevallier on 10/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYSegmentedControl.h"
#import "UIImage+SY.h"
#import "Masonry.h"

@interface SYSegmentedControl ()
@property (nonatomic, strong) NSArray <UIButton *> *buttons;
@end

@implementation SYSegmentedControl

- (instancetype)init
{
    self = [super init];
    if (self) [self customSetup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self customSetup];
    return self;
}

#if TARGET_OS_TV

- (void)customSetup
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.layer.cornerRadius = 6.;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    [coordinator addCoordinatedAnimations:^{
        if ([self.buttons containsObject:(id)context.nextFocusedView])
            [self bringSubviewToFront:context.nextFocusedView];
    } completion:nil];
}

- (void)setFocusedTextColor:(UIColor *)focusedTextColor
{
    self->_focusedTextColor = focusedTextColor;
    for (UIButton *button in self.buttons)
        [button setTitleColor:focusedTextColor forState:UIControlStateFocused];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor
{
    self->_selectedTextColor = selectedTextColor;
    for (UIButton *button in self.buttons)
        [button setTitleColor:selectedTextColor forState:UIControlStateSelected];
}

- (void)setTextColor:(UIColor *)textColor
{
    self->_textColor = textColor;
    for (UIButton *button in self.buttons)
        [button setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    for (UIButton *button in self.buttons)
    {
        [button setBackgroundImage:[UIImage imageWithColor:self.backgroundColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:self.backgroundColor] forState:UIControlStateSelected];
    }
}

- (void)setTitles:(NSArray<NSString *> *)titles
{
    CGFloat marginBetween = 20.;
    CGFloat marginInsets  = 20.;
    
    self->_titles = titles;
    [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray <UIButton *> *buttons = [NSMutableArray array];
    for (NSString *title in self.titles)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setBackgroundImage:[UIImage imageWithColor:self.focusedBackgroundColor] forState:UIControlStateFocused];
        [button setBackgroundImage:[UIImage imageWithColor:self.backgroundColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:self.backgroundColor] forState:UIControlStateSelected];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:self.focusedTextColor forState:UIControlStateFocused];
        [button setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
        [button setTitleColor:self.textColor forState:UIControlStateNormal];
        if (self.textFont)
            [button setAttributedTitle:[[NSAttributedString alloc] initWithString:title
                                                                       attributes:@{NSFontAttributeName:self.textFont}]
                              forState:UIControlStateNormal];
        else
            [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventPrimaryActionTriggered];
        [button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [button setContentEdgeInsets:UIEdgeInsetsMake(marginInsets, marginInsets, marginInsets, marginInsets)];
        [buttons addObject:button];
        [self addSubview:button];
    }
    
    for (NSUInteger i = 0; i < buttons.count; ++i)
    {
        UIButton *button = buttons[i];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
            if (i == 0)
            {
                make.left.equalTo(@0);
            }
            else
            {
                make.width.equalTo(buttons.firstObject);
                make.left.equalTo(buttons[i-1].mas_right).offset(marginBetween);
            }
            if (i == buttons.count - 1)
            {
                make.right.equalTo(@0);
            }
        }];
    }
    
    self.buttons = [buttons copy];
}

- (void)setButtons:(NSArray<UIButton *> *)buttons
{
    self->_buttons = buttons;
    [self invalidateIntrinsicContentSize];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    for (NSUInteger i = 0; i < self.buttons.count; ++i)
    {
        UIButton *button = self.buttons[i];
        [button setSelected:(i == selectedIndex)];
    }
}

- (NSUInteger)selectedIndex
{
    for (NSUInteger i = 0; i < self.buttons.count; ++i)
    {
        UIButton *button = self.buttons[i];
        if (button.isSelected)
            return i;
    }
    return NSNotFound;
}

- (void)setTextFont:(UIFont *)textFont
{
    self->_textFont = textFont;
    for (NSUInteger i = 0; i < self.buttons.count; ++i)
    {
        UIButton *button = self.buttons[i];
        if (textFont)
            [button setAttributedTitle:[[NSAttributedString alloc] initWithString:self.titles[i]
                                                                       attributes:@{NSFontAttributeName:textFont}]
                              forState:UIControlStateNormal];
        else
            [button setTitle:self.titles[i] forState:UIControlStateNormal];
    }
}

- (void)setFocusedBackgroundColor:(UIColor *)focusedBackgroundColor
{
    self->_focusedBackgroundColor = focusedBackgroundColor;
    for (UIButton *button in self.buttons)
        [button setBackgroundImage:[UIImage imageWithColor:focusedBackgroundColor] forState:UIControlStateFocused];
}

- (void)buttonDidTap:(id)sender
{
    NSUInteger index = [self.buttons indexOfObject:sender];
    if (index == self.selectedIndex)
        return;
    
    [UIView animateWithDuration:.2 animations:^{
        [self setSelectedIndex:index];
        if ([self.delegate respondsToSelector:@selector(segmentedControl:didSelectIndex:)])
            [self.delegate segmentedControl:self didSelectIndex:index];
    }];
}
#else

- (void)customSetup
{
    [self.layer setCornerRadius:4.];
    [self.layer setMasksToBounds:YES];
    [self addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)setFrontColor:(UIColor *)frontColor
{
    [self setTintColor:frontColor];
}

- (UIColor *)frontColor
{
    return self.tintColor;
}

- (void)setBackColor:(UIColor *)backColor
{
    [self setBackgroundColor:backColor];
    [self update];
}

- (UIColor *)backColor
{
    return self.backgroundColor;
}

- (void)setTextFont:(UIFont *)textFont
{
    self->_textFont = textFont;
    [self update];
}

- (void)update
{
    // BACKGROUND
    [self.layer setCornerRadius:4.];
    [self.layer setMasksToBounds:YES];
    
    // FONT
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes addEntriesFromDictionary:[self titleTextAttributesForState:UIControlStateNormal]];
    if (self.textFont) {
        [attributes setObject:self.textFont forKey:NSFontAttributeName];
    }
    [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (void)setTitles:(NSArray<NSString *> *)titles
{
    self->_titles = titles;
    while ([self numberOfSegments])
        [self removeSegmentAtIndex:0 animated:NO];
    
    for (NSUInteger i = 0; i < titles.count; ++i)
    {
        NSString *title = titles[i];
        [self insertSegmentWithTitle:title atIndex:i animated:NO];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedSegmentIndex:selectedIndex];
}

- (NSUInteger)selectedIndex
{
    if (super.selectedSegmentIndex == UISegmentedControlNoSegment)
        return NSNotFound;
    return super.selectedSegmentIndex;
}

- (void)segmentDidChange:(id)sender
{
    [UIView animateWithDuration:.2 animations:^{
        if ([self.delegate respondsToSelector:@selector(segmentedControl:didSelectIndex:)])
            [self.delegate segmentedControl:self didSelectIndex:super.selectedSegmentIndex];
    }];
}

#endif

- (void)setHeight:(CGFloat)height
{
    self->_height = height;
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    if (self.height >= 1.)
        return CGSizeMake([super intrinsicContentSize].width, self.height);
    return [super intrinsicContentSize];
}

- (void)setTitlesAsString:(NSString *)titlesAsString
{
    NSArray <NSString *> *titles = [titlesAsString componentsSeparatedByString:@"|"];
    [self setTitles:titles];
}

- (NSString *)titlesAsString
{
    return [self.titles componentsJoinedByString:@"|"];
}

@end

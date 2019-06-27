//
//  SYSegmentedControl.m
//  SYSegmentedControl
//
//  Created by Stan Chevallier on 10/09/2016.
//  Copyright © 2016 Syan. All rights reserved.
//

#import "SYSegmentedControl.h"
#import <SYKit/SYKit-Swift.h>

static NSString * const SYSegmentedControlTitlesSeparator = @"|";

@interface SYSegmentedControl ()
@property (nonatomic, strong) NSArray <UIButton *> *buttons;
@property (nonatomic, strong) NSArray <UIView *> *separators;
@property (nonatomic, strong) NSArray <NSLayoutConstraint *> *buttonWidthConstraints;
@property (nonatomic, strong) NSArray <NSLayoutConstraint *> *separatorWidthConstraints;
@property (nonatomic, strong) NSArray <NSLayoutConstraint *> *marginConstraints;
@end

@implementation SYSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self customSetup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self customSetup];
    return self;
}

- (void)customSetup
{
    _lineWidth              = 1;
    _height                 = 0;
    _equalWidths            = YES;
    _allowNoSelection       = NO;
    _allowMultipleSelection = YES;
    _marginBetweenItems     = (TARGET_OS_TV ? 20. : 0.);
    _itemsInsets            = (TARGET_OS_TV ? UIEdgeInsetsZero : UIEdgeInsetsMake(10, 10, 10, 10));
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
#if TARGET_OS_TV
    [self.layer setCornerRadius:6.];
#else
    [self.layer setCornerRadius:4.];
    [self.layer setBorderWidth:self.lineWidth];
    [self.layer setBorderColor:self.tintColor.CGColor];
    [self.layer setMasksToBounds:YES];
#endif
}

#pragma mark - Properties

#pragma mark Titles

- (void)setTitles:(NSArray<NSString *> *)titles
{
    self->_titles = titles;
    [self recreateButtons];
}

- (NSString *)titlesAsString
{
    return [self.titles componentsJoinedByString:SYSegmentedControlTitlesSeparator];
}

- (void)setTitlesAsString:(NSString *)titlesAsString
{
    NSArray <NSString *> *titles = [titlesAsString componentsSeparatedByString:SYSegmentedControlTitlesSeparator];
    [self setTitles:titles];
}

#pragma mark Colors

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
#if !TARGET_TV_OS
    [self updateSeparatorColors];
    for (UIButton *button in self.buttons)
    {
        [button setTitleColor:tintColor forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:self.tintColor]
                          forState:UIControlStateSelected];
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:[self.tintColor colorWithAlphaComponent:.2]]
                          forState:UIControlStateHighlighted];
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:[self.tintColor colorWithAlphaComponent:.7]]
                          forState:(UIControlStateHighlighted|UIControlStateSelected)];
    }
    
    for (UIView *separator in self.separators)
        [separator setBackgroundColor:self.tintColor];
    
    [self.layer setBorderColor:self.tintColor.CGColor];
#endif
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
#if !TARGET_TV_OS
    [self updateSeparatorColors];
    for (UIButton *button in self.buttons)
    {
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:self.backgroundColor]
                          forState:UIControlStateNormal];
        
        [button setTitleColor:self.backgroundColor
                     forState:UIControlStateSelected];
        [button setTitleColor:self.backgroundColor
                     forState:(UIControlStateSelected | UIControlStateHighlighted)];
    }
#endif
}

#if TARGET_OS_TV
- (void)setTextColor:(UIColor *)textColor
{
    self->_textColor = textColor;
    for (UIButton *button in self.buttons)
        [button setTitleColor:textColor
                     forState:UIControlStateNormal];
}

- (void)setFocusedTextColor:(UIColor *)focusedTextColor
{
    self->_focusedTextColor = focusedTextColor;
    for (UIButton *button in self.buttons)
    {
        [button setTitleColor:focusedTextColor
                     forState:UIControlStateFocused];
        [button setTitleColor:focusedTextColor
                     forState:(UIControlStateFocused|UIControlStateSelected|UIControlStateHighlighted)];
    }
}

- (void)setFocusedBackgroundColor:(UIColor *)focusedBackgroundColor
{
    self->_focusedBackgroundColor = focusedBackgroundColor;
    for (UIButton *button in self.buttons)
    {
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:focusedBackgroundColor]
                          forState:UIControlStateFocused];
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:focusedBackgroundColor]
                          forState:(UIControlStateFocused|UIControlStateSelected|UIControlStateHighlighted)];
    }
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor
{
    self->_selectedTextColor = selectedTextColor;
    for (UIButton *button in self.buttons)
    {
        [button setTitleColor:selectedTextColor
                     forState:UIControlStateSelected];
        [button setTitleColor:selectedTextColor
                     forState:(UIControlStateSelected|UIControlStateFocused)];
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    self->_selectedBackgroundColor = selectedBackgroundColor;
    for (UIButton *button in self.buttons)
    {
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:selectedBackgroundColor]
                          forState:UIControlStateSelected];
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:selectedBackgroundColor]
                          forState:(UIControlStateSelected|UIControlStateFocused)];
        [button setBackgroundImage:[[UIImage alloc] sy_imageWithColor:selectedBackgroundColor]
                          forState:(UIControlStateHighlighted|UIControlStateFocused)];
    }
}
#endif


#pragma mark Font

- (void)setFont:(UIFont *)font
{
    self->_font = font;
    for (UIButton *button in self.buttons)
        [button.titleLabel setFont:font];
}

#pragma mark Index

- (void)setSelectedIndexes:(NSIndexSet *)selectedIndexes
{
    if (!self.allowMultipleSelection && selectedIndexes.count > 1)
    {
        [self setSelectedIndexes:[NSIndexSet indexSetWithIndex:selectedIndexes.firstIndex]];
        return;
    }
    
    self->_selectedIndexes = selectedIndexes ?: [NSIndexSet indexSet];
    
    [self updateSeparatorColors];
    
    for (NSUInteger i = 0; i < self.buttons.count; ++i)
    {
        UIButton *button = self.buttons[i];
        [button setSelected:[selectedIndexes containsIndex:i]];
    }
}

- (NSArray <NSString *> *)selectedTitles
{
    return [self.titles objectsAtIndexes:self.selectedIndexes];
}

- (void)setSelectedTitles:(NSArray<NSString *> *)selectedTitles
{
    [self setSelectedIndexes:[self.titles indexesOfObjectsPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [selectedTitles containsObject:obj];
    }]];
}

- (NSString *)selectedTitlesAsString
{
    return [self.selectedTitles componentsJoinedByString:SYSegmentedControlTitlesSeparator];
}

- (void)setSelectedTitlesAsString:(NSString *)selectedTitlesAsString
{
    [self setSelectedTitles:[selectedTitlesAsString componentsSeparatedByString:SYSegmentedControlTitlesSeparator]];
}

#pragma mark Metrics

- (void)setLineWidth:(CGFloat)lineWidth
{
    self->_lineWidth = lineWidth;
    
#if !TARGET_OS_TV
    [self.layer setBorderWidth:lineWidth];
    for (NSLayoutConstraint *constraint in self.separatorWidthConstraints)
        [constraint setConstant:lineWidth];
#endif
    
}

- (void)setHeight:(CGFloat)height
{
    self->_height = height;
    [self invalidateIntrinsicContentSize];
}

- (void)setEqualWidths:(BOOL)equalWidths
{
    self->_equalWidths = equalWidths;
    
    if (equalWidths)
    {
        NSMutableArray <NSLayoutConstraint *> *equalWidthsConstraints = [NSMutableArray arrayWithCapacity:self.buttons.count];
        for (NSUInteger i = 1; i < self.buttons.count; ++i)
        {
            [equalWidthsConstraints addObject:[self.buttons.firstObject.widthAnchor constraintEqualToAnchor:self.buttons[i].widthAnchor]];
        }
        
        [self addConstraints:equalWidthsConstraints];
        self.buttonWidthConstraints = [equalWidthsConstraints copy];
    }
    else
    {
        [self removeConstraints:self.buttonWidthConstraints];
        self.buttonWidthConstraints = @[];
    }
    
    [self invalidateIntrinsicContentSize];
}

- (void)setMarginBetweenItems:(CGFloat)marginBetweenItems
{
    self->_marginBetweenItems = marginBetweenItems;
    
    for (NSLayoutConstraint *constraint in self.marginConstraints)
        [constraint setConstant:marginBetweenItems];
    
    [self invalidateIntrinsicContentSize];
}

- (void)setItemsInsets:(UIEdgeInsets)itemsInsets
{
    self->_itemsInsets = itemsInsets;
    
    for (UIButton *button in self.buttons)
        [button setContentEdgeInsets:itemsInsets];
    
    [self invalidateIntrinsicContentSize];
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width, (self.height >= 1. ? self.height : size.height));
}

#pragma mark - Actions

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    [coordinator addCoordinatedAnimations:^{
        if ([self.buttons containsObject:(id)context.nextFocusedView])
            [self bringSubviewToFront:context.nextFocusedView];
    } completion:nil];
}

- (void)buttonDidTap:(UIButton *)sender
{
    NSUInteger index = [self.buttons indexOfObject:sender];
    
    NSMutableIndexSet *indexSet = [self.selectedIndexes mutableCopy] ?: [NSMutableIndexSet indexSet];
    
    // unselecting item
    if ([self.selectedIndexes containsIndex:index])
    {
        if (self.selectedIndexes.count > 1 || (self.selectedIndexes.count == 1 && self.allowNoSelection))
            [indexSet removeIndex:index];
    }
    // selecting item
    else
    {
        if (self.allowMultipleSelection)
            [indexSet addIndex:index];
        else
            indexSet = [NSMutableIndexSet indexSetWithIndex:index];
    }
    
    if ([indexSet isEqualToIndexSet:self.selectedIndexes])
        return;
    
    [self setSelectedIndexes:[indexSet copy]];
    if ([self.delegate respondsToSelector:@selector(segmentedControl:changedSelectedIndexes:)])
        [self.delegate segmentedControl:self changedSelectedIndexes:indexSet];
}

#pragma mark - Private

- (void)recreateButtons
{
    self.selectedIndexes = nil;
    [self.buttons    makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.separators makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray <UIButton *> *buttons = [NSMutableArray arrayWithCapacity:self.buttons.count];
    
    for (NSString *title in self.titles)
    {
#if TARGET_OS_TV
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
#else
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
#endif
        
        // removes default blur background on tvOS
        [[button sy_findSubviewsOfClass:[UIVisualEffectView class] recursive:YES]
         makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [button setTitle:title forState:UIControlStateNormal];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        
#if TARGET_OS_TV
        [button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventPrimaryActionTriggered];
#else
        [button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
#endif
        
        [buttons addObject:button];
        [self addSubview:button];
    }
    
    NSMutableArray <NSLayoutConstraint *> *marginConstraints = [NSMutableArray arrayWithCapacity:buttons.count+1];
    for (NSUInteger i = 0; i < buttons.count; ++i)
    {
        UIButton *button = buttons[i];
        
        [self addConstraint:[button.topAnchor constraintEqualToAnchor:self.topAnchor]];
        [self addConstraint:[button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]];
        
        if (i == 0)
        {
            [marginConstraints addObject:[button.leftAnchor constraintEqualToAnchor:self.leftAnchor]];
        }
        else
        {
            [marginConstraints addObject:[button.leftAnchor constraintEqualToAnchor:buttons[i-1].rightAnchor]];
        }
        
        if (i == buttons.count - 1)
        {
            [marginConstraints addObject:[button.rightAnchor constraintEqualToAnchor:self.rightAnchor]];
        }
    }
    self.marginConstraints = [marginConstraints copy];
    [self addConstraints:marginConstraints];
    
#if !TARGET_OS_TV
    NSMutableArray <UIView *> *separators = [NSMutableArray arrayWithCapacity:buttons.count];
    NSMutableArray <NSLayoutConstraint *> *separatorWidthConstraint = [NSMutableArray arrayWithCapacity:buttons.count];
    
    for (NSUInteger i = 1; i < buttons.count; ++i)
    {
        UIView *separator = [[UIView alloc] init];
        [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [separators addObject:separator];
        
        [self addSubview:separator];
        
        [self addConstraint:[separator.topAnchor constraintEqualToAnchor:self.topAnchor]];
        [self addConstraint:[separator.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]];
        [self addConstraint:[separator.centerXAnchor constraintEqualToAnchor:buttons[i].leftAnchor]];
        [separatorWidthConstraint addObject:[separator.widthAnchor constraintEqualToConstant:self.lineWidth]];
        
        [separator addConstraint:separatorWidthConstraint.lastObject];
    }
    self.separatorWidthConstraints = [separatorWidthConstraint copy];
    self.separators = [separators copy];
#endif
    
    self.buttons = [buttons copy];
}

- (void)setButtons:(NSArray<UIButton *> *)buttons
{
    self->_buttons = buttons;
    
    [self setTintColor:self.tintColor];
    [self setBackgroundColor:self.backgroundColor];
    [self setFont:self.font];
    [self setEqualWidths:self.equalWidths];
    [self setMarginBetweenItems:self.marginBetweenItems];
    [self setItemsInsets:self.itemsInsets];
    
#if TARGET_OS_TV
    [self setTextColor:self.textColor];
    [self setFocusedTextColor:self.focusedTextColor];
    [self setFocusedBackgroundColor:self.focusedBackgroundColor];
    [self setSelectedTextColor:self.selectedTextColor];
    [self setSelectedBackgroundColor:self.selectedBackgroundColor];
#endif
    
    [self invalidateIntrinsicContentSize];
}

- (void)updateSeparatorColors
{
    for (NSUInteger i = 0; i < self.separators.count; ++i)
    {
        if ([self.selectedIndexes containsIndex:i] && [self.selectedIndexes containsIndex:i+1])
            [self.separators[i] setBackgroundColor:self.backgroundColor];
        else
            [self.separators[i] setBackgroundColor:self.tintColor];
    }
}

@end

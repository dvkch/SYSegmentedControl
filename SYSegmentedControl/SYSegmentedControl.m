//
//  SYSegmentedControl.m
//  Wild
//
//  Created by Stan Chevallier on 10/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYSegmentedControl.h"
#import "UIImage+SYKit.h"

static NSString * const SYSegmentedControlTitlesSeparator = @"|";

#if TARGET_OS_TV
static CGFloat const SYSegmentedControlMarginBetween = 20.;
static CGFloat const SYSegmentedControlMarginInsets  = 20.;
#else
static CGFloat const SYSegmentedControlMarginBetween =  0.;
static CGFloat const SYSegmentedControlMarginInsets  = 10.;
#endif


@interface NSLayoutConstraint (SYKit)

+ (instancetype)sy_equalConstraintWithItems:(NSArray *)items
                                  attribute:(NSLayoutAttribute)attribute
                                     offset:(CGFloat)offset;

+ (instancetype)sy_equalConstraintWithItems:(NSArray *)items
                                 attribute1:(NSLayoutAttribute)attribute1
                                 attribute2:(NSLayoutAttribute)attribute2
                                     offset:(CGFloat)offset;

+ (instancetype)sy_constraintWithItems:(NSArray *)items
                             attribute:(NSLayoutAttribute)attribute
                             relatedBy:(NSLayoutRelation)relation
                                offset:(CGFloat)offset;

+ (instancetype)sy_constraintWithItems:(NSArray *)items
                            attribute1:(NSLayoutAttribute)attribute1
                            attribute2:(NSLayoutAttribute)attribute2
                             relatedBy:(NSLayoutRelation)relation
                                offset:(CGFloat)offset;

@end

@interface SYSegmentedControl ()
@property (nonatomic, strong) NSArray <UIButton *> *buttons;
@property (nonatomic, strong) NSArray <UIView *> *separators;
@property (nonatomic, strong) NSArray <NSLayoutConstraint *> *buttonWidthConstraints;
@property (nonatomic, strong) NSArray <NSLayoutConstraint *> *separatorWidthConstraints;
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

#if TARGET_OS_TV
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

- (void)setFocusedBackgroundColor:(UIColor *)focusedBackgroundColor
{
    self->_focusedBackgroundColor = focusedBackgroundColor;
    for (UIButton *button in self.buttons)
        [button setBackgroundImage:[UIImage sy_imageWithColor:focusedBackgroundColor]
                          forState:UIControlStateFocused];
}
#endif

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self updateSeparatorColors];
    for (UIButton *button in self.buttons)
    {
        [button setTitleColor:tintColor forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage sy_imageWithColor:self.tintColor]
                          forState:UIControlStateSelected];
        
        [button setBackgroundImage:[UIImage sy_imageWithColor:[self.tintColor colorWithAlphaComponent:.2]]
                          forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage sy_imageWithColor:[self.tintColor colorWithAlphaComponent:.7]]
                          forState:(UIControlStateHighlighted|UIControlStateSelected)];
    }
    
    for (UIView *separator in self.separators)
        [separator setBackgroundColor:self.tintColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [self updateSeparatorColors];
    for (UIButton *button in self.buttons)
    {
        [button setBackgroundColor:[UIColor clearColor]];
        [button setBackgroundImage:[UIImage sy_imageWithColor:self.backgroundColor]
                          forState:UIControlStateNormal];
        if (TARGET_OS_TV)
        {
            [button setBackgroundImage:[UIImage sy_imageWithColor:self.backgroundColor]
                              forState:UIControlStateSelected];
        }
        else
        {
            [button setTitleColor:self.backgroundColor
                         forState:UIControlStateSelected];
            [button setTitleColor:self.backgroundColor
                         forState:(UIControlStateSelected | UIControlStateHighlighted)];
        }
    }
}

#pragma mark Font

- (void)setFont:(UIFont *)font
{
    self->_font = font;
    for (NSUInteger i = 0; i < self.buttons.count; ++i)
    {
        UIButton *button = self.buttons[i];
        if (font)
            [button setAttributedTitle:[[NSAttributedString alloc] initWithString:self.titles[i]
                                                                       attributes:@{NSFontAttributeName:font}]
                              forState:UIControlStateNormal];
        else
            [button setTitle:self.titles[i] forState:UIControlStateNormal];
    }
}

#pragma mark Index

- (void)setSelectedIndexes:(NSIndexSet *)selectedIndexes
{
    if (!self.allowMultipleSelection && selectedIndexes.count > 1)
    {
        [self setSelectedIndexes:[NSIndexSet indexSetWithIndex:selectedIndexes.firstIndex]];
        return;
    }
    
    self->_selectedIndexes = selectedIndexes;
    
    [self updateSeparatorColors];
    
    for (NSUInteger i = 0; i < self.buttons.count; ++i)
    {
        UIButton *button = self.buttons[i];
        [button setSelected:[selectedIndexes containsIndex:i]];
    }
}

#pragma mark - Metrics

- (void)setLineWidth:(CGFloat)lineWidth
{
    self->_lineWidth = lineWidth;
    
    [self.layer setBorderWidth:lineWidth];
    for (NSLayoutConstraint *constraint in self.separatorWidthConstraints)
        [constraint setConstant:lineWidth];
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
            [equalWidthsConstraints addObject:
             [NSLayoutConstraint sy_equalConstraintWithItems:@[self.buttons[i], self.buttons.firstObject]
                                                   attribute:NSLayoutAttributeWidth
                                                      offset:0]];
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

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width, (self.height >= 1. ? self.height : size.height));
}

#pragma mark - Actions

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
        [button setTitle:title forState:UIControlStateNormal];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventPrimaryActionTriggered];
        [button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [button setContentEdgeInsets:UIEdgeInsetsMake(SYSegmentedControlMarginInsets,
                                                      SYSegmentedControlMarginInsets,
                                                      SYSegmentedControlMarginInsets,
                                                      SYSegmentedControlMarginInsets)];
        [button setBackgroundColor:[UIColor grayColor]];
        [buttons addObject:button];
        [self addSubview:button];
    }
    
    for (NSUInteger i = 0; i < buttons.count; ++i)
    {
        UIButton *button = buttons[i];
        
        [self addConstraint:
         [NSLayoutConstraint sy_equalConstraintWithItems:@[button, self]
                                               attribute:NSLayoutAttributeTop
                                                  offset:0.]];
        
        [self addConstraint:
         [NSLayoutConstraint sy_equalConstraintWithItems:@[button, self]
                                               attribute:NSLayoutAttributeBottom
                                                  offset:0.]];
        
        if (i == 0)
        {
            [self addConstraint:
             [NSLayoutConstraint sy_equalConstraintWithItems:@[button, self]
                                                   attribute:NSLayoutAttributeLeft
                                                      offset:SYSegmentedControlMarginBetween]];
        }
        else
        {
            [self addConstraint:
             [NSLayoutConstraint sy_constraintWithItems:@[buttons[i-1], button]
                                             attribute1:NSLayoutAttributeRight
                                             attribute2:NSLayoutAttributeLeft
                                              relatedBy:NSLayoutRelationEqual
                                                 offset:-SYSegmentedControlMarginBetween]];
        }

        if (i == buttons.count - 1)
        {
            [self addConstraint:
             [NSLayoutConstraint sy_equalConstraintWithItems:@[button, self]
                                                   attribute:NSLayoutAttributeRight
                                                      offset:-SYSegmentedControlMarginBetween]];
        }
    }

#if !TARGET_OS_TV
    NSMutableArray <UIView *> *separators = [NSMutableArray arrayWithCapacity:buttons.count];
    NSMutableArray <NSLayoutConstraint *> *separatorWidthConstraint = [NSMutableArray arrayWithCapacity:buttons.count];
    
    for (NSUInteger i = 1; i < buttons.count; ++i)
    {
        UIView *separator = [[UIView alloc] init];
        [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [separators addObject:separator];
        
        [self addSubview:separator];
        
        [self addConstraint:
         [NSLayoutConstraint sy_equalConstraintWithItems:@[separator, self]
                                               attribute:NSLayoutAttributeTop
                                                  offset:0]];
        [self addConstraint:
         [NSLayoutConstraint sy_equalConstraintWithItems:@[separator, self]
                                               attribute:NSLayoutAttributeBottom
                                                  offset:0]];
        [self addConstraint:
         [NSLayoutConstraint sy_equalConstraintWithItems:@[separator, buttons[i]]
                                              attribute1:NSLayoutAttributeCenterX
                                              attribute2:NSLayoutAttributeLeft
                                                  offset:0]];

        [separatorWidthConstraint addObject:
         [NSLayoutConstraint constraintWithItem:separator
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.
                                       constant:self.lineWidth]];

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
    
#if TARGET_OS_TV
    [self setFocusedBackgroundColor:self.focusedBackgroundColor];
    [self setFocusedTextColor:self.focusedTextColor];
    [self setSelectedTextColor:self.selectedTextColor];
    [self setTextColor:self.textColor];
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

@implementation NSLayoutConstraint (SYKit)

+ (instancetype)sy_equalConstraintWithItems:(NSArray *)items
                                  attribute:(NSLayoutAttribute)attribute
                                     offset:(CGFloat)offset
{
    return [self sy_constraintWithItems:items
                             attribute1:attribute
                             attribute2:attribute
                              relatedBy:NSLayoutRelationEqual
                                 offset:offset];
}

+ (instancetype)sy_equalConstraintWithItems:(NSArray *)items
                                 attribute1:(NSLayoutAttribute)attribute1
                                 attribute2:(NSLayoutAttribute)attribute2
                                     offset:(CGFloat)offset
{
    return [self sy_constraintWithItems:items
                             attribute1:attribute1
                             attribute2:attribute2
                              relatedBy:NSLayoutRelationEqual
                                 offset:offset];
}

+ (instancetype)sy_constraintWithItems:(NSArray *)items
                             attribute:(NSLayoutAttribute)attribute
                             relatedBy:(NSLayoutRelation)relation
                                offset:(CGFloat)offset
{
    return [self sy_constraintWithItems:items
                             attribute1:attribute
                             attribute2:attribute
                              relatedBy:relation
                                 offset:offset];
}

+ (instancetype)sy_constraintWithItems:(NSArray *)items
                            attribute1:(NSLayoutAttribute)attribute1
                            attribute2:(NSLayoutAttribute)attribute2
                             relatedBy:(NSLayoutRelation)relation
                                offset:(CGFloat)offset
{
    NSAssert(items.count == 2, @"Two items needed to create this constraint");
    
    return [self constraintWithItem:items.firstObject
                          attribute:attribute1
                          relatedBy:relation
                             toItem:items.lastObject
                          attribute:attribute2
                         multiplier:1
                           constant:offset];
}

@end


//
//  JLActionSheet.m
//  JLActionSheet
//
//  Created by Jason Loewy on 1/31/13.
//  Copyright (c) 2013 Jason Loewy. All rights reserved.
//

#import "JLActionSheet.h"
#import <QuartzCore/QuartzCore.h>

#import "JLActionButton.h"


@interface JLActionSheet ()

/// Action Objects
@property (nonatomic, strong) id<JLActionSheetDelegate> delegate;

/// UI Instance Objects
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cancelTitle;
@property (nonatomic, strong) UIImage *cancelImage;
@property (nonatomic, strong) NSArray  *buttonTitles;
@property (nonatomic, strong) NSArray *buttonImages;

/// Display Containers
@property (nonatomic, strong) UIPopoverController *popoverController;

@end

@implementation JLActionSheet

/// UI Objects
static const CGFloat kActionButtonHeight = 60.0f;

/// Display Macros
static const CGFloat kBGFadeOpacity = 0.3f;

/// Animation Macros
static const NSTimeInterval kBGFadeDuration = 0.2;

#pragma mark - Initialization Methods

const NSInteger cancelButtonTag      = 9382;
const NSInteger buttonParentsViewTag = 28453;
const NSInteger tapBGViewTag         = 4292;

- (instancetype) initWithTitle:(NSString *)title
                      delegate:(id<JLActionSheetDelegate>)delegate
             cancelButtonTitle:(NSString *)cancelTitle
             otherButtonTitles:(NSArray *)buttonTitles
{
    return
    [self initWithTitle:title
               delegate:delegate
      cancelButtonTitle:cancelTitle
      cancelButtonImage:nil
           buttonTitles:buttonTitles
              andImages:nil];
}

- (instancetype) initWithTitle:(NSString *)title
                      delegate:(id<JLActionSheetDelegate>)delegate
             cancelButtonTitle:(NSString *)cancelTitle
             cancelButtonImage:(UIImage *)cancelImage
                  buttonTitles:(NSArray *)buttonTitles
                     andImages:(NSArray *)images
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _title              = title;
    _cancelTitle        = cancelTitle;
    _delegate           = delegate;
    _cancelButtonIndex  = -1;
    _cancelImage        = cancelImage;
    _buttonTitles       = buttonTitles.reverseObjectEnumerator.allObjects;
    _buttonImages       = images.reverseObjectEnumerator.allObjects;

    [self setBackgroundColor:[UIColor clearColor]];
    [self setStyle:JLSTYLE_MULTIFON];
    [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self setAutoresizesSubviews:YES];

    // Create the background clear tap responder view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(dismissActionSheet:)];
    UIView *tapBGView                  = [[UIView alloc] initWithFrame:self.frame];
    tapBGView.tag                      = tapBGViewTag;

    [tapBGView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:kBGFadeOpacity]];
    [tapBGView addGestureRecognizer:tapGesture];
    [tapBGView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self addSubview:tapBGView];

    return self;
}

+ (instancetype) sheetWithTitle:(NSString *)title
                       delegate:(id<JLActionSheetDelegate>)delegate
              cancelButtonTitle:(NSString *)cancelTitle
              otherButtonTitles:(NSArray *)buttonTitles
{
    return [[JLActionSheet alloc] initWithTitle:title
                                       delegate:delegate
                              cancelButtonTitle:cancelTitle
                              otherButtonTitles:buttonTitles];
}

+ (instancetype) sheetWithTitle:(NSString *)title
                       delegate:(id<JLActionSheetDelegate>)delegate
              cancelButtonTitle:(NSString *)cancelTitle
              cancelButtonImage:(UIImage *)cancelImage
                   buttonTitles:(NSArray *)buttonTitles
                      andImages:(NSArray *)images
{
    return [[JLActionSheet alloc] initWithTitle:title
                                       delegate:delegate
                              cancelButtonTitle:cancelTitle
                              cancelButtonImage:cancelImage
                                   buttonTitles:buttonTitles
                                      andImages:images];
}

#pragma mark - Presentation Methods

- (UIView*) layoutButtonsWithTitle:(BOOL) allowTitle
{
    CGFloat titleOffset                 = (_title == nil || !allowTitle) ? 0 : 20;
    if (!self.customStyle) {
        self.customStyle = [[JLActionSheetStyle alloc] initWithStyle:_style];
    }
    CGFloat buttonHeight                = kActionButtonHeight;
    NSInteger buttonCount               = _cancelTitle ? (_buttonTitles.count + 1) : _buttonTitles.count;
    CGFloat parentViewHeight            = ((buttonHeight * buttonCount) + titleOffset);
    UIView* buttonParentView            = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                   (CGRectGetHeight(self.bounds)
                                                                                    - parentViewHeight),
                                                                                   CGRectGetWidth(self.bounds),
                                                                                   parentViewHeight)];
    CGFloat currentButtonTop            = buttonParentView.bounds.size.height - buttonHeight;
    CGFloat currentButtonTag            = 0;
    
    if (_cancelTitle)
    {
        JLActionButton* cancelButton    = [JLActionButton buttonWithStyle:self.customStyle title:_cancelTitle isCancel:YES];
        cancelButton.tag                = currentButtonTag++;
        _cancelButtonIndex              = cancelButton.tag;
        
        [cancelButton.titleLabel setFont:[self buttonFont]];
        cancelButton.imageEdgeInsets = self.imageInsets;
        cancelButton.titleEdgeInsets = self.titleInsets;
        [cancelButton setTitleColor:[self cancelButtonTitleColor]
                           forState:UIControlStateNormal];
        [cancelButton setContentHorizontalAlignment:[self textAlignment]];

        if (self.cancelImage) {
            [cancelButton setImage:self.cancelImage
                          forState:UIControlStateNormal];
        }
        [cancelButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setFrame:CGRectMake(0, currentButtonTop, CGRectGetWidth(buttonParentView.bounds), buttonHeight)];
        [buttonParentView addSubview:cancelButton];
        
        currentButtonTop -= buttonHeight;
    }
    
    for (NSString* currentButtonTitle in _buttonTitles)
    {
        JLActionButton* currentActionButton = [JLActionButton buttonWithStyle:self.customStyle title:currentButtonTitle isCancel:NO];
        currentActionButton.tag             = currentButtonTag++;
        
        [currentActionButton.titleLabel setFont:[self buttonFont]];
        currentActionButton.imageEdgeInsets = self.imageInsets;
        currentActionButton.titleEdgeInsets = self.titleInsets;
        [currentActionButton setTitleColor:[self buttonTitleColor]
                                  forState:UIControlStateNormal];
        [currentActionButton setContentHorizontalAlignment:[self textAlignment]];

        NSUInteger ind = currentActionButton.tag - 1;
        if (self.buttonImages && self.buttonImages.count > ind) {
            [currentActionButton setImage:self.buttonImages[ind]
                                 forState:UIControlStateNormal];
        }
        [currentActionButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [currentActionButton setFrame:CGRectMake(0, currentButtonTop, CGRectGetWidth(buttonParentView.bounds), buttonHeight)];
        [buttonParentView addSubview:currentActionButton];
        
        currentButtonTop -= buttonHeight;
    }
    
    // Handle creating the title object if there is a title provided
    if (_title.length > 0 && allowTitle)
    {
        [buttonParentView setBackgroundColor:[self.customStyle getBGColorHighlighted:NO]];
        [((JLActionButton*)[buttonParentView.subviews lastObject]) configureForTitle];
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(buttonParentView.bounds), titleOffset)];        
        [titleLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[self titleFont]];
        [titleLabel setTextColor:[self titleColor]];
        [titleLabel setShadowOffset:CGSizeMake(0, -1.0)];
        [titleLabel setShadowColor:[self.customStyle getTextShadowColor:NO]];
        [titleLabel setTextAlignment:self.titleAlignment];
        [titleLabel setText:_title];
        
        [buttonParentView addSubview:titleLabel];
    }
    [buttonParentView setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth)];
    [buttonParentView.layer setShadowColor:[UIColor blackColor].CGColor];
    [buttonParentView.layer setShadowOffset:CGSizeMake(0, -3.0f)];
    [buttonParentView.layer setShadowOpacity:.3f];
    [buttonParentView.layer setShadowRadius:4.0f];
    CGPathRef path = [UIBezierPath bezierPathWithRect:buttonParentView.bounds].CGPath;
    [buttonParentView.layer setShadowPath:path];
    return buttonParentView;
}

/*
 Repsonsible for presenting the JLActionSheet from the parentview specified
 Must first make sure that the sizing and origin of the JLActionSheet is correct
 PARAMETERS:
 parentView -> The view that the JLActionSheet is being presented on
 */
- (void) showInView:(UIView *)parentView
{
    if (!parentView) {
      parentView = [UIApplication sharedApplication].keyWindow.subviews.lastObject;
    }

    [self setFrame:parentView.bounds];
    
    // Create the parent UIView that houses the JLActionButtons
    UIView* buttonsParentView   = [self layoutButtonsWithTitle:YES];
    buttonsParentView.tag       = buttonParentsViewTag;
    CGPoint originalCenter      = buttonsParentView.center;
    [buttonsParentView setCenter:CGPointMake(buttonsParentView.center.x,
                                             (CGRectGetHeight(self.bounds)
                                              + (CGRectGetHeight(buttonsParentView.bounds) / 2)))];
    [self addSubview:buttonsParentView];
    
    [self setAlpha:0.0f];
    [parentView addSubview:self];
    [UIView animateWithDuration:kBGFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            [self setAlpha:1.0f];
                            [buttonsParentView setCenter:originalCenter];
                        } completion:nil];
}

/*
 Convienence method for displaying on the view of a UIViewController
 Calls showInView: with the view controllers main view
 PARAMETERS:
 parentViewController -> The ViewController that the JLActionSheet will be presented on
 */
- (void) showOnViewController:(UIViewController *)parentViewController { [self showInView:parentViewController.view]; }


- (void) showFromBarItem:(UIBarButtonItem *)barButton onView:(UIView *)parentView
{
    
    // Only show from bar button item in a popover if coming from iPad
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        [self showInView:parentView];
    else
    {
        BOOL allowTitle                 = (_title.length > 0) ? NO : YES;
        UIView* buttonsParentView       = [self layoutButtonsWithTitle:allowTitle];
        UIViewController* actionSheetVC = [[UIViewController alloc] init];
        actionSheetVC.view              = buttonsParentView;
        
        if (_title.length > 0)
        {
            // Enter here if there is a title for this actionsheet
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:actionSheetVC];
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            [_popoverController setPopoverContentSize:CGSizeMake(_popoverController.popoverContentSize.width, buttonsParentView.bounds.size.height + (navController.navigationBar.bounds.size.height - 10))];
            
            // Initialize and configure the navigation title item
            UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _popoverController.popoverContentSize.width, 34)];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [titleLabel setTextAlignment:self.titleAlignment];
            [titleLabel setShadowColor:[UIColor blackColor]];
            [titleLabel setShadowOffset:CGSizeMake(0, -.5)];
            
            [titleLabel setText:_title];
            [actionSheetVC.navigationItem setTitleView:titleLabel];
        }
        else
        {
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:actionSheetVC];
            [_popoverController setPopoverContentSize:CGSizeMake(_popoverController.popoverContentSize.width, buttonsParentView.bounds.size.height)];
        }
        
        [_popoverController presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) showFromBarItem:(UIBarButtonItem *)barButton
        onViewController:(UIViewController *)parentViewController
{
    [self showFromBarItem:barButton
                   onView:parentViewController.view];
}

#pragma mark - Dismissal Methods

/*
 Repsonsible for hiding the action sheet
 This is the final method that is called in the lifecycle of the JLAction sheet
 PARAMETERS:
 id -> The object that is triggering the closing of the JLActionsheet
 */
- (void) dismissActionSheet:(id) sender
{
    if (!_popoverController)
    {
        UIView* buttonsParentView = [self viewWithTag:buttonParentsViewTag];
        [UIView animateWithDuration:(kBGFadeDuration + .05) delay:0.175 options:UIViewAnimationOptionCurveLinear animations:^{
            [[self viewWithTag:tapBGViewTag] setAlpha:0.0f];
            [buttonsParentView setCenter:CGPointMake(buttonsParentView.center.x, (CGRectGetHeight(self.bounds) + (CGRectGetHeight(buttonsParentView.bounds) / 2)))];
        }completion:^(BOOL finished)
        {
            [self removeFromSuperview];
            
            //----
            // If a didDismissBLock has been provided fire that
            // If not check if the delegate responds to the didDismiss action and fire that
            // blocks take precedence over delegate since they must be explicitely provided
            //----
            if (didDismissBlock)
                didDismissBlock(self, ((JLActionButton*)sender).tag);
            else if ([sender isKindOfClass:[JLActionButton class]] && [_delegate respondsToSelector:@selector(actionSheet:didDismissButtonAtIndex:)])
                    [_delegate actionSheet:self didDismissButtonAtIndex:((JLActionButton*)sender).tag];
        }];
    }
    else
    {
        [_popoverController dismissPopoverAnimated:YES];
        
        //----
        // If a didDismissBLock has been provided fire that
        // If not check if the delegate responds to the didDismiss action and fire that
        // blocks take precedence over delegate since they must be explicitely provided
        //----
        if (didDismissBlock)
            didDismissBlock(self, ((JLActionButton*)sender).tag);
        else if ([_delegate respondsToSelector:@selector(actionSheet:didDismissButtonAtIndex:)])
                [_delegate actionSheet:self didDismissButtonAtIndex:((JLActionButton*)sender).tag];
    }
}

/*
 Responsible for reacting to when one of the JLActionButtons are clicked
 Calls the delegate method so the delegate can react and starts the dismissal process
 PARAMETERS:
 sender -> The JLActionButton that was clicked
 */
- (void) buttonClicked:(JLActionButton*) sender
{
    //----
    // If a clickedButtonBlock has been provided fire that
    // If not check if the delegate responds to the clickedButton action and fire that
    // blocks take precedence over delegate since they must be explicitely provided
    //----
    if (clickedButtonBlock)
        clickedButtonBlock(self, sender.tag);
    else if ([_delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
            [_delegate actionSheet:self clickedButtonAtIndex:sender.tag];
    
    [self dismissActionSheet:sender];
}

#pragma mark - Accessor Methods

- (void)setCustomStyle:(JLActionSheetStyle *)customStyle
{
    if (self.customStyle == customStyle) {
        return;
    }
    self.style = JLSTYLE_CUSTOM;
    self->_customStyle = customStyle;
}

- (NSString*) titleAtIndex:(NSInteger)buttonIndex
{
    NSString* title;
    if (!_cancelTitle)
        title = _buttonTitles[buttonIndex];
    else
        title = (buttonIndex == _cancelButtonIndex) ? _cancelTitle : _buttonTitles[buttonIndex - 1];
    
    return title;
}

/*
 Responsible for determining if the JLActionsheet is currently being presented or not
 */
- (BOOL) isVisible
{
    if (_popoverController)
        return [_popoverController isPopoverVisible] ? YES : NO;
    
    return (self.superview == nil) ? NO : YES;
}

#pragma mark - UI Mutator Methods

/*
 Responsible for configuring if the tap to dismiss is permitted on the background view
 PARAMETERS:
 allowTap -> The flag that determines if the tap to dismiss is allowed or not
 */
- (void) allowTapToDismiss:(BOOL)allowTap
{
    UIView* tapBGView = [self viewWithTag:tapBGViewTag];
    tapBGView.gestureRecognizers = @[];
    
    if (allowTap)
    {
        UITapGestureRecognizer* tapGesture  = [[UITapGestureRecognizer
                                                alloc] initWithTarget:self
                                                               action:@selector(dismissActionSheet:)];
        [tapBGView addGestureRecognizer:tapGesture];
    }
}

#pragma mark - Action Mutator Methods

/*
 Responsible for setting the functionality of the clickedButtonBlock
 This will then be used in place over a delegate call when it is set
 PARAMETERS
 actionBlock -> The block of code that will be used for the clickedButtonBlock
 */
- (void) setClickedButtonBlock:(JLActionBlock)actionBlock
{
    clickedButtonBlock = actionBlock;
}

/*
 Responsible for setting the functionality of teh didDismissBlock
 This will then be used in place over a delegate call when it is set
 PARAMETER:
 actionBlock -> The block of code that will be used for the didDismissBlock
 */
- (void) setDidDismissBlock:(JLActionBlock)actionBlock
{
    didDismissBlock = actionBlock;
}

#pragma mark - Font accessors

- (UIFont *)titleFont
{
    return _titleFont ? _titleFont : [UIFont systemFontOfSize:14.];
}

- (UIColor *)titleColor
{
    return _titleColor ? _titleColor : [self.customStyle getTextColor:NO];
}

- (UIFont *)buttonFont
{
    return _buttonFont ? _buttonFont : [UIFont systemFontOfSize:20.];
}

- (UIColor *)buttonTitleColor
{
    return _buttonTitleColor ? _buttonTitleColor : [self.customStyle getTextColor:NO];
}

- (UIColor *)cancelButtonTitleColor
{
    return _cancelButtonTitleColor ? _cancelButtonTitleColor : [self.customStyle getTextColor:YES];
}

- (NSTextAlignment)titleAlignment
{
    return _titleAlignment ? _titleAlignment : NSTextAlignmentCenter;
}

- (UIControlContentHorizontalAlignment)textAlignment
{
    return _textAlignment ? _textAlignment : UIControlContentHorizontalAlignmentLeft;
}

@end

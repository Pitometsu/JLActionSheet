//
//  JLActionSheet.h
//  JLActionSheet
//
//  Created by Jason Loewy on 1/31/13.
//  Copyright (c) 2013 Jason Loewy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JLActionSheetStyle.h"


@class JLActionSheet;


@protocol JLActionSheetDelegate <NSObject>

@optional
- (void) actionSheet:(JLActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void) actionSheet:(JLActionSheet*)actionSheet didDismissButtonAtIndex:(NSInteger)buttonIndex;

@end


typedef void(^JLActionBlock)(JLActionSheet* actionSheet, NSInteger buttonIndex);


@interface JLActionSheet : UIView
{
    JLActionBlock clickedButtonBlock;
    JLActionBlock didDismissBlock;
}

// Data Objects
@property (readonly) NSInteger cancelButtonIndex;

// UI Objects
@property (nonatomic, assign) JLStyle style;
@property (nonatomic, strong) JLActionSheetStyle *customStyle;

//pt

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *buttonFont;
@property (nonatomic, strong) UIColor *buttonTitleColor;
@property (nonatomic, strong) UIColor *cancelButtonTitleColor;
@property (nonatomic, assign) NSTextAlignment titleAlignment;
@property (nonatomic, assign) UIControlContentHorizontalAlignment textAlignment;
@property (nonatomic, assign) UIEdgeInsets titleInsets;
@property (nonatomic, assign) UIEdgeInsets imageInsets;

/// Initialization Methods
+ (instancetype) sheetWithTitle:(NSString*) title
                       delegate:(id<JLActionSheetDelegate>) delegate
              cancelButtonTitle:(NSString*) cancelTitle
              otherButtonTitles:(NSArray*) buttonTitles;
+ (instancetype) sheetWithTitle:(NSString *)title
                       delegate:(id<JLActionSheetDelegate>)delegate
              cancelButtonTitle:(NSString *)cancelTitle
              cancelButtonImage:(UIImage *)cancelImage
                   buttonTitles:(NSArray *)buttonTitles
                      andImages:(NSArray *)images;
- (instancetype) initWithTitle:(NSString*) title
                      delegate:(id<JLActionSheetDelegate>) delegate
             cancelButtonTitle:(NSString*) cancelTitle
             otherButtonTitles:(NSArray*) buttonTitles;
- (instancetype) initWithTitle:(NSString *)title
                      delegate:(id<JLActionSheetDelegate>)delegate
             cancelButtonTitle:(NSString *)cancelTitle
             cancelButtonImage:(UIImage *)cancelImage
                  buttonTitles:(NSArray *)buttonTitles
                     andImages:(NSArray *)images;

/// Action Block Methods
- (void) setClickedButtonBlock:(JLActionBlock) actionBlock;
- (void) setDidDismissBlock:(JLActionBlock) actionBlocks;

/// Presentation Methods
- (void) showInView:(UIView*) parentView;
- (void) showOnViewController:(UIViewController*) parentViewController;
- (void) showFromBarItem:(UIBarButtonItem*) barButton onView:(UIView*) parentView;
- (void) showFromBarItem:(UIBarButtonItem*) barButton onViewController:(UIViewController*) parentViewController;

/// Accessor Methods
- (NSString*) titleAtIndex:(NSInteger)buttonIndex;
- (BOOL) isVisible;

/// UI Mutator Methods
- (void) allowTapToDismiss:(BOOL) allowTap;

@end

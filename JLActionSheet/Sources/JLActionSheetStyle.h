//
//  JLActionSheetStyle.h
//  JLActionSheet
//
//  Created by Jason Loewy on 2/1/13.
//  Copyright (c) 2013 Jason Loewy. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum JLStyle {
    JLSTYLE_STEEL,
    JLSTYLE_SUPERCLEAN,
    JLSTYLE_CLEANBLUE,
    JLSTYLE_FERRARI,
    JLSTYLE_MULTIFON,
    JLSTYLE_CUSTOM
} JLStyle;


@interface JLActionSheetStyle : NSObject

// Assumes input like "00FF00" (RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString;

/// Border Colors
@property (nonatomic, strong, readonly) UIColor* lightBorderColor;
@property (nonatomic, strong, readonly) UIColor* darkBorderColor;

- (instancetype) initWithStyle:(JLStyle) style;
- (instancetype) initWithBackgroundColor:(UIColor *)backgroundColor
              highlightedBackgroundColor:(UIColor *)highlightedBackgroundColor
                   cancelBackgroundColor:(UIColor *)cancelBackgroundColor
        cancelHighlightedBackgroundColor:(UIColor *)cancelHighlightedBackgroundColor
                         darkBorderColor:(UIColor *)darkBorderColor
                        lightBorderColor:(UIColor *)lightBorderColor
                               textColor:(UIColor *)textColor
                         textShadowColor:(UIColor *)textShadowColor
                         cancelTextColor:(UIColor *)cancelTextColor
                   cancelTextShadowColor:(UIColor *)cancelTextShadowColor;

- (UIColor*) getBGColorHighlighted:(BOOL) highlighted;
- (UIColor*) getCancelBGColorHighlighted:(BOOL) highlighted;

/// Text Color Accessors
- (UIColor*) getTextColor:(BOOL) isCancel;
- (UIColor*) getTextShadowColor:(BOOL) isCancel;

@end

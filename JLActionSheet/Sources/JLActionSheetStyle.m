//
//  JLActionSheetStyle.m
//  JLActionSheet
//
//  Created by Jason Loewy on 2/1/13.
//  Copyright (c) 2013 Jason Loewy. All rights reserved.
//

#import "JLActionSheetStyle.h"


UIColor *Color(CGFloat r,
               CGFloat g,
               CGFloat b,
               CGFloat a
               ) {
    return
    [UIColor colorWithRed:(r / 255.f)
                    green:(g / 255.f)
                     blue:(b / 255.f)
                    alpha:a];
}


@interface JLActionSheetStyle ()

@property (nonatomic, strong) UIColor* standardBGColor;
@property (nonatomic, strong) UIColor* highlightedBGColor;

@property (nonatomic, strong) UIColor* cancelBGColor;
@property (nonatomic, strong) UIColor* cancelHighlightedBG;

/// Font Colors
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, strong) UIColor* textShadowColor;
@property (nonatomic, strong) UIColor* cancelTextColor;
@property (nonatomic, strong) UIColor* cancelTextShadowColor;

@end


@implementation JLActionSheetStyle

// Assumes input like "00FF00" (RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.f
                           green:((CGFloat)((rgbValue & 0x00FF00) >>  8)) / 255.f
                            blue:((CGFloat)((rgbValue & 0x0000FF) >>  0)) / 255.f
                           alpha:1.f];
}

- (id) initWithStyle:(JLStyle)style
{
    if (self =[super init])
    {
        if (style == JLSTYLE_STEEL)
        {
            _standardBGColor        = Color(59, 59, 59, 1.0);
            _highlightedBGColor     = Color(20, 20, 20, 1.0);
            
            _cancelBGColor          = Color(44, 44, 44, 1.0);
            _cancelHighlightedBG    = Color(20, 20, 20, 1.0);
            
            // Set the border colors
            _darkBorderColor        = Color(15, 15, 15, 1.0);
            _lightBorderColor       = Color(66, 66, 66, 1.0);
            
            _textColor              = [UIColor whiteColor];
            _textShadowColor        = [UIColor colorWithWhite:.05 alpha:1.0];
            
            _cancelTextColor        = _textColor;
            _cancelTextShadowColor  = _textShadowColor;
        }
        else if (style == JLSTYLE_SUPERCLEAN || style == JLSTYLE_CLEANBLUE)
        {
            _standardBGColor        = Color(220, 220, 220, 1.0);
            _highlightedBGColor     = Color(205, 205, 205, 1.0);
            
            if (style == JLSTYLE_SUPERCLEAN)
            {
                _cancelBGColor          = Color(165, 24, 13, 1.0);
                _cancelHighlightedBG    = Color(135, 20, 9, 1.0);
            }
            else
            {
                _cancelBGColor          = Color(38, 119, 250, 1.0);
                _cancelHighlightedBG    = Color(31, 105, 225, 1.0);
            }
                
            // Set the border colors
            _darkBorderColor        = Color(0, 0, 0, .2);
            _lightBorderColor       = Color(255, 255, 255, .2);
            
            _textColor              = Color(40, 40, 40, 1.0);
            _textShadowColor        = Color(220, 220, 220, .75);
            
            _cancelTextColor        = [UIColor whiteColor];
            _cancelTextShadowColor  = [UIColor colorWithWhite:.05 alpha:1.0];
        }
        else if (style == JLSTYLE_FERRARI)
        {
            _standardBGColor        = Color(232, 44, 56, 1.0);
            _highlightedBGColor     = Color(191, 26, 42, 1.0);
            
            _cancelBGColor          = Color(211, 34, 50, 1.0);
            _cancelHighlightedBG    = Color(191, 26, 42, 1.0);
            
            // Set the border colors
            _darkBorderColor        = Color(189, 31, 45, 1.0);
            _lightBorderColor       = Color(208, 40, 50, 1.0);
            
            
            _textColor              = Color(10, 11, 12, 1.0);
            _textShadowColor        = [UIColor clearColor];
            
            _cancelTextColor        = _textColor;
            _cancelTextShadowColor  = _textShadowColor;
            
        } else if (style == JLSTYLE_MULTIFON) {
            
            _standardBGColor        = [UIColor whiteColor];
            _highlightedBGColor     = Color(204., 204., 204., 1.);
            
            _cancelBGColor          = Color(240., 240., 240., 1.);
            _cancelHighlightedBG    = Color(200., 200., 200., 1.);
            
            _darkBorderColor        = Color(0, 0, 0, .2);
            _lightBorderColor       = Color(255, 255, 255, .2);
            
            _textColor              = Color(40, 40, 40, 1.0);
            _textShadowColor        = Color(220, 220, 220, .75);
            
            _cancelTextColor        = Color(68., 38., 107., 1.);
            _cancelTextShadowColor  = [UIColor clearColor];
        }
    }
    
    return self;
}

- (instancetype) initWithBackgroundColor:(UIColor *)backgroundColor
              highlightedBackgroundColor:(UIColor *)highlightedBackgroundColor
                   cancelBackgroundColor:(UIColor *)cancelBackgroundColor
        cancelHighlightedBackgroundColor:(UIColor *)cancelHighlightedBackgroundColor
                         darkBorderColor:(UIColor *)darkBorderColor
                        lightBorderColor:(UIColor *)lightBorderColor
                               textColor:(UIColor *)textColor
                         textShadowColor:(UIColor *)textShadowColor
                         cancelTextColor:(UIColor *)cancelTextColor
                   cancelTextShadowColor:(UIColor *)cancelTextShadowColor
{
    self = [super init];

    if (!self) {
        return nil;
    }
    self->_standardBGColor        = backgroundColor;
    self->_highlightedBGColor     = highlightedBackgroundColor;
    
    self->_cancelBGColor          = cancelBackgroundColor;
    self->_cancelHighlightedBG    = cancelHighlightedBackgroundColor;
    
    // Set the border colors
    self->_darkBorderColor        = darkBorderColor;
    self->_lightBorderColor       = lightBorderColor;
    
    self->_textColor              = textColor;
    self->_textShadowColor        = textShadowColor;
    
    self->_cancelTextColor        = cancelTextColor;
    self->_cancelTextShadowColor  = cancelTextShadowColor;

    return self;
}

#pragma mark - Style UIColor Accessor Methods


- (UIColor*) getBGColorHighlighted:(BOOL)highlighted
{
    return highlighted ? _highlightedBGColor : _standardBGColor;
}

- (UIColor*) getCancelBGColorHighlighted:(BOOL)highlighted
{
    return highlighted ? _cancelHighlightedBG : _cancelBGColor;
}

- (UIColor*) getTextColor:(BOOL) isCancel
{
    return isCancel ? _cancelTextColor : _textColor;
}

- (UIColor*) getTextShadowColor:(BOOL)isCancel
{
    return isCancel ? _cancelTextShadowColor : _textShadowColor;
}

@end

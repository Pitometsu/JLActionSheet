//
//  JLViewController.m
//  JLActionSheet
//
//  Created by Jason Loewy on 1/31/13.
//  Copyright (c) 2013 Jason Loewy. All rights reserved.
//

#import "JLViewController.h"

#import "JLActionSheet.h"


@interface JLViewController () <JLActionSheetDelegate>

@property (nonatomic, strong) JLActionSheet* actionSheet;

@property (weak, nonatomic) IBOutlet UISegmentedControl *itemCountSegmentController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *styleSegmentedController;
@property (weak, nonatomic) IBOutlet UISwitch *showCancelButton;
@property (weak, nonatomic) IBOutlet UISwitch *allowTapSwitch;

@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

// custom color text fields
@property (weak, nonatomic) IBOutlet UITextField *backgroundColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *highlightedBackgrodColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *cancelBackgroundColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *cancelHighlightedColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *darkBorderColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *lightBorderColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *textColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *textShadowColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *cancelTextColorTextField;
@property (weak, nonatomic) IBOutlet UITextField *cancelTextShadowColorTextField;

@end


@implementation JLViewController

#pragma mark - Demo Convenience Methods

- (IBAction)keyboardDonePressed:(id)sender
{
    [_titleTextField resignFirstResponder];
}

- (JLStyle)getSelectedStyle
{
    JLStyle selectedStyle;

    // Determine which style to be used
    if (_styleSegmentedController.selectedSegmentIndex == 0)
        selectedStyle = JLSTYLE_STEEL;
    else if (_styleSegmentedController.selectedSegmentIndex == 1)
        selectedStyle = JLSTYLE_SUPERCLEAN;
    else if (_styleSegmentedController.selectedSegmentIndex == 2)
        selectedStyle = JLSTYLE_FERRARI;
    else if (_styleSegmentedController.selectedSegmentIndex == 3)
        selectedStyle = JLSTYLE_CLEANBLUE;
    else
        selectedStyle = JLSTYLE_CUSTOM;

    return selectedStyle;
}

- (NSMutableArray*) getButtonTitles
{
    NSMutableArray* buttonTitles = [[NSMutableArray alloc] initWithCapacity:5];
    for (NSInteger i = 0; i < (_itemCountSegmentController.selectedSegmentIndex + 1); i++) {
        switch (i) {
            case 0:
                buttonTitles[0] = @"One";
                break;
            case 1:
                buttonTitles[1] = @"Two";
                break;
            case 2:
                buttonTitles[2] = @"Three";
                break;
            case 3:
                buttonTitles[3] = @"Four";
                break;
            case 4:
                buttonTitles[4] = @"Five";
                break;
            default:
                break;
        }
    }
    return buttonTitles;
}

#pragma mark - Presentation Methods

- (IBAction)presentInView:(id)sender
{
    [_titleTextField resignFirstResponder];
    
    NSMutableArray* buttonTitles = [self getButtonTitles];
    NSString* cancelTitle        = [_showCancelButton isOn] ? @"Cancel" : nil;
    NSString* sheetTitle         = (_titleTextField.text.length > 0) ? _titleTextField.text : nil;
    
    _actionSheet                 = [JLActionSheet sheetWithTitle:sheetTitle
                                                        delegate:self
                                               cancelButtonTitle:cancelTitle
                                               otherButtonTitles:buttonTitles];
    [_actionSheet allowTapToDismiss:[_allowTapSwitch isOn]];
    [self addStyle];
    [_actionSheet showOnViewController:self];
}

- (IBAction)presentFromNavBar:(UIBarButtonItem *)sender
{
    [_titleTextField resignFirstResponder];
    
    NSMutableArray* buttonTitles = [self getButtonTitles];
    NSString* cancelTitle        = [_showCancelButton isOn] ? @"Cancel" : nil;
    NSString* sheetTitle         = (_titleTextField.text.length > 0) ? _titleTextField.text : nil;
    
    _actionSheet                 = [JLActionSheet sheetWithTitle:sheetTitle
                                                        delegate:self
                                               cancelButtonTitle:cancelTitle
                                               otherButtonTitles:buttonTitles];
    [_actionSheet allowTapToDismiss:[_allowTapSwitch isOn]];
    [self addStyle];
    [_actionSheet showFromBarItem:sender onViewController:self];
}

- (void)addStyle
{
    JLStyle currentStyle = [self getSelectedStyle];

    if (currentStyle != JLSTYLE_CUSTOM) {
        self.actionSheet.style = currentStyle;
        return;
    }
    self.actionSheet.customStyle =
    [[JLActionSheetStyle alloc] initWithBackgroundColor:[JLActionSheetStyle colorFromHexString:self.backgroundColorTextField.text]
                             highlightedBackgroundColor:[JLActionSheetStyle colorFromHexString:self.highlightedBackgrodColorTextField.text]
                                  cancelBackgroundColor:[JLActionSheetStyle colorFromHexString:self.cancelBackgroundColorTextField.text]
                       cancelHighlightedBackgroundColor:[JLActionSheetStyle colorFromHexString:self.cancelHighlightedColorTextField.text]
                                        darkBorderColor:[JLActionSheetStyle colorFromHexString:self.darkBorderColorTextField.text]
                                       lightBorderColor:[JLActionSheetStyle colorFromHexString:self.lightBorderColorTextField.text]
                                              textColor:[JLActionSheetStyle colorFromHexString:self.textColorTextField.text]
                                        textShadowColor:[JLActionSheetStyle colorFromHexString:self.textShadowColorTextField.text]
                                        cancelTextColor:[JLActionSheetStyle colorFromHexString:self.cancelTextColorTextField.text]
                                  cancelTextShadowColor:[JLActionSheetStyle colorFromHexString:self.cancelTextShadowColorTextField.text]];
}

/*
 Shows how to use blocks with JLActionSheet
 Setting blocks make them take priority over delegate usage
 */
- (void)addExampleBlocks
{
    [_actionSheet setClickedButtonBlock:^(JLActionSheet* actionSheet, NSInteger buttonIndex) {
        NSLog(@"Call Back");
        NSLog(@"Clicked button title: %@", [actionSheet titleAtIndex:buttonIndex]);
    }];
    
    [_actionSheet setDidDismissBlock:^(JLActionSheet* actionSheet, NSInteger buttonIndex) {
        NSLog(@"Did Dismiss Block");
    }];
}

#pragma mark - JLActionSheet Delegate

// Called when the action button is initially clicked
- (void)   actionSheet:(JLActionSheet *)actionSheet
  clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked Button: %ld Title: %@", (long)buttonIndex,
          [actionSheet titleAtIndex:buttonIndex]);
    [_selectedLabel setText:[actionSheet titleAtIndex:buttonIndex]];
    if (buttonIndex == actionSheet.cancelButtonIndex)
        NSLog(@"Is cancel button");
}

// Called when the action button fully disappears from view
- (void)      actionSheet:(JLActionSheet *)actionSheet
  didDismissButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Did dismiss");
}

@end

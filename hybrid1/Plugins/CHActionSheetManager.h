//
//  CHActionSheetManager.h
//  Chatter
//
//  Created by Qingqing Liu on 4/5/12.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHActionSheetManagerDelegate <NSObject>
@required

/** Sent to the receiver when an actionsheet will be dismissed when entering the background.
  */
- (void)actionSheetWillBeDismissedForEnteringBackground:(UIActionSheet *)actionSheet;

@end

/** Singleton class to manage UIActionSheet instances.
 
 This class will manage UIActionSheet to ensure only one is visble at any given
 time and will dismiss current action sheet when app enters background on iPhone.
 */
@interface CHActionSheetManager : NSObject {
    UIActionSheet *_currentActionSheet;
    id<CHActionSheetManagerDelegate> _delegate;
}

/** Currently visible UIActionSheet instance.
 */
@property (nonatomic, retain) UIActionSheet *currentActionSheet;

/** Current delegate responsible for receiving notifications.
 
 @warning This property will automatically be unset when the releaseActionSheet
 message is sent.
 
 @see CHActionSheetManagerDelegate
 */
@property (nonatomic, assign) id<CHActionSheetManagerDelegate> delegate;

/** Returns the singleton instance.
 */
+ (CHActionSheetManager*)sharedInstance;

/** Create new UIActionSheet that will be managed by this ActionSheetManager.
 
 @warning This method returns a retained ActionSheet instance (retain count +1)
 */
// TODO: rename this method to denote it returns a retained object or otherwise refactor
- (UIActionSheet *) actionSheetWithTitle:(NSString*)title 
                                delegate:(id<UIActionSheetDelegate>) delegate
                       cancelButtonTitle:(NSString*)cancelTitle
                  destructiveButtonTitle:(NSString*)destructiveTitle
                       otherButtonTitles:(NSString *)otherButtonTitles, ...;

/** Release and dismiss the current action sheet.
 
 Invoking this method will automatically unset the delegate property.
 */
- (void)releaseActionSheet;

/** Dismiss current visible action sheet
 */
- (void)dismissVisibleActionSheet;

/** Indicates if the currentActionSheet is visible.
 
 @return `YES` if the actionsheet is visible, otherwise `NO`.
 */
- (BOOL)isActionSheetVisible;

@end

//
//  CHActionSheetManager.m
//  Chatter
//
//  Created by Qingqing Liu on 4/5/12.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import "CHActionSheetManager.h"
#import "ChatterSDKConstants.h"

@interface CHActionSheetManager ()
- (void)appEnterBackground;
@end

@implementation CHActionSheetManager
@synthesize currentActionSheet = _currentActionSheet;
@synthesize delegate = _delegate;

+ (CHActionSheetManager*)sharedInstance {
    static dispatch_once_t pred;
	static CHActionSheetManager *sharedInstance = nil;    
    dispatch_once(&pred, ^{
        sharedInstance = [[CHActionSheetManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(appEnterBackground)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
        }
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CHRelease(_currentActionSheet);
    [super dealloc];
}

- (void)releaseActionSheet {
    self.delegate = nil;
    [self dismissVisibleActionSheet];
    CHRelease(_currentActionSheet);
}

- (void)dismissVisibleActionSheet {
    if ([self isActionSheetVisible]) {
        // dismiss current action sheet if it is visible
        [self.currentActionSheet dismissWithClickedButtonIndex:self.currentActionSheet.cancelButtonIndex animated:NO];
        CHRelease(_currentActionSheet);
    }
}

- (BOOL)isActionSheetVisible {
    if (nil != self.currentActionSheet && [self.currentActionSheet isVisible]) {
        return YES;
    } else {
        return NO;
    }
}

// Waring: returns a retained instance, despite the method name
- (UIActionSheet *)actionSheetWithTitle:(NSString*)title 
                                delegate:(id<UIActionSheetDelegate>) delegate
                       cancelButtonTitle:(NSString*)cancelTitle
                  destructiveButtonTitle:(NSString*)destructiveTitle
                       otherButtonTitles:(NSString *)otherButtonTitles, ... {
    [self dismissVisibleActionSheet];
    self.delegate = nil;

    _currentActionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                      delegate:delegate
                                             cancelButtonTitle:cancelTitle
                                        destructiveButtonTitle:destructiveTitle
                                             otherButtonTitles:otherButtonTitles, nil];
    return _currentActionSheet;
}

- (void)appEnterBackground {
    if ([self isActionSheetVisible]) {
        if (self.delegate) {
            [self.delegate actionSheetWillBeDismissedForEnteringBackground:self.currentActionSheet];
        } else {
            if ([self.currentActionSheet.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
                [self.currentActionSheet.delegate actionSheet:self.currentActionSheet
                                         clickedButtonAtIndex:self.currentActionSheet.cancelButtonIndex];
            }
        }
        
        [self dismissVisibleActionSheet];
    }
}

@end

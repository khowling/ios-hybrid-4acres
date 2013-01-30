//
//  ContainerWebViewViewController.h
//  DreamForce
//
//  Created by Damian Tochetto on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "Constants.h"

@interface FileWebViewViewController : UIViewController<UIActionSheetDelegate, UIWebViewDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    NSURL *_initialURL;
    UIWebView *_webView;
    NSString *_name;
    NSString *_mimeType;
    
    NSString *_sid;
}
/**
 The first URL to load after displaying this view.
 */
@property (nonatomic, readonly, retain) NSURL *initialURL;
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *mimeType;
@property (nonatomic, readonly, retain) NSString *sid;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *actionButton;


/**
 Stick the URL on the pasteboard
 */
- (void)pasteLinkToPasteboard:(NSURL*)link;


+ (void)openFile:(NSURL *)anURL withName:(NSString*)name withMimeType:(NSString*)mimeType sid:(NSString*)sid withType:(PGOpenFileType)type fromViewController:(UIViewController *)aViewController animated:(BOOL)animated;

- (id)initWithFile:(NSURL *)anURL withName:(NSString*)name withMimeType:(NSString*)mimeType sid:(NSString*)sid withType:(PGOpenFileType)type;

@end


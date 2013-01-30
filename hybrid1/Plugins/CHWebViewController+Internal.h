//
// CHWebViewController.h
// chatterUI
//
// Created by Jason Schroeder on 8/1/11.
// Copyright 2011 Salesforce.com. All rights reserved.
//

#import "CHWebViewController.h"

@interface CHWebViewController () <UIActionSheetDelegate, UITextFieldDelegate, UIWebViewDelegate> {
    NSURL *_initialURL;
    UIWebView *_webView;
    UITextField *_urlForm;
}
/**
 The first URL to load after displaying this view.
 */
@property (nonatomic, readonly, retain) NSURL *initialURL;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UITextField *urlForm;

- (UIActionSheet *)newActionButtonActionSheet;

/**
 Stick the URL on the pasteboard
 */
- (void)pasteLinkToPasteboard:(NSURL*)link;

@end
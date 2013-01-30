//
// CHWebViewController.m
// chatterUI
//
// Created by Jason Schroeder on 8/1/11.
// Copyright 2011 Salesforce.com. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>

#import "CHWebViewController+Internal.h"
//#import "CHLocaleUtils.h"
//#import "Logger.h"
#import "ChatterSDKConstants.h"
#import "UIBarButtonItem+ChatterUI.h"
#import "CHActionSheetManager.h"

#import "ActivityIndicator.h"
#import "Constants.h"

const static CGFloat kCHWebViewToolBarHeight = 44.0;
const static CGFloat kCHWebViewUrlFieldHeight = 26.0;
const static CGFloat kCHWebViewiPadUrlFormWidthOffset = 260.0;
const static CGFloat kCHWebViewiPhoneUrlFormWidthOffset = 100.0;
const static CGFloat kCHWebViewBarButtonFixSpace =  10.0;



@interface CHWebViewController()
{
    ActivityIndicator* _activityIndicator;
}

+ (CGFloat)getUrlFieldOffset;

@property (nonatomic, retain) UIBarButtonItem *actionButton;

@end

@implementation CHWebViewController

@synthesize initialURL = _initialURL;
@synthesize webView = _webView;
@synthesize urlForm = _urlForm;
@synthesize actionButton = _actionButton;

+ (CGFloat)getUrlFieldOffset {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return kCHWebViewiPadUrlFormWidthOffset;
    }
    else {
        return kCHWebViewiPhoneUrlFormWidthOffset;
    }
}

+ (void)openURL:(NSURL *)anURL fromViewController:(UIViewController *)aViewController animated:(BOOL)animated {
    CHWebViewController *webVC = [[CHWebViewController alloc] initWithURL:anURL];
    [aViewController presentViewController:webVC animated:animated completion:nil];
    [webVC release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSURL *)aURL {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _initialURL = [aURL retain];
    }
    return self;
}

// TODO: return an autoreleased action sheet instead of a retained one

- (UIActionSheet *)newActionButtonActionSheet {
//#ifndef __clang_analyzer__ // TODO: remove this cheap hack to suppress clang warnings about returning a +0 retain count object
    NSString *viewInSafari = NSLocalizedString(@"ACTION_VIEW_IN_SAFARI", @"View in Safari button");
    NSString *copyLink = NSLocalizedString(@"ACTION_COPY_LINK", @"Copy link button");
    UIActionSheet *sheet = nil;
    NSString *cancelButtonTitle = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cancelButtonTitle = NSLocalizedString(@"BUTTON_CANCEL", @"cancel button");
    }
    
    // TODO: below method returns a retained sheet instance, despite the method name
    sheet = [[CHActionSheetManager sharedInstance] actionSheetWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:cancelButtonTitle
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:viewInSafari, copyLink, nil];
//#endif // __clang_analyzer__
    return sheet;
}

- (void)dealloc {
    self.webView.delegate = nil;
    self.urlForm.delegate = nil;
    
    [_activityIndicator release];

    CHRelease(_webView);
    CHRelease(_initialURL);
    CHRelease(_urlForm);
    CHRelease(_actionButton);
    
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BUTTON_CLOSE", @"Close")
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(onButtonClose:)];
    //create back button
    UIBarButtonItem *backButton = [self barButtonItemWithImage:@"embeddedbrowser_back.png"
                                                        target:self
                                                        action:@selector(onButtonBack:)
                                        accessibilityIdentifer:@"chatter.webview.backButton"];
    
    //create forward button
    UIBarButtonItem *forwardButton = [self barButtonItemWithImage:@"embeddedbrowser_forward.png"
                                                           target:self
                                                           action:@selector(onButtonForward:)
                                           accessibilityIdentifer:@"chatter.webview.forwardButton"];
    
    //create action sheet button
    self.actionButton = [self barButtonItemWithImage:@"embeddedbrowser_actionsheet.png"
                                              target:self
                                              action:@selector(onButtonAction:)
                              accessibilityIdentifer:@"chatter.webview.actionButton"];
    
    //create reload button
    UIBarButtonItem *reloadButton = [self barButtonItemWithImage:@"embeddedbrowser_refresh.png"
                                                          target:self
                                                          action:@selector(onButtonReload:)
                                          accessibilityIdentifer:@"chatter.webview.refreshButton"];
    
    
    _urlForm = [[UITextField alloc] initWithFrame:CGRectZero];
    _urlForm.borderStyle = UITextBorderStyleRoundedRect;
    _urlForm.textColor = [UIColor colorWithRed:0.455 green:0.463 blue:0.471 alpha:1.0];
    _urlForm.font = [UIFont systemFontOfSize:15.0];
    _urlForm.backgroundColor = [UIColor whiteColor];
    [_urlForm setUserInteractionEnabled:NO];
    
    // NOTE this code is commented-out as long as the URL can't be edited
    //_urlForm.autocorrectionType = UITextAutocorrectionTypeNo;
    //_urlForm.keyboardType = UIKeyboardTypeURL;
    //_urlForm.returnKeyType = UIReturnKeyGo;
    //_urlForm.clearButtonMode = UITextFieldViewModeWhileEditing; // has a clear 'x' button to the right
    //_urlForm.delegate = self;
    [_urlForm setText:[_initialURL absoluteString]];
    
    CGFloat heightOffSet = 0.0;
    CGFloat urlWidthOffset = 0.0;
    UIToolbar *actionBar = nil;
    CGRect urlFrame = CGRectZero;
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    urlWidthOffset = [[self class] getUrlFieldOffset];
    
    
    
    //setup URL field
    urlFrame = CGRectMake(0, 0, viewWidth - urlWidthOffset, kCHWebViewUrlFieldHeight);
    self.urlForm.frame = urlFrame;
    _urlForm.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    UIBarButtonItem *textItem = [[UIBarButtonItem alloc] initWithCustomView:_urlForm];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //On iPad, only include top bar to hold both URL field and all action buttons
        
        //setup action bar as the top bar
        actionBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kCHWebViewToolBarHeight)];
        actionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        actionBar.accessibilityIdentifier = @"chatter.webview.topToolbar";
        
        //create top bar
        [actionBar setItems:[NSArray arrayWithObjects:
                             closeButton,
                             backButton,
                             forwardButton,
                             [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                             textItem,
                             [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                             self.actionButton,
                             [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                             reloadButton,
                             [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                             nil] animated:NO];
        
        
    }
    else {
        //On iPhone, use top bar to host close button and url field. Use a bottom toolbar to host all other action buttons
        heightOffSet = kCHWebViewToolBarHeight;
        
        //Create top toolbar for iPhone to host close butto and URL field
        CGRect toolbarFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kCHWebViewToolBarHeight);
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
        toolbar.accessibilityIdentifier = @"chatter.webview.topToolbar";
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [toolbar setItems:[NSArray arrayWithObjects:closeButton,
                           [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                           textItem,
                           [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace], nil] animated:NO];
        [self.view addSubview:toolbar];
        [toolbar release];
        
        
        //Setup bottom action toolbar on iPhone
        actionBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewHeight - kCHWebViewToolBarHeight, viewWidth, kCHWebViewToolBarHeight)];
        actionBar.accessibilityIdentifier = @"chatter.webview.bottomToolbar";
        actionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [actionBar setItems:[NSArray arrayWithObjects:backButton,
                             forwardButton,
                             [UIBarButtonItem flexibleSpace],
                             self.actionButton,
                             [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                             reloadButton,
                             [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                             nil] animated:NO];
    }
    [self.view addSubview:actionBar];
    [textItem release];
    [closeButton release];
    [actionBar release];
    
    
    //Setup web view
    CGRect webViewFrame = CGRectMake(0, kCHWebViewToolBarHeight, viewWidth, viewHeight - heightOffSet - kCHWebViewToolBarHeight);
    _webView = [[UIWebView alloc] initWithFrame:webViewFrame];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    
    [self.view addSubview:_webView];
    
    
    if (!_activityIndicator) 
    {
        _activityIndicator = [[ActivityIndicator currentIndicator] retain];
        [self.view addSubview:_activityIndicator];
        [_activityIndicator hide];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.initialURL]];
}

- (void)viewDidUnload {
    [_webView setDelegate:nil];
    [_urlForm setDelegate:nil];
    self.webView = nil;
    self.urlForm = nil;
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


#pragma mark -
#pragma mark Button Handlers
- (void)onButtonClose:(id)sender {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[CHActionSheetManager sharedInstance] dismissVisibleActionSheet];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonBack:(id)sender {
    [_webView goBack];
}

- (void)onButtonForward:(id)sender {
    [_webView goForward];
}

- (void)onButtonAction:(id)sender {
    UIActionSheet * sheet = [self newActionButtonActionSheet];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [sheet showFromBarButtonItem:self.actionButton animated:YES];
    } else {
        [sheet showInView:self.view];
    }
}

- (void)onButtonReload:(id)sender {
    [_webView reload];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_activityIndicator displayActivity:NSLocalizedString(@"Loading", @"Loading")]; 
    NSString *currentRequest = [[[webView request] URL] absoluteString];
    if ([currentRequest length] > 0)
        [self.urlForm setText:currentRequest];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_activityIndicator hide];
    NSString *currentRequest = [[[webView request] URL] absoluteString];
    if ([currentRequest length] > 0)
        [self.urlForm setText:currentRequest];
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error 
{
    [_activityIndicator hide];
    TRACE(@"Error (%@) - code (%d)", [error localizedDescription], [error code]);
}

- (void)pasteLinkToPasteboard:(NSURL *)link {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    [pboard setValue:link forPasteboardType:(NSString*)kUTTypeURL];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSURL *latestLink = [NSURL URLWithString:self.urlForm.text];
    if (buttonIndex >= 0) {
        
        NSString *selectedAction = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([selectedAction isEqualToString:NSLocalizedString(@"ACTION_VIEW_IN_SAFARI", @"")]) {
            [[UIApplication sharedApplication] openURL:latestLink];
        } else if ([selectedAction isEqualToString:NSLocalizedString(@"ACTION_COPY_LINK", @"")]) {
            [self pasteLinkToPasteboard:latestLink];
        }
    }
    [[CHActionSheetManager sharedInstance] releaseActionSheet];
}

- (UIBarButtonItem *)barButtonItemWithImage:(NSString *)imageName target:(id)target action:(SEL)action accessibilityIdentifer:(NSString *)accessibilityIdentifer {
 //   UIImage *buttonImage = [CHLocaleUtils imageNamed:imageName];
    UIImage *buttonImage = [UIImage imageNamed:imageName];

    CGRect frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    if (nil != accessibilityIdentifer) {
        button.accessibilityIdentifier = accessibilityIdentifer;
    }
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button release];
    
    return [barButton autorelease];
}



@end
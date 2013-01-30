//
//  ContainerWebViewViewController.m
//  DreamForce
//
//  Created by Damian Tochetto on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileWebViewViewController.h"
#import "ChatterSDKConstants.h"
#import "UIBarButtonItem+ChatterUI.h"
#import "CHActionSheetManager.h"
#import "ActivityIndicator.h"
#import "Constants.h"
#import "AppDelegate.h"



#define DOWNLOAD_ASIHHTTP  0


#if DOWNLOAD_ASIHHTTP == 1

#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

#endif


const static CGFloat kCHWebViewToolBarHeight = 44.0;
const static CGFloat kCHWebViewUrlFieldHeight = 26.0;
const static CGFloat kCHWebViewiPadUrlFormWidthOffset = 160.0;
const static CGFloat kCHWebViewiPhoneUrlFormWidthOffset = 140.0;
const static CGFloat kCHWebViewBarButtonFixSpace =  10.0;


@interface FileWebViewViewController ()
{
    ActivityIndicator* _activityIndicator;
    NSString* _directoryPath;
    BOOL downloadFinished;
    UIDocumentInteractionController* _docController;
    PGOpenFileType _type;
    UIActionSheet * _sheet;
}

@end

@implementation FileWebViewViewController

@synthesize initialURL = _initialURL;
@synthesize webView = _webView;
@synthesize name = _name;
@synthesize mimeType = _mimeType;
@synthesize sid=_sid;

@synthesize actionButton = _actionButton;

+ (CGFloat)getTitleOffset {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return kCHWebViewiPadUrlFormWidthOffset;
    }
    else {
        return kCHWebViewiPhoneUrlFormWidthOffset;
    }
}

+ (void)openFile:(NSURL *)anURL withName:(NSString*)name withMimeType:(NSString*)mimeType sid:(NSString*)sid withType:(PGOpenFileType)type fromViewController:(UIViewController *)aViewController animated:(BOOL)animated {
    
    TRACE (@"openFile %u", type);
    FileWebViewViewController *webVC = [[FileWebViewViewController alloc] initWithFile:anURL withName:name withMimeType:mimeType sid:sid withType:type];
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

- (id)initWithFile:(NSURL *)aURL withName:(NSString*)aName withMimeType:(NSString*)mimeType sid:(NSString*)sid withType:(PGOpenFileType)type
{
    TRACE (@"openFile %u", type);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _initialURL = [aURL retain];
        _name = [aName retain];
        _type = type;
        _mimeType = [mimeType retain];
        _sid = [sid retain];
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        
        _directoryPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:kPathFileRoot]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_directoryPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:_directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
#if DOWNLOAD_ASIHHTTP == 1
        [ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES];
        [ASIHTTPRequest setDefaultUserAgentString:[[AppDelegate sharedInstance] userAgentString]];
        //  [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
#endif
        
    }
    return self;
}

// TODO: return an autoreleased action sheet instead of a retained one

- (UIActionSheet *)newActionButtonActionSheetFile
{
    TRACE (@"%@", @"newActionButtonActionSheetFile");
    
    NSString *opeIn = NSLocalizedString(@"ACTION_VIEW_OPEN_IN", @"Open in ...");
    NSString *sendByEmail = NSLocalizedString(@"ACTION_SEND_EMAIL_DOCU", @"Email Document");
    
    UIActionSheet *sheet = nil;
    NSString *cancelButtonTitle = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cancelButtonTitle = NSLocalizedString(@"BUTTON_CANCEL", @"cancel button");
    }
    
    sheet = [[UIActionSheet alloc] initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:cancelButtonTitle
                          destructiveButtonTitle:nil
                               otherButtonTitles:opeIn, sendByEmail, nil];
    return sheet;
}

- (UIActionSheet *)newActionButtonActionSheetImage
{
    TRACE (@"%@", @"newActionButtonActionSheetImage");

    NSString *save = NSLocalizedString(@"ACTION_SAVE_PHOTO", @"Save Photo");
    NSString *email = NSLocalizedString(@"ACTION_SEND_EMAIL_PHOTO", @"Email Photo");
    UIActionSheet *sheet = nil;
    NSString *cancelButtonTitle = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cancelButtonTitle = NSLocalizedString(@"BUTTON_CANCEL", @"cancel button");
    }
    
    sheet = [[UIActionSheet alloc] initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:cancelButtonTitle
                          destructiveButtonTitle:nil
                               otherButtonTitles:save, email, nil];
    return sheet;
}



- (void)dealloc {
    self.webView.delegate = nil;
    
    CHRelease(_webView);
    CHRelease(_initialURL);
    CHRelease(_actionButton);
    CHRelease(_name)
    CHRelease(_mimeType)
    
    [_activityIndicator release];
    
    [_directoryPath release];
    
    [_docController release];
    
    _sheet.delegate = nil;
    [_sheet release];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    TRACE (@"viewDidLoad %u", 0);
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BUTTON_DONE", @"Done")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(onButtonDone:)];
    
    CGFloat heightOffSet = 0.0;
    UIToolbar *actionBar = nil;
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    
    
    CGFloat titleWidthOffset = [[self class] getTitleOffset];
    
    CGRect nameLabelFrame = CGRectMake(0, 0, viewWidth - titleWidthOffset, kCHWebViewUrlFieldHeight);
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    nameLabel.textAlignment = UITextAlignmentCenter;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = _name;
    UIBarButtonItem *textItem = [[UIBarButtonItem alloc] initWithCustomView:nameLabel];
    [nameLabel release];
    
    TRACE (@"viewDidLoad create action sheet button %@", @" ");
    
    
    self.actionButton = [self barButtonItemWithImage:@"embeddedbrowser_actionsheetFile.png"
                                              target:self
                                              action:@selector(onButtonAction:)
                              accessibilityIdentifer:@"chatter.webview.actionButton"];
    
    //setup action bar as the top bar
    actionBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kCHWebViewToolBarHeight)];
    actionBar.tintColor = [UIColor redColor];
    actionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    actionBar.accessibilityIdentifier = @"chatter.webview.topToolbar";
    
    //create top bar
    
//    [actionBar setItems:[NSArray arrayWithObjects:
//                         closeButton,
//                         [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
//                         textItem,
//                         [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
//                         self.actionButton,
//                         nil] animated:NO];
    
    actionBar.items = [NSArray arrayWithObjects:
                       closeButton,
                       [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                       textItem,
                       [UIBarButtonItem fixedSpace:kCHWebViewBarButtonFixSpace],
                       self.actionButton,
                       nil];
    
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
    _webView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_webView];
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    downloadFinished = YES;
    NSString* fileName = [NSString stringWithFormat:@"%@/%@", _directoryPath, _name];
	if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        
#if DOWNLOAD_ASIHHTTP == 1
        [self downloadASIHTTPFile];
#else
        [self downloadFile];
#endif
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self refreshWebView];
}

- (void)viewDidUnload {
    [_webView setDelegate:nil];
    self.webView = nil;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [_activityIndicator hide];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


-(void)refreshWebView
{
    TRACE (@"refreshWebView %u", _type);
    if (downloadFinished) {
        
        NSString* fileName;
        
        if (_type == PGOpenImage)
        {
            //   NSString* htmlFormatter = @"<html><head></head><body style=\"background-color:rgb(0,0,0);\"><img src=\"%@\" alt=\"%@\"/></body></html>";
            
            NSString* htmlFormatter = @"<html><head><style type=\"text/css\">img {position:relative; top:0; left:0; right:0;bottom:0;margin:auto;}</style></head><body style=\"background-color:rgb(0,0,0);\"><div><table width=\"100%\" height=\"100%\" align=\"center\" valign=\"center\"><tr><td><img src=\"%@\" alt=\"%@\" /></td></tr></table></div></body></html>";
            
            //    NSString* htmlFormatter = @"<html><head><style type=\"text/css\">html, body, #wrapper {height:100%;width: 100%;margin: 0;padding: 0;border: 0;}#wrapper td {vertical-align: middle;text-align: center;}</style> </head><body style=\"background-color:rgb(0,0,0);\"><table id=\"wrapper\"><tr><td><img src=\"%@\" alt=\"%@\" /></td></tr></table></body></html>";
            
            //    NSString* htmlFormatter = @"<html><head><style type=\"text/css\">body {width: 100%;height: 100%;background-color: #000; background-image: url(%@);background-position: 50% 50%; background-repeat: no-repeat;}  </style> <meta name=\"viewport\" content=\"user-scalable=yes\" /></head><body> </body> </html>";
            
            
            NSString* htmlString = [NSString stringWithFormat:htmlFormatter, _name, _name];
            NSData* htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
            TRACE (@"refreshWebView image name %@", _name);
            fileName = [NSString stringWithFormat:@"%@/%@", _directoryPath, @"image.html"];
            NSError* errorWrite;
            [htmlData writeToFile:fileName options:NSDataWritingAtomic error:&errorWrite];
        }
        else
        {
            TRACE (@"refreshWebView file name %@", _name);
            fileName = [NSString stringWithFormat:@"%@/%@", _directoryPath, _name];
        }
        
        NSURLRequest* fileRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:fileName]];
        [self.webView loadRequest:fileRequest];
    }
}


#pragma Download thread

#if DOWNLOAD_ASIHHTTP == 1

-(void) downloadASIHTTPFile
{
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", _directoryPath, _name];
    NSString* fileTempPath = [NSString stringWithFormat:@"%@/%@.temp", _directoryPath, _name];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:_initialURL];
    
    [request setDownloadDestinationPath:filePath];
    [request setTemporaryFileDownloadPath:fileTempPath];
    [request setAllowResumeForFileDownloads:YES];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setNumberOfTimesToRetryOnTimeout:2];
    //[request setValidatesSecureCertificate:NO];
    
    [request setCompletionBlock:^{
        
        [_activityIndicator hide];
        
        downloadFinished = YES;
        [self refreshWebView];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        TRACE(@"Error %@", [error localizedDescription]);
        
        [_activityIndicator hide];
        
        [self showMessageErrorDownloading];
    }];
    
    [request startAsynchronous];
    
    if (!_activityIndicator)
    {
        _activityIndicator = [[ActivityIndicator currentIndicator] retain];
        [self.view.window addSubview:_activityIndicator];
    }
    [_activityIndicator displayActivity:NSLocalizedString(@"Loading", @"Loading")];
    downloadFinished = NO;
    
}

#endif

-(void) downloadFile
{
    downloadFinished = NO;
    
    NSString * userAgent = [[AppDelegate sharedInstance] userAgentString];
    NSArray* parameters = [NSArray arrayWithObjects:_initialURL, _sid, userAgent, _directoryPath, _name, nil];
    
    [NSThread detachNewThreadSelector:@selector(downloadThread:) toTarget:self withObject:parameters];
    
    if (!_activityIndicator)
    {
        _activityIndicator = [[ActivityIndicator currentIndicator] retain];
        [self.view.window addSubview:_activityIndicator];
    }
    [_activityIndicator displayActivity:NSLocalizedString(@"Loading", @"Loading")];
}

-(void) showMessageErrorDownloading
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DreamForce", @"DreamForce")
                                                     message:NSLocalizedString(@"ERROR_DOWNLOADING_FILE", @"Error downloading file")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"BUTTON_CANCEL", @"Cancel")
                                           otherButtonTitles:NSLocalizedString(@"TRY_AGAIN", @"Try again"), nil];
    [alert show];
}

-(void)downloadThread:(NSArray*) parameters
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURL * url = [parameters objectAtIndex:0];
    NSString *  sid = [parameters objectAtIndex:1];
    NSString * userAgent = [parameters objectAtIndex:2];
    NSString * directory = [parameters objectAtIndex:3];
    NSString * name = [parameters objectAtIndex:4];
    
    TRACE(@"downloadThread URL %@", url);
    
    NSString * urlString = [url absoluteString];
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@"c.na14.visual.force.com"
                                                     withString:@"na14.salesforce.com"];
    NSURL * newUurl = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //TRACE(@"KEITH URL %@", newUurl);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:newUurl];
	[request setTimeoutInterval:kRequestTimeOut];
    
    sid = [sid stringByReplacingOccurrencesOfString:@"OAuth"
                                         withString:@"Bearer"];
    
    //TRACE(@"OAuth %@", sid);
    
    [request setValue:sid forHTTPHeaderField:@"Authorization"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", directory, name];
    
    NSError* errorRequest=nil;
    NSError* errorWrite=nil;
    NSHTTPURLResponse* response = nil;
    
	NSData* file = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errorRequest];
    
	if (errorRequest)
    {
        TRACE(@"Error %@", [errorRequest localizedDescription]);
        [_activityIndicator performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
        
        [self performSelectorOnMainThread:@selector(showMessageErrorDownloading) withObject:nil waitUntilDone:NO];
        return;
	}
    
	[file writeToFile:filePath options:NSDataWritingAtomic error:&errorWrite];
	
	if (errorWrite)
    {
        TRACE(@"Error %@", [errorWrite localizedDescription]);
        [_activityIndicator performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(showMessageErrorDownloading) withObject:nil waitUntilDone:NO];
        
        return;
	}
	
	downloadFinished = YES;
	[self performSelectorOnMainThread:@selector(refreshWebView) withObject:nil waitUntilDone:NO];
    
    [_activityIndicator performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
    
	[pool release];
}

#pragma mark -
#pragma mark Button Handlers

- (void)onButtonDone:(id)sender
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (_docController) {
        [_docController dismissMenuAnimated:NO];
    }
    if (_sheet) {
        [_sheet dismissWithClickedButtonIndex:_sheet.cancelButtonIndex animated:NO];
    }
    
    [_activityIndicator hide];
    
    [[CHActionSheetManager sharedInstance] dismissVisibleActionSheet];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)onButtonAction:(id)sender {
    TRACE(@"onButtonAction %@", @" ");
    
    if (_docController) {
        [_docController dismissMenuAnimated:YES];
    }
    
    //    UIActionSheet * _sheet = nil;
    
    if (_sheet)
    {
        _sheet.delegate = nil;
        [_sheet release];
        _sheet = nil;
    }
    
    if (_type == PGOpenFile)
    {
        _sheet = [self newActionButtonActionSheetFile];
    }
    else
    {
        _sheet = [self newActionButtonActionSheetImage];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [_sheet showFromBarButtonItem:self.actionButton animated:YES];
    }
    else
    {
        [_sheet showInView:self.view];
    }
}


#pragma mark -
#pragma mark UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_activityIndicator displayActivity:NSLocalizedString(@"Loading", @"Loading")];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_activityIndicator hide];
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
    TRACE(@"actionSheet %@", @" ");
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    TRACE(@"Button index %d", buttonIndex);
    
    if (buttonIndex >= 0) {
        
        NSString *selectedAction = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if (_type == PGOpenFile)
        {
            if ([selectedAction isEqualToString:NSLocalizedString(@"ACTION_VIEW_OPEN_IN", @"")])
            {
                [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
                [self showActionMenuFromBarButton:self.actionButton];
            }
            else if([selectedAction isEqualToString:NSLocalizedString(@"ACTION_SEND_EMAIL_DOCU", @"")])
            {
                [self checkAndSendMail];
            }
            
        }
        else if (_type == PGOpenImage)
        {
            if ([selectedAction isEqualToString:NSLocalizedString(@"ACTION_SAVE_PHOTO", @"")])
            {
                NSString* filePath = [NSString stringWithFormat:@"%@/%@", _directoryPath, _name];
                UIImage* image = [UIImage imageWithContentsOfFile:filePath];
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
            }
            else if([selectedAction isEqualToString:NSLocalizedString(@"ACTION_SEND_EMAIL_PHOTO", @"")])
            {
                [self checkAndSendMail];
            }
        }
        
    }
    //  actionSheet.delegate = nil;
    //   [actionSheet release];
    // [[CHActionSheetManager sharedInstance] releaseActionSheet];
}

- (UIBarButtonItem *)barButtonItemWithImage:(NSString *)imageName target:(id)target action:(SEL)action accessibilityIdentifer:(NSString *)accessibilityIdentifer
{
    TRACE(@"barButtonItemWithImage %@", imageName);
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    TRACE(@"barButtonItemWithImage %@ %f %f", imageName, buttonImage.size.width, buttonImage.size.height );
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

#pragma UIDocumentInteractionController delegate



- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    TRACE(@"%@",@"willBeginSendingToApplication");
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    TRACE(@"%@",@"didEndSendingToApplication");
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    TRACE(@"%@", @"documentInteractionControllerDidDismissOpenInMenu");
}


-(void) showActionMenuFromBarButton:(UIBarButtonItem*) barButtomItem
{
    
    if (!_docController)
    {
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", _directoryPath, _name];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        _docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        _docController.delegate = self;
        [_docController retain];
    }
    
    //BOOL isValid = [_docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    
    BOOL isValid = [_docController presentOpenInMenuFromBarButtonItem:barButtomItem animated:YES];
    
    if (!isValid)
    {
        TRACE(@"%@", @"isNotValid");
        
        NSString* message = [NSString stringWithFormat:NSLocalizedString(@"NOT_APPLICATION_TO_OPEN_FORMAT", @"There are not app to open this file"), _name];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DreamForce", @"DreamForce")
                                                        message: message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma Image

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    if (error)
    {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DreamForce", @"DreamForce")
                                           message:NSLocalizedString(@"ERROR_SAVIN_IMAGE", @"Error saving image")
                                          delegate:nil
                                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                 otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}


#pragma Mail

-(void) checkAndSendMail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}


#pragma mark -
#pragma mark Compose Mail

-(void)launchMailAppOnDevice
{
    NSString *emailString = [NSString stringWithFormat:@"mailto:?subject=%@&body= ", _name];
    emailString = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
}

-(void)displayComposerSheet {
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    picker.title = NSLocalizedString(@"ACTION_SEND_EMAIL", @"Send email");
    
    [picker setSubject:_name];
    
    [picker setToRecipients:nil];
    [picker setCcRecipients:nil];
    [picker setBccRecipients:nil];
    
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", _directoryPath, _name];
    NSData* dataFile = [NSData dataWithContentsOfFile:filePath];
    
    NSString* mimeType;
    if (_mimeType)
    {
        mimeType = _mimeType;
    }
    else
    {
        mimeType = [self mimeForName:_name];
    }
    [picker addAttachmentData:dataFile mimeType:mimeType fileName:_name];
    
    // Fill out the email body text
    //NSMutableString *emailBody = [self generateBody];
    
    [picker setMessageBody:@"" isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
    [picker release];
}


-(NSMutableString*) generateBody
{
    // Fill out the email body text
    NSMutableString *emailBody = [NSMutableString string];
    
    return emailBody;
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller  didFinishWithResult:(MFMailComposeResult)result  error:(NSError*)error {
    
    
    switch (result)	{
    	case MFMailComposeResultCancelled:
    		break;
    	case MFMailComposeResultSaved:
    		break;
    	case MFMailComposeResultSent:
    		break;
    	case MFMailComposeResultFailed:
    		break;
    	default:
    		break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

-(NSString*) mimeForName:(NSString*)name
{
    NSRange range;
    
    range = [name rangeOfString:@"jpg" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"image/jpg";
    }
    range = [name rangeOfString:@"png" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"image/png";
    }
    range = [name rangeOfString:@"gif" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"image/gif";
    }
    
    range = [name rangeOfString:@"bmp" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"image/bmp";
    }
    
    range = [name rangeOfString:@"pdf" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"application/pdf";
    }
    
    range = [name rangeOfString:@"doc" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"application/msword";
    }
    
    range = [name rangeOfString:@"dot" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"application/msword";
    }
    
    range = [name rangeOfString:@"xls" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"application/excel";
    }
    
    range = [name rangeOfString:@"txt" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"text/plain";
    }
    
    range = [name rangeOfString:@"pot" options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        return @"application/mspowerpoint";
    }
    
    return @"application/application";
}

#pragma Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
#if DOWNLOAD_ASIHHTTP == 1
        [self downloadASIHTTPFile];
#else
        [self downloadFile];
#endif
    }
}

@end

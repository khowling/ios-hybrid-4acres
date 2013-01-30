//
//  HelloPlugin.m
//  hybrid1
//
//  Created by temp on 1/11/13.
//  Copyright (c) 2013 temp. All rights reserved.
//

#import "HelloPlugin.h"
#import "Constants.h"
#import "CHWebViewController.h"
#import "AppDelegate.h"
#import "FileWebViewViewController.h"

@implementation HelloPlugin

- (void) nativeFunction:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    //get the callback id
    NSString *callbackId = [arguments pop];
    
    NSLog(@"Hello, this is a native function called from PhoneGap/Cordova!");
    
    NSString *resultType = [arguments objectAtIndex:0];
    CDVPluginResult *result;
    
    if ( [resultType isEqualToString:@"success"] ) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"Success :)"];
        [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    }
    else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Error :("];
        [self writeJavascript:[result toErrorCallbackString:callbackId]];
    }
}


- (void)openFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self open:arguments withDict:options withType:PGOpenFile];
}


- (void)openImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self open:arguments withDict:options withType:PGOpenImage];
}

- (void)open:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options withType:(PGOpenFileType) type
{
    NSString* callback = [arguments objectAtIndex:0];
    NSAssert(callback, @"PGCHWebView. Callback function is not defined!");
    
    NSArray *keyArray = [options allKeys];
    NSAssert([keyArray count], @"PGCHWebView.openFile key was wrong!");
    
    NSString *valueFile = [options objectForKey:kCHWebViewFileKey];
    NSAssert(valueFile, @"PGCHWebView.openFile key kCHWebViewFileKey was wrong!");
    
    NSString *valueName = [options objectForKey:kCHWebViewNameKey];
    NSAssert(valueName, @"PGCHWebView.openFile key kCHWebViewNameKey was wrong!");
    
    NSString *mimeType = [options objectForKey:kCHWebViewMimeTypeKey];
    NSAssert(valueName, @"PGCHWebView.openFile key kCHWebViewMimeTypeKey was wrong!");
    
    NSString* sid = [options objectForKey:kCHWebViewSidTypeKey];
    NSAssert(valueName, @"PGCHWebView.openFile key kCHWebViewSidTypeKey was wrong!");
    
    
    NSURL* url = [NSURL URLWithString:valueFile];

    //CHWebViewController* viewcontroller = [[AppDelegate sharedInstance] viewController];

    SFHybridViewController* viewcontroller = [[AppDelegate sharedInstance] viewController];
    
    [FileWebViewViewController openFile:url withName:valueName withMimeType:mimeType sid:sid withType:type fromViewController:(UIViewController*)viewcontroller animated:YES];
    
    CDVPluginResult* result;
    NSString* js;
    
    UIApplication* application = [UIApplication sharedApplication];
    if (![application canOpenURL:url])
    {
        result = [CDVPluginResult
                  resultWithStatus: CDVCommandStatus_ERROR
                  messageAsString: NSLocalizedString(@"Feature unsupported",@"Feature unsupported")];
        js = [result toErrorCallbackString:callback];
    }
    else
    {
        result = [CDVPluginResult
                  resultWithStatus: CDVCommandStatus_OK
                  messageAsString: NSLocalizedString(@"Opened",@"Opened")];
        js = [result toSuccessCallbackString:callback];
    }
    
    [self writeJavascript:js];
}


@end

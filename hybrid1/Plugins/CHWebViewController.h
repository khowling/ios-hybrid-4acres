//
// CHWebViewController.h
// chatterUI
//
// Created by Jason Schroeder on 8/1/11.
// Copyright 2011 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHWebViewController : UIViewController

+ (void)openURL:(NSURL *)anURL fromViewController:(UIViewController *)aViewController animated:(BOOL)animated;
- (id)initWithURL:(NSURL *)anURL;

@end
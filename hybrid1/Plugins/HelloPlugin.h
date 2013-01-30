//
//  HelloPlugin.h
//  hybrid1
//
//  Created by temp on 1/11/13.
//  Copyright (c) 2013 temp. All rights reserved.
//

#import <SalesforceHybridSDK/CDVPlugin.h>

@interface HelloPlugin : CDVPlugin

- (void) nativeFunction:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
//- (void)openURL:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)openFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)openImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

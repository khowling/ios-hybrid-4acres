//
//  CHLocaleUtils.m
//  chatter
//
//  Created by Michael Nachbaur on 5/17/11.
//  Copyright 2011 Salesforce.com. All rights reserved.
//

#import "CHLocaleUtils.h"

static NSString* const kCHLocaleUtilsBundle = @"ChatterSDK";
static NSBundle* ChatterSDKBundle = nil;
static NSString * RelativeImagesPathPrefix = nil;

NSString* CHLocalizedString(NSString* key, NSString* comment) {
    return [CHLocaleUtils localizedStringForKey:key comment:comment];
}

@implementation CHLocaleUtils

+ (void)initialize {
    if (self == [CHLocaleUtils class]) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kCHLocaleUtilsBundle ofType:@"bundle"];
        NSAssert(nil != bundlePath, @"Cannot find the bundle %@.bundle", kCHLocaleUtilsBundle);
        ChatterSDKBundle = [[NSBundle bundleWithPath:bundlePath] retain];

        NSString *mainPath = [[NSBundle mainBundle] resourcePath];
        NSString *bundlepath = [ChatterSDKBundle resourcePath];
        
        NSString *commonPrefix = [mainPath commonPrefixWithString:bundlepath options:0];
        RelativeImagesPathPrefix = [[bundlepath substringFromIndex:[commonPrefix length] + 1] retain];
    }
}

+ (NSBundle*)bundle {
    return ChatterSDKBundle;
}

+ (UIImage*)imageNamed:(NSString*)name {
    return [UIImage imageNamed:[RelativeImagesPathPrefix stringByAppendingPathComponent:name]];
}

+ (UIImage*)buttonBarStretchableImage:(NSString*)name {
    UIImage *buttonBg = [CHLocaleUtils imageNamed:name];
    if (nil == buttonBg)
        return nil;
    
    UIEdgeInsets backgroundInsets = UIEdgeInsetsMake(buttonBg.size.height / 2, buttonBg.size.width / 2,
                                                     buttonBg.size.height / 2, buttonBg.size.width / 2);
    return [buttonBg resizableImageWithCapInsets:backgroundInsets];
}

+ (NSString*)localizedStringForKey:(NSString*)key comment:(NSString*)comment {
    return [ChatterSDKBundle localizedStringForKey:key value:key table:nil];
}

@end

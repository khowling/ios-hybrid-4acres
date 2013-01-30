//
//  UIBarButtonItem+ChatterUI.m
//  chatterUI
//
//  Created by Michael Nachbaur on 5/28/11.
//  Copyright 2011 Salesforce.com. All rights reserved.
//

#import "UIBarButtonItem+ChatterUI.h"
#import "CHLocaleUtils.h"

//FIX_CATEGORY_BUG(UIBarButtonItem_ChatterUI);

@implementation UIBarButtonItem (ChatterUI)

+ (UIBarButtonItem *)flexibleSpace {
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                          target:nil
                                                          action:nil] autorelease];
}

+ (UIBarButtonItem *)fixedSpace:(CGFloat)width {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                          target:nil
                                                                          action:nil];
    item.width = width;
    return [item autorelease];
}

+ (UIBarButtonItem *)barButtonItemWithImage:(NSString *)imageName target:(id)target action:(SEL)action accessibilityIdentifer:(NSString *)accessibilityIdentifer {
    
    
    UIImage *buttonImage = [CHLocaleUtils imageNamed:imageName];
    
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

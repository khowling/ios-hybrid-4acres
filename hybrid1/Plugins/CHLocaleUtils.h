//
//  CHLocaleUtils.h
//  chatter
//
//  Created by Michael Nachbaur on 5/17/11.
//  Copyright 2011 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString* CHLocalizedString(NSString* key, NSString* comment);

@interface CHLocaleUtils : NSObject {
    
}

+ (NSBundle*)bundle;

+ (UIImage*)imageNamed:(NSString*)name;
+ (UIImage*)buttonBarStretchableImage:(NSString*)name;

+ (NSString*)localizedStringForKey:(NSString*)key comment:(NSString*)comment;

@end

//
//  UIBarButtonItem+ChatterUI.h
//  chatterUI
//
//  Created by Michael Nachbaur on 5/28/11.
//  Copyright 2011 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (ChatterUI)

/**Create a flexible space bar button item
 */
+ (UIBarButtonItem *)flexibleSpace;

/**Create a fix space bar button item
 
 @param width Width for the fixed space
*/
+ (UIBarButtonItem *)fixedSpace:(CGFloat)width;

/**Create a button item with image and action. 
 
 This convenient method will create a button internally with the specified image and action and use the button
 to create the BarButtonItem
 @param imageName Name of the image 
 @param target Button taget
 @param action Button touch up inside action
 @param accessibilityIdentifer Accessbility identifier, pass nil if no identifier should be assigned
 */
+ (UIBarButtonItem *)barButtonItemWithImage:(NSString *)imageName target:(id)target action:(SEL)action accessibilityIdentifer:(NSString *)accessibilityIdentifer;
@end

//
//  ChatterSDKConstants.h
//  ChatterSDK
//
//  Created by Jason Schroeder on 8/5/11.
//  Copyright 2011 Salesforce.com. All rights reserved.
//

#ifndef ChatterSDKConstants_h
#define ChatterSDKConstants_h

#define CHRelease(ivar) [ivar release]; ivar = nil;
#define FIX_CATEGORY_BUG(name) @interface FIXCATEGORYBUG ## name @end @implementation FIXCATEGORYBUG ## name @end 

const static CGFloat kAvatarIconSizePhone = 48.0;
const static CGFloat kAvatarIconSizePad = 53.0;

/** Identifies the context for an event; whether due to user interaction or programmatically triggered.
 */
typedef NSInteger CHInteractionContext;
enum {
    CHInteractionContextUser = 0,       /// the event was caused by user interaction
    CHInteractionContextProgrammatic    /// the event was programmatically triggered
};

#pragma mark - Remote Push Notifications

static NSString * const CHPushCountDidChangeNotification    = @"CHPushCountDidChangeNotification";
static NSString * const CHRecentGroupSettingChangedNotification = @"CHRecentGroupSettingChangedNotification";

static NSString * const CHPushKeyCount                      = @"CHPushCount";
static NSString * const CHPushKeyType                       = @"CHPushType";
static NSString * const CHPushTypeChatterFeeds              = @"CHPushTypeChatterFeeds";
static NSString * const CHPushTypePrivateMessages           = @"CHPushTypePrivateMessages";

static NSString * const CHOrganizationSettingsChangedNotification = @"CHOrganizationSettingsChangedNotification";
static NSString * const CHOrganizationSettingsFailedNotification = @"CHOrganizationSettingsFailedNotification";

static NSString * const SEARCH_ALL = @"SEARCH_ALL";
static NSString * const SEARCH_ALL_GROUPS = @"SEARCH_ALL_GROUPS";
static NSString * const SEARCH_ALL_PEOPLE = @"SEARCH_ALL_PEOPLE";
static NSString * const SEARCH_ALL_FILES = @"SEARCH_ALL_FILES";
static NSString * const CHATTER_RELATED_GROUPS = @"groups";
static NSString * const CHTemporaryContentPostPrefix = @"0D5---";
static NSString * const CHTemporaryCommentPostPrefix = @"0D7---";
static NSString * const CHTemporaryFilePrefix = @"068---";
//This is the apple error code value for network unavailable error NSURLErrorNotConnectedToInternet
static NSInteger const CHNetworkErrorCode = NSURLErrorNotConnectedToInternet;

/**
 Default file count for a user in core data, so before getting the actual count from the server we
 can use this value to display "--" in the file count label.
 Default is -5 since our in memory default for all counts is set to -1.
 */
static NSInteger const CHEntityDetailUnknownStatisticsValue = -5;

#pragma mark - Special Feed ID's

/**
 A special id used to indicate the newsfeed of the current user (owner).
 We distinguish between this and the ordinary owner id because the owner id
 is used to load the owner's wall feed (list of her own postings) .
 */
static NSString * const OWNER_NEWSFEED_ID = @"newsfeed";

/**
 A special id for the "To:Me" news feed which contains things on your wall, @mentions, etc
 It does not show posts made by the owner.
 */
static NSString * const TOME_NEWSFEED_ID = @"tome_feed";

#pragma mark - Device ID

/**
 Device identifier for iPad's. Included in all Mocha requests.
 */
static NSString * const CHDeviceIDiPad = @"iOS_iPad";
/**
 Device identifier for all non-iPad devices (i.e. iPhone and iPod Touch). Included in all Mocha requests.
 */
static NSString * const CHDeviceIDiPhone = @"iOS_iPhone";
/**
 Returns either `CHDeviceIDiPad` or `CHDeviceIDiPhone` based on the current device.
 */
static inline NSString * CHDeviceID() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CHDeviceIDiPad : CHDeviceIDiPhone;
}
/**
 Returns the right avatar size based on the current device.
 */
static inline CGFloat CHAvatarIconSize() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kAvatarIconSizePad: kAvatarIconSizePhone;
}

static inline id CHNotNullValue(id value) {
    if ([value isEqual:[NSNull null]])
        return nil;
    return value;
}

#pragma mark - CGRect functions

/** Returns a rectangle with the `floorf` of all its values applied.
 
 @param r The rectangle to process.
 @return The `floorf` of the supplied rectangle.
 */
CG_INLINE CGRect
CGRectFloor(CGRect r) {
    CGRect rect;
    rect.origin.x = floorf(r.origin.x); rect.origin.y = floorf(r.origin.y);
    rect.size.width = floorf(r.size.width); rect.size.height = floorf(r.size.height);
    return rect;
}

/** Returns a rectangle with the `ceilf` of all its values applied.
 
 @param r The rectangle to process.
 @return The `ceilf` of the supplied rectangle.
 */
CG_INLINE CGRect
CGRectCeil(CGRect r) {
    CGRect rect;
    rect.origin.x = ceilf(r.origin.x); rect.origin.y = ceilf(r.origin.y);
    rect.size.width = ceilf(r.size.width); rect.size.height = ceilf(r.size.height);
    return rect;
}

/** Returns a size with the `floorf` of all its values applied.
 
 @param s The size to process.
 @return The `floorf` of the supplied size.
 */
CG_INLINE CGSize
CGSizeFloor(CGSize s) {
    CGSize size;
    size.width = floorf(s.width); size.height = floorf(s.height);
    return size;
}

/** Returns a size with the `ceilf` of all its values applied.
 
 @param s The size to process.
 @return The `ceilf` of the supplied size.
 */
CG_INLINE CGSize
CGSizeCeil(CGSize s) {
    CGSize size;
    size.width = ceilf(s.width); size.height = ceilf(s.height);
    return size;
}

/** Returns a point with the `floorf` of all its values applied.
 
 @param p The point to process.
 @return The `floorf` of the supplied point.
 */
CG_INLINE CGPoint
CGPointFloor(CGPoint p) {
    CGPoint point;
    point.x = floorf(p.x); point.y = floorf(p.y);
    return point;
}

/** Returns a rectangle whose origin is reset to `0,0`.
 
 @param r The rectangle to process.
 @return The rectangle with its origin adjusted to zero.
 */
CG_INLINE CGRect
CGRectResetOrigin(CGRect r) {
    CGRect rect = r;
    rect.origin.x = rect.origin.y = 0.0;
    return rect;
}

/** Returns the center point for the supplied rectangle, corrected to prevent sub-pixel blurring.
 
 When calculating the center point for a rectangle, if either of its dimensions is an odd
 number it's possible that sub-pixel blurring could occur when placing using the standard
 center-point to position a view on the screen.  This function will correct for that by
 slightly adjusting the center coordinate.
 
 @param r The rectangle to process.
 @return The normalized center point for this rectangle.
 */
CG_INLINE CGPoint
CGRectGetCenterPoint(CGRect r) {
    CGPoint point;
    point.x = CGRectGetMidX(r);
    point.y = CGRectGetMidY(r);
    UIOffset offset = UIOffsetMake((int)r.size.width % 2 ? 0.5 : 0.0, 
                                   (int)r.size.height % 2 ? 0.5 : 0.0);
    point.x += offset.horizontal;
    point.y += offset.vertical;
    return point;
}

/** Returns a size scaled down to fit within a maximum size.
 
 This function ensures that the supplied size is scaled down to fit within the input
 `maxsize`, while ensuring that its original aspect ratio is maintained.
 
 @param size The size to scale down.
 @param maxsize The maximum size the scaled dimensions can be.
 @return The scaled size.
 */
CG_INLINE CGSize
CGSizeScaled(CGSize size, CGSize maxsize) {
    CGFloat scale;
	CGSize newsize = size;
	
	if (newsize.height && (newsize.height > maxsize.height)) {
		scale = maxsize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	if (newsize.width && (newsize.width >= maxsize.width)) {
		scale = maxsize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	return newsize;
}

#endif // ChatterSDKConstants_h

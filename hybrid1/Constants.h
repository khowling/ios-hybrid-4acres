//
//  Constants.h
//  DreamForce
//
//  Created by Damian Tochetto on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define UNUSED(x) ((void)(x))


#if DEBUG==1

#define TRACE(format, arg ...)   do { NSLog(format, arg); } while(0)
#else
#define TRACE(format, arg ...)  do {} while(0)
#endif


// IDP - My Domain key
static NSString* kPrimaryLoginHostPrefKey = @"primary_login_host_pref";
static NSString* kPrimaryLoginHostPrefValue = @"CUSTOM";

static NSString* kCustomLoginHostPrefKey = @"custom_login_host_pref";

// Event Plugin
static NSString* kEnableCalendarKey = @"kEnableCalendarKey";
static NSString* kSyncCalendarKey   = @"kSyncCalendarKey";

static const NSInteger kPresetCalendarAlarmBefore = -900; // 15 x 60 seg

static NSString* kDateFormatterWithTimeZone = @"yyyy-MM-dd HH:mm:ss ZZZZZ";

// Push
static NSString* kPushExtraKey = @"extra";
static NSString* kPushApsKey = @"aps";
static NSString* kPushAlertKey = @"alert";
static NSString* kPushMessageKey = @"message";
static NSString* kPushTokenKey = @"token";
static NSString* kPushOSKey = @"os";
static NSString* kPushiOSValue = @"ios";

// QR
static NSString* kBarcodeTextKey = @"text";
static NSString* kBarcodeFormatKey = @"format";
static NSString* kBarcodeCancelledKey = @"cancelled";

// Calendar
static NSString* kCalendarTitleKey = @"title";
static NSString* kCalendarLocationKey = @"location";
static NSString* kCalendarMessageKey = @"message";
static NSString* kCalendarStartKey = @"startDate";
static NSString* kCalendarEndKey = @"endDate";
static NSString* kCalendarTimeNoTZKey = @"yyyy-MM-dd HH:mm:ss";

static NSString* kCalendarValueKey = @"value";
static NSString* kCalendarValueTrue = @"true";
static NSString* kCalendarValueFalse = @"false";

static NSString* kCalendarKey = @"calendar";

static NSString* kCalendarResultKey = @"result";
static NSString* kCalendarTimesLotsKey = @"timeslots";


static NSString* kCalendarItemsKey = @"items";
static NSString* kCalendarIdKey = @"id";
static NSString* kCalendarEventKitIdKey = @"eventKitId";

static NSString* kCalendarRoomKey = @"room";
static NSString* kCalendarNameKey = @"name";
static NSString* kCalendarRoomNumberKey = @"roomNumber";
static NSString* kCalendarDateOfDayKey = @"dateOfDay";
static NSString* kCalendarStartTimeKey = @"startTime";
static NSString* kCalendarEndTimeKey = @"endTime";

static NSString* kCalendarSpeakersKey = @"speakers";
static NSString* kCalendarFirstNameKey = @"firstName";
static NSString* kCalendarLastNameKey = @"lastName";
static NSString* kCalendarSpeakerNameKey = @"name";

static NSString* kCalendarDescriptionKey = @"shortDescription";


// Email / SMS
static NSString* kEmailToRecipientsKey = @"toRecipients";
static NSString* kEmailCcRecipientsKey = @"ccRecipients";
static NSString* kEmailBcRecipientsKey = @"bccRecipients";
static NSString* kEmailSubjectKey = @"subject";
static NSString* kEmailBodyKey = @"body";
static NSString* kEmailHtmlKey = @"isHTML";

// URL
static NSString* kUrlMngUrlKey = @"url";


static NSString* kCHWebViewUrlKey = @"url";
static NSString* kCHWebViewFileKey = @"file";
static NSString* kCHWebViewNameKey = @"name";

static NSString* kCHWebViewMimeTypeKey = @"mimeType";
static NSString* kCHWebViewSidTypeKey = @"authorization";


static NSString* kPathFileRoot = @"ChatterFiles";

typedef enum
{
    PGOpenFile=0,
    PGOpenImage,
    PGOpenURL
    
} PGOpenFileType;


static const NSTimeInterval kRequestTimeOut = 60.0;

// Aurasma

static const NSTimeInterval kAurasmaImageTimer = 3.5;

static NSString* kFirstTimeRunKey = @"url";

static const CGFloat kPaddingButtoniPhone = 10.0;
static const CGFloat kPaddingButtoniPad = 30.0;


// Barcode
#define kSalesforceColorBlue [UIColor colorWithRed:0.0/255.0 green:157.0/255.0 blue:220.0/255.0 alpha:1.0]
#define kSalesforceColorBlueRect [UIColor colorWithRed:0.0/255.0 green:157.0/255.0 blue:220.0/255.0 alpha:0.4]

static const CGFloat kPaddingTextViewiPhone = 10.0;
static const CGFloat kPaddingTextViewiPad = 20.0;


// Splash

static const NSTimeInterval kMaxTimeToHiddenSplash = 6.0;



#warning Set DOMAIN_PROD = 1 before compile to AppStore

#define DOMAIN_PROD     1

#define DOMAIN_E2D      0
#define DOMAIN_QA       0
#define DOMAIN_DF       0

#define DOMAIN_TEST     0
#define DOMAIN_TEST_RG  0


#if !DOMAIN_PROD && !DOMAIN_E2D && !DOMAIN_QA && !DOMAIN_DF && !DOMAIN_TEST && !DOMAIN_TEST_RG

#error Defining domain is necessary

#endif


#define PUSH_NOTIFICATION_ENABLE    0 // 0 disable / 1 enable

// Prod
static NSString* kMyDomainProd = @"dreamevent.my.salesforce.com";
static NSString* kMyLoginProd = @".force.com";

// Events2Dev dtochetto+etod@gmail.com / SanFrancisco2012
static NSString* kMyDomainE2D = @"dreamevent--events2dev.cs1.my.salesforce.com";
static NSString* kMyLoginE2D = @"cloudevent.events2dev.cs1.force.com";

// QA dtochetto+qa@gmail.com / SanFrancisco2012
static NSString* kMyDomainQA = @"dreamevent--dfchatterq.cs3.my.salesforce.com";
static NSString* kMyLoginQA = @"cloudevent.dfchatterq.cs3.force.com";

// DF Chatter full
//
//static NSString* kMyDomainDF = @"dreamevent--full.cs3.my.salesforce.com";
//static NSString* kMyLoginDF = @"cloudevent.full.cs3.force.com";

static NSString* kMyDomainDF = @"dreamevent--dfcfull.cs12.my.salesforce.com";
static NSString* kMyLoginDF = @"cloudevent.dfcfull.cs12.force.com";

// Test
//static NSString* kMyDomainTest = @"dreamtest-dev-ed.my.salesforce.com";
static NSString* kMyDomainTest = @"login.salesforce.com";
static NSString* kMyLoginTest = @"";

// Test Rodri
static NSString* kMyDomainTestRodri = @"na14.force.com";
static NSString* kMyLoginTestRodri = @"dreamevent-developer-edition.na14.force.com";


//
//  CAUtil.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


// Last info value key
#define kCAKeyDefaultIsCoffeeScript @"KeyDefaultIsCoffeeScript"
#define kCAKeyDefaultIsJQuery @"KeyDefaultIsJQuery"
#define kCAKeyDefaultIsOnError @"KeyDefaultIsOnError"
#define kCAKeyDefaultIsConsoleLog @"KeyDefaultIsConsoleLog"

// Setting key
#define kCAKeySettingTextColor @"KeySettingTextColor"
#define kCAKeySettingBgColor @"KeySettingBgColor"
#define kCAKeySettingFontName @"KeySettingFontName"
#define kCAKeySettingFontSize @"KeySettingFontSize"
#define kCAKeySettingIsCustomKeyboard @"KeySettingIsCustomKeyboard"
#define kCAKeySettingCustomKeys @"KeySettingCustomKeys"
#define kCAKeySettingIsLineNums @"kCAKeySettingIsLineNums"
#define kCAKeySettingIsLineInfo @"kCAKeySettingIsLineInfo"

#define kCAKeySettingIsBodyText @"KeySettingIsBodyText"
#define kCAKeySettingIsAttachment @"KeySettingIsAttachment"
#define kCAKeySettingIsZipball @"KeySettingIsZipball"

#define kCAKeySettingServiceName @"KeySettingServiceName"
#define kCAKeySettingUsername @"KeySettingUsername"
#define kCAKeySettingPassword @"KeySettingPassword"

#define kCAKeyImportUrls @"KeyImportUrls"
#define kCAKeyImportHtml @"KeyImportHtml"
#define kCAKeyImportCss @"KeyImportCss"
#define kCAKeyImportJs @"KeyImportJs"

#define kCAKeyIsFirst @"KeyIsFirst"

@interface CAUtil : NSObject

+ (void)openSafari:(NSString *)title urlString:(NSString *)urlString confirm:(BOOL)confirm;

+ (NSString *)encodeURL:(NSString *)urlString;
+ (NSString *)decodeURL:(NSString *)urlString;

+ (BOOL)isIOS5;
+ (BOOL)isIOS4;

+ (NSArray *)colors;
+ (UIColor *)color:(int)index;
+ (NSArray *)colorNames;
+ (NSString *)colorName:(int)index;

+ (NSArray *)fontNames;
+ (NSString *)fontName:(int)index;
+ (int)fontIndex:(NSString *)name;

+ (NSArray *)fontSizes;
+ (NSString *)fontSize:(int)index;

+ (NSString*)base64:(NSString*)str;

+ (void)showError:(NSString *)message;

@end

#ifdef DEBUG
//# define LOG(...) NSLog(__VA_ARGS__)
//# define LOG(...) NSLog(@"%s %d: ", __func__, __LINE__);NSLog(__VA_ARGS__)
#define LOG(fmt, ...)		NSLog(@"%s:%d：%s\n%@", (strrchr(__FILE__, '/') + 1), __LINE__, __func__, [NSString stringWithFormat:fmt,## __VA_ARGS__])
# define LOG_METHOD NSLog(@"%s", __func__)
#else
# define LOG(...) ;
# define LOG_METHOD ;
#endif


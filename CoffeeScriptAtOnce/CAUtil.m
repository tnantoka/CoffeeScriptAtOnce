//
//  CAUtil.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CAUtil.h"

#import "BlockAlertView.h"

@implementation CAUtil

static NSArray *_colors = nil;
static NSArray *_colorNames = nil;
static NSArray *_fontNames = nil;
static NSArray *_fontSizes = nil;

+ (void)openSafari:(NSString *)title urlString:(NSString *)urlString confirm:(BOOL)confirm {

    if (confirm) {
        
        NSString *alertTitle = [NSString stringWithFormat:@"Open Website"];
        NSString *alertMessage = [NSString stringWithFormat:@"Open \"%@'s site (%@)\" in Safari?", title, urlString];
        
        BlockAlertView *blockAlert = [[BlockAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        
        [blockAlert showWithCompletionHandler:^(NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 0: {
                    NSURL *url = [NSURL URLWithString:urlString];
                    [[UIApplication sharedApplication] openURL:url];
                    break;
                }
                case 1:
                    break;
            }
        }];
        
        [blockAlert release];
        
    } else {
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];        
    }

}

+ (NSString *)encodeURL:(NSString *)urlString {
    CFStringRef strRef = CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                                 (CFStringRef)urlString, 
                                                                 NULL, 
                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                 kCFStringEncodingUTF8);
    NSString * str = [NSString stringWithString:(NSString *)strRef];
    CFRelease(strRef);
    return str;
}

+ (NSString *)decodeURL:(NSString *)urlString {
    CFStringRef strRef = 
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                (CFStringRef)urlString,
                                                                CFSTR(""),
                                                                kCFStringEncodingUTF8);
    NSString * str = [NSString stringWithString:(NSString *)strRef];
    CFRelease(strRef);
    return str;
}

+ (BOOL)isIOS5 {
    NSString *versions = [[UIDevice currentDevice] systemVersion];
    return [versions compare:@"5.0"] != NSOrderedAscending;
}

+ (BOOL)isIOS4 {
    return ![self isIOS5];
}

+ (NSArray *)colors {
    
    if (!_colors) {
        _colors = [[NSArray arrayWithObjects:
                    [UIColor blackColor], 
                    [UIColor darkGrayColor], 
                    [UIColor lightGrayColor], 
                    [UIColor whiteColor], 
                    [UIColor grayColor], 
                    [UIColor redColor], 
                    [UIColor greenColor], 
                    [UIColor blueColor], 
                    [UIColor cyanColor], 
                    [UIColor yellowColor], 
                    [UIColor magentaColor], 
                    [UIColor orangeColor], 
                    [UIColor purpleColor], 
                    [UIColor brownColor], 
                    [UIColor clearColor], 
                    
                    [UIColor lightTextColor], 
                    [UIColor darkTextColor], 
                    [UIColor groupTableViewBackgroundColor], 
                    [UIColor viewFlipsideBackgroundColor], 
                    [UIColor scrollViewTexturedBackgroundColor], 
                    [UIColor underPageBackgroundColor], 
                    nil] retain];
    }    
    
    return _colors;
}

+ (NSArray *)colorNames {
    
    if (!_colorNames) {
        _colorNames = [[NSArray arrayWithObjects:
                        @"blackColor", 
                        @"darkGrayColor", 
                        @"lightGrayColor", 
                        @"whiteColor", 
                        @"grayColor", 
                        @"redColor", 
                        @"greenColor", 
                        @"blueColor", 
                        @"cyanColor", 
                        @"yellowColor", 
                        @"magentaColor", 
                        @"orangeColor", 
                        @"purpleColor", 
                        @"brownColor", 
                        @"clearColor",
                        
                        @"lightTextColor", 
                        @"darkTextColor", 
                        @"groupTableViewBackgroundColor", 
                        @"viewFlipsideBackgroundColor", 
                        @"scrollViewTexturedBackgroundColor", 
                        @"underPageBackgroundColor", 
                        
                        nil] retain];
    }    
    
    return _colorNames;
}

+ (UIColor *)color:(int)index {
    if (index < 0 || index >= [self colors].count) {
        return nil;
    }
    return [[self colors] objectAtIndex:index];    
}

+ (UIColor *)colorName:(int)index {
    if (index < 0 || index >= [self colorNames].count) {
        return nil;
    }
    return [[self colorNames] objectAtIndex:index];    
}

+ (NSArray *)fontNames {
    
    if (!_fontNames) {
        NSMutableArray *fonts = [NSMutableArray array];
        NSArray *familyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)];
        for (id familyName in familyNames) {
            NSArray* fontNames = [[UIFont fontNamesForFamilyName:familyName] sortedArrayUsingSelector:@selector(compare:)];
            for (NSString *fontName in fontNames) {
                [fonts addObject:fontName];
            }
        }    
        _fontNames = [fonts retain];
    }
    
    return _fontNames;
}
                        
+ (NSString *)fontName:(int)index {
    if (index < 0 || index >= [self fontNames].count) {
        return nil;
    }
    return [[self fontNames] objectAtIndex:index];    
}

+ (int)fontIndex:(NSString *)name {
    return [[self fontNames] indexOfObject:name];
}

+ (NSArray *)fontSizes {
    
    if (!_fontSizes) {
        NSMutableArray *sizes = [NSMutableArray array];
        
        for (int i = 9; i < 37; i++) {
            [sizes addObject:[NSString stringWithFormat:@"%d", i]];
        }
                
        _fontSizes = [sizes retain];
    }
    
    return _fontSizes;
}

+ (NSString *)fontSize:(int)index {
    if (index < 0 || index >= [self fontSizes].count) {
        return nil;
    }
    return [[self fontSizes] objectAtIndex:index];    
}


+ (NSString*)base64:(NSString *)str {
	static const char *tbl = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	const char *s = [str UTF8String];
	int length = [str length];
	char *tmp = malloc(length * 4 / 3 + 4);
	int i = 0;
	int n = 0;
	char *p = tmp;
	while (i < length) {
		n = s[i++];
		n *= 256;
		if (i < length) n += s[i];
		i++;
		n *= 256;
		if (i < length) n += s[i]; 		i++; 		 		p[0] = tbl[((n & 0x00fc0000) >> 18)];
		p[1] = tbl[((n & 0x0003f000) >> 12)];
		p[2] = tbl[((n & 0x00000fc0) >>  6)];
		p[3] = tbl[((n & 0x0000003f) >>  0)];
		if (i > length) p[3] = '=';
		if (i > length + 1) p[2] = '=';
		p += 4;
	}
	*p = '\0';
	//NSString *ret = [NSString stringWithCString:tmp];
	NSString *ret = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
	free(tmp);
	return ret;

}

+ (void)showError:(NSString *)message {
    [[[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];    
}

@end


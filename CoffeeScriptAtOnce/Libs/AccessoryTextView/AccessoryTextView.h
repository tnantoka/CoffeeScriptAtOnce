//
//  AccessoryTextView.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccessoryTextView : UITextView <UITextFieldDelegate>

@property (nonatomic, retain) NSMutableArray *keys;

- (void)setUserKeys:(NSString *)userKeys;

- (void)hideAccessory:(BOOL)hidden;

@end

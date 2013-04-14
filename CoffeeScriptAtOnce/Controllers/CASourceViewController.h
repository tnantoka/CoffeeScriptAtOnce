//
//  CASourceViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/09/28.
//
//

#import <UIKit/UIKit.h>

@interface CASourceViewController : UIViewController

@property (nonatomic, assign) id delegate;
- (id)initWithSource:(NSString *)source title:(NSString *)title name:(NSString *)name;
@end

@interface NSObject (CASourceViewControllerDelegate)
- (void)sourceControllerDidClose:(CASourceViewController *)controller;
@end
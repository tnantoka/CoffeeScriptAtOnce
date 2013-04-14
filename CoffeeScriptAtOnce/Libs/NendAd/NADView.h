//
//  NADView.h
//  NendAd
//
//  Ver 1.2.3
//
//  広告枠ベースビュークラス

#import <UIKit/UIKit.h>

#define NAD_ADVIEW_SIZE_320x50  CGSizeMake(320,50)

@class NADView;

@protocol NADViewDelegate <NSObject>

// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView;


@end

@interface NADView : UIView {
    
    id delegate;
    NSInteger retryTime;
    
}

@property (nonatomic, assign) id <NADViewDelegate> delegate;

// モーダルビューを表示元のビューコントローラを指定
@property (nonatomic, assign) UIViewController *rootViewController;

// apikeyとspotのセット
- (void)setNendID:(NSString *)apiKey spotID:(NSString *)spotID;


// 広告のロード
// 送信するパラメータをNSDictionaryの形で作成し、引数として渡す
//
//
- (void)load:(NSDictionary *)parameter;

@end

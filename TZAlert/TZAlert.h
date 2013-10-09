//
//  TZAlert.h
//  atlantis
//
//  Created by Zhou Hangqing on 13-9-18.
//  Copyright (c) 2013年 QomoCorp co.Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    TZAlertPresentationStylePopUp = 0,
    TZAlertPresentationStyleSlideDown,
    TZAlertPresentationStyleSlideUp
} TZAlertPresentationStyle;

@interface TZAlert : UIView

@property (nonatomic, assign) TZAlertPresentationStyle presentationStyle;
@property (nonatomic, assign) BOOL dimBackground;
@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, assign) BOOL tapToHide;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) void(^closeBlock)();
@property (nonatomic, assign) CGSize defaultSize;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *contentText;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *contentFont;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat opacity;

@property (nonatomic, readonly) BOOL isShowing;

- (id)initWithView:(UIView *)view;
- (id)initWithWindow:(UIWindow *)window;

- (void)showWithAnimated:(BOOL)animated;
- (void)show;
- (void)showAndHideAfterDuration:(NSTimeInterval)duration;
- (void)hideWithAnimated:(BOOL)animated;
- (void)hide;
- (void)hideWithCompletionBlock:(void (^)(void))block;

@end

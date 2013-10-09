//
//  TZAlert.m
//  atlantis
//
//  Created by Zhou Hangqing on 13-9-18.
//  Copyright (c) 2013年 QomoCorp co.Ltd. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "TZAlert.h"

#define kFadeInAnimationDuration 0.3
#define kTransformPart1AnimationDuration 0.2
#define kTransformPart2AnimationDuration 0.1

@interface TZAlert ()

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, assign) BOOL hideAfterShown;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGAffineTransform rotationTransform;
@property (nonatomic, copy) void (^completionBlock)();


@end

@implementation TZAlert

#pragma mark - Lifecycle

- (void)dealloc
{
    [self unregisterFromKVO];
    [self unregisterFromNotifications];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.hideAfterShown = NO;
        self.presentationStyle = TZAlertPresentationStylePopUp;
        self.dimBackground = NO;
        self.isModal = NO;
        self.tapToHide = YES;
        self.titleFont = [UIFont systemFontOfSize:16];
        self.contentFont = [UIFont systemFontOfSize:13];
        self.color = nil;
        self.opacity = 0.9;
        
//        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        // Make it invisible first
        self.alpha = 0.0;
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.contentView];
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:self.opacity];;
        self.contentView.layer.cornerRadius = 3;
        
        self.defaultSize = CGSizeMake(frame.size.width * 0.3, frame.size.height * 0.2);
        
        [self setUpLabels];
        [self registerForKVO];
        [self registerForNotifications];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
	NSAssert(view, @"View must not be nil.");
	return [self initWithFrame:view.bounds];
}

- (id)initWithWindow:(UIWindow *)window {
	return [self initWithView:window];
}


- (void)setDefaultSize:(CGSize)defaultSize
{
    _defaultSize = defaultSize;
    
    self.contentView.frame = CGRectMake(0, 0, _defaultSize.width, _defaultSize.height);
}

- (void)setColor:(UIColor *)color
{
    if (color != nil) {
        _color = color;
    } else {
        _color = [UIColor colorWithWhite:0.1 alpha:self.opacity];
    }
    
    self.contentView.backgroundColor = _color;
}

- (void)setCustomView:(UIView *)customView
{
    if (_customView != customView) {
        [_customView removeFromSuperview];
        _customView = customView;
    }
}

#pragma mark - Views


- (void)didMoveToSuperview
{
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        [self setTransformForCurrentOrientation:NO];
    }
}

- (void)setTransformForCurrentOrientation:(BOOL)animated {
	// Stay in sync with the superview
	if (self.superview) {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat radians = 0;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
		else { radians = (CGFloat)M_PI_2; }
		// Window coordinates differ!
		self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
	} else {
		if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
		else { radians = 0; }
	}
	self.rotationTransform = CGAffineTransformMakeRotation(radians);
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	[self setTransform:self.rotationTransform];
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)layoutSubviews
{
    CGSize size = self.contentView.bounds.size;
    if (self.closeButton) {
        self.closeButton.center = CGPointMake(size.width - self.closeButton.frame.size.width * 0.5, self.closeButton.frame.size.height * 0.5);
    }
    self.closeButton.opaque = YES;
    
    if (self.customView) {
        return;
    }
    
    
    self.titleLabel.frame = CGRectMake(0.1 * size.width, 0.05 * size.height, 0.8 * size.width, 0.3 * size.height);
    self.contentLabel.frame = CGRectMake(0.1 * size.width, 0.4 * size.height, 0.8 * size.width, 0.6 * size.height);
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    
	if (self.dimBackground) {
		//Gradient colours
		size_t gradLocationsNum = 2;
		CGFloat gradLocations[2] = {0.0f, 1.0f};
		CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
		CGColorSpaceRelease(colorSpace);
		//Gradient center
		CGPoint gradCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		//Gradient radius
		float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
		//Gradient draw
		CGContextDrawRadialGradient (context, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsAfterEndLocation);
		CGGradientRelease(gradient);
	}

	CGContextFillPath(context);
    
	UIGraphicsPopContext();

}

#pragma mark - UI 

- (void)setUpLabels
{
    self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
	self.titleLabel.adjustsFontSizeToFitWidth = NO;
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.opaque = NO;
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.font = self.contentFont;
	self.titleLabel.text = self.contentText;
	[self.contentView addSubview:self.titleLabel];
	
	self.contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
	self.contentLabel.adjustsFontSizeToFitWidth = NO;
	self.contentLabel.textAlignment = NSTextAlignmentCenter;
	self.contentLabel.opaque = NO;
	self.contentLabel.backgroundColor = [UIColor clearColor];
	self.contentLabel.textColor = [UIColor whiteColor];
	self.contentLabel.numberOfLines = 0;
	self.contentLabel.font = self.contentFont;
	self.contentLabel.text = self.contentText;
	[self.contentView addSubview:self.contentLabel];
}

- (void)updateCloseButton
{
    if (self.closeButton) {
        [self.closeButton removeTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [self.closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.closeButton.superview) {
            [self.closeButton removeFromSuperview];
        }
    
        if (self.customView) {
            [self.customView addSubview:self.closeButton];
            [self.contentView bringSubviewToFront:self.closeButton];

        } else {
            [self.contentView addSubview:self.closeButton];
            [self.contentView bringSubviewToFront:self.closeButton];

        }
        
    }
}

- (void)updateContentViewCenter
{
    CGSize size = self.bounds.size;
    switch (self.presentationStyle) {
        case TZAlertPresentationStylePopUp: {
            self.contentView.center = CGPointMake(size.width * 0.5, size.height * 0.5);
        }
            break;
        case TZAlertPresentationStyleSlideDown: {
            self.contentView.center = CGPointMake(size.width * 0.5, 0 - self.contentView.frame.size.height * 0.5);
        }
            break;
        case TZAlertPresentationStyleSlideUp: {
             self.contentView.center = CGPointMake(size.width * 0.5, size.height + self.contentView.frame.size.height * 0.5);
        }
            break;
        default:
            break;
    }
    
}

- (void)updateCustomView
{
    if (self.customView && self.customView.superview == nil) {
        [self.contentView addSubview:self.customView];
//        self.customView.frame = self.contentView.bounds;
        CGPoint center = self.contentView.center;
        self.contentView.frame = self.customView.frame;
        self.contentView.center = center;
    }
}

#pragma mark - Show & Hide

- (void)showWithAnimated:(BOOL)animated
{
    if (animated) {
        CGRect originFrame = self.contentView.frame;
        CGAffineTransform transform = self.contentView.transform;
        
        self.alpha = 0.0f;
        if (self.presentationStyle == TZAlertPresentationStylePopUp) {
            self.contentView.transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(0.1f, 0.1f));
        }
        
        [UIView animateWithDuration:kFadeInAnimationDuration animations:^{
            self.alpha = 1.0;
        }];
        
        [UIView animateWithDuration:kTransformPart1AnimationDuration animations:^{
            if (self.presentationStyle == TZAlertPresentationStylePopUp) {
                self.contentView.transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(1.1f, 1.1f));
            } else if (self.presentationStyle == TZAlertPresentationStyleSlideDown) {
                self.contentView.transform = CGAffineTransformTranslate(transform, 0, originFrame.size.height * 1.1);
            } else if (self.presentationStyle == TZAlertPresentationStyleSlideUp) {
                self.contentView.transform = CGAffineTransformTranslate(transform, 0, -originFrame.size.height * 1.1);
            }
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:kTransformPart2AnimationDuration animations:^{
                    if (self.presentationStyle == TZAlertPresentationStylePopUp) {
                        self.contentView.transform = transform;
                    } else if (self.presentationStyle == TZAlertPresentationStyleSlideDown) {
                        self.contentView.transform = CGAffineTransformTranslate(transform, 0, originFrame.size.height * 1.0);
                    } else if (self.presentationStyle == TZAlertPresentationStyleSlideUp) {
                        self.contentView.transform = CGAffineTransformTranslate(transform, 0, -originFrame.size.height * 1.0);
                    }
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self showAnimationDone];
                    }
                }];
            }
        }];
    } else {
        [self showAnimationDone];
    }
}

- (void)show
{
    [self showWithAnimated:YES];
}

- (void)showAndHideAfterDuration:(NSTimeInterval)duration
{
    self.hideAfterShown = YES;
    self.duration = duration;
    [self showWithAnimated:YES];
}

- (void)showAnimationDone
{
    _isShowing = YES;
    self.alpha = 1.0;
    
    if (self.hideAfterShown) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:self.duration];
        self.hideAfterShown = NO;
    }
}

- (void)hideWithAnimated:(BOOL)animated
{
    if (animated) {
        
        CGRect originFrame = self.contentView.frame;
     
        [UIView animateWithDuration:kFadeInAnimationDuration animations:^{
            self.alpha = 0.0;
        }];
        
        [UIView animateWithDuration:kTransformPart2AnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.presentationStyle == TZAlertPresentationStylePopUp) {
                self.contentView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            } else if (self.presentationStyle == TZAlertPresentationStyleSlideDown) {
                self.contentView.transform = CGAffineTransformMakeTranslation(0, originFrame.size.height * 1.1);
            } else if (self.presentationStyle == TZAlertPresentationStyleSlideUp) {
                self.contentView.transform = CGAffineTransformMakeTranslation(0, -originFrame.size.height * 1.1);
            }

        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:kTransformPart1AnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    if (self.presentationStyle == TZAlertPresentationStylePopUp) {
                        self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                    } else if (self.presentationStyle == TZAlertPresentationStyleSlideDown) {
                        self.contentView.transform = CGAffineTransformMakeTranslation(0, -originFrame.size.height * 1.0);
                    } else if (self.presentationStyle == TZAlertPresentationStyleSlideUp){
                        self.contentView.transform = CGAffineTransformMakeTranslation(0, originFrame.size.height * 1.0);;
                    }
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self hideAnimationDone];
                    }
                }];

            }
        }];
    } else {
        [self hideAnimationDone];
    }
}

- (void)hide
{
    [self hideWithAnimated:YES];
}

- (void)hideWithCompletionBlock:(void (^)(void))block
{
    self.completionBlock = block;
    [self hide];
}

- (void)hideAnimationDone
{
    _isShowing = NO;
    self.alpha = 0;
    
    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = NULL;
    }
    
    [self removeFromSuperview];
}

#pragma mark - Touches

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit =  [super hitTest:point withEvent:event] ;
    
    if (hit != self.contentView && hit != self.customView && !self.isModal) {
        return nil;
    }
    
    return hit ;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.tapToHide) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(self.contentView.frame, location)) {
        [self hideWithAnimated:YES];
    }
}

#pragma mark - Button handle

- (void)onClose:(UIButton *)button
{
    [self hideWithCompletionBlock:self.closeBlock];
}


#pragma mark - KVO

- (void)registerForKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterFromKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (NSArray *)observableKeypaths {
	return [NSArray arrayWithObjects:@"presentationStyle", @"defaultSize", @"customView", @"titleText", @"contentText", @"titleFont", @"contentFont", @"closeButton", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
	} else {
		[self updateUIForKeypath:keyPath];
	}
}

- (void)updateUIForKeypath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"presentationStyle"] || [keyPath isEqualToString:@"defaultSize"]) {
        [self updateContentViewCenter];
    } else if ([keyPath isEqualToString:@"customView"]) {
        [self updateCustomView];
        [self updateContentViewCenter];
        [self updateCloseButton];
	} else if ([keyPath isEqualToString:@"titleText"]) {
		self.titleLabel.text = self.titleText;
	} else if ([keyPath isEqualToString:@"titleFont"]) {
		self.titleLabel.font = self.titleFont;
	} else if ([keyPath isEqualToString:@"contentText"]) {
		self.contentLabel.text = self.contentText;
	} else if ([keyPath isEqualToString:@"contentFont"]) {
		self.contentLabel.font = self.contentFont;
	} else if ([keyPath isEqualToString:@"closeButton"]) {
        [self updateCloseButton];
	}
    
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)registerForNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	UIView *superview = self.superview;
	if (!superview) {
		return;
	} else if ([superview isKindOfClass:[UIWindow class]]) {
		[self setTransformForCurrentOrientation:YES];
	} else {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
}




@end

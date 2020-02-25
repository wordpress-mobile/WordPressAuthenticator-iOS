#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AuthWPWalkthroughOverlayViewOverlayMode) {
    WPWalkthroughGrayOverlayViewOverlayModeTapToDismiss,
    WPWalkthroughGrayOverlayViewOverlayModeTwoButtonMode,
    WPWalkthroughGrayOverlayViewOverlayModePrimaryButton
};

typedef NS_ENUM(NSUInteger, AuthWPWalkthroughOverlayViewIcon) {
    WPWalkthroughGrayOverlayViewWarningIcon,
    WPWalkthroughGrayOverlayViewBlueCheckmarkIcon,
};

@interface AuthWPWalkthroughOverlayView : UIView

@property (nonatomic, assign) AuthWPWalkthroughOverlayViewOverlayMode overlayMode;
@property (nonatomic, assign) AuthWPWalkthroughOverlayViewIcon icon;
@property (nonatomic, strong) NSString *overlayTitle;
@property (nonatomic, strong) NSString *overlayDescription;
@property (nonatomic, strong) NSString *footerDescription;
@property (nonatomic, strong) NSString *secondaryButtonText;
@property (nonatomic, strong) NSString *primaryButtonText;
@property (nonatomic, assign) BOOL hideBackgroundView;

@property (nonatomic, copy) void (^dismissCompletionBlock)(AuthWPWalkthroughOverlayView *);
@property (nonatomic, copy) void (^secondaryButtonCompletionBlock)(AuthWPWalkthroughOverlayView *);
@property (nonatomic, copy) void (^primaryButtonCompletionBlock)(AuthWPWalkthroughOverlayView *);

- (void)dismiss;

@end

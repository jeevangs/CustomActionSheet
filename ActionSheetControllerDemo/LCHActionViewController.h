//
//  LCHActionViewController.h
//  ActionSheetControllerDemo
//
//  Created by Geddam Subramanyam, Jeevan Kumar on 12/2/15.
//  Copyright © 2015 Honeywell. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LCHActionStyle) {
    LCHActionStyleDefault = 0,
    LCHActionStyleCancel,
    LCHActionStyleDestructive
};

@interface LCHActionItem : NSObject <NSCopying>

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) BOOL isActionInSelectedState;

+ (instancetype) actionWithTitle:(NSString *)title image:(UIImage *)image style:(LCHActionStyle)style handler:(void (^)(LCHActionItem *action))handler;
@end

@interface LCHActionViewController : UIViewController

@property (nonatomic, assign) BOOL backgroundTapDismissalGestureEnabled;
@property (nonatomic, strong) UIColor *separatorColor;

+ (instancetype) initWithTitle:(NSString *)title message:(NSString *)message;
- (void) addAction:(LCHActionItem *)action;
@end

//
//  LCHActionViewController.m
//  ActionSheetControllerDemo
//
//  Created by Geddam Subramanyam, Jeevan Kumar on 12/2/15.
//  Copyright © 2015 Honeywell. All rights reserved.
//

#import "LCHActionViewController.h"

static CGFloat const kAnimationDuration = 0.3f;
static CGFloat const kPaddingFromScreenEdgesForLabel = 20.0f;
static CGFloat const kPaddingBetweenLabelsAndScreen = 5.0f;
static CGFloat const kHeaderSepartorLineHeight = 1.0f;

static NSString *kTableViewCellIdentifier = @"TableViewCellIdentifier";

#pragma mark - LCHSlidingAnimation Class
@interface LCHSlidingAnimationController : NSObject<UIViewControllerAnimatedTransitioning>

@end

@implementation LCHSlidingAnimationController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIView *presentedView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    
    presentedView.frame = containerView.bounds;
    [containerView addSubview:presentedView];
    
    CGAffineTransform transform = presentedView.transform;
    presentedView.transform = CGAffineTransformTranslate(transform, 0, containerView.bounds.size.height);
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        presentedView.transform = transform;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end

#pragma mark - LCHActionViewPresentationController Class

@protocol LCHActionViewPresentationDelegate <NSObject>
- (CGRect) frameForPresentationViewController;
@end

@interface LCHActionViewPresentionController : UIPresentationController

@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, assign) BOOL backgroundTapDismissalGestureEnabled;
@property (nonatomic, weak) id<LCHActionViewPresentationDelegate> actionViewPresentationDelegate;

@end

@implementation LCHActionViewPresentionController

- (UIView *)dimmingView {
    static UIView *instance = nil;
    if (instance == nil) {
        instance = [[UIView alloc] initWithFrame:self.containerView.bounds];
        instance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return instance;
}

- (void)presentationTransitionWillBegin {
    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0;
    [self.containerView addSubview:self.dimmingView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnViewToDismiss)];
    [self.dimmingView addGestureRecognizer:tapGesture];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 1;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect rect = [self.actionViewPresentationDelegate frameForPresentationViewController];
    return rect;
}

- (void)containerViewWillLayoutSubviews {
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

- (void) tappedOnViewToDismiss{
    if (self.backgroundTapDismissalGestureEnabled) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end

#pragma mark - LCHAlertAction Class
@interface LCHActionItem ()

typedef void (^LCHActionHandler)(LCHActionItem *action);

@property (nonatomic, strong) LCHActionHandler handler;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, assign) LCHActionStyle style;
@property (nonatomic, strong) UIImage *image;
@end

@implementation LCHActionItem

static NSDictionary *_defaultFonts = nil;
static NSDictionary *_defaultColors = nil;

+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image style:(LCHActionStyle)style handler:(LCHActionHandler)handler {
    return [[[self class] alloc] initWithTitle:title image:image style:style handler:handler];
}

- (id)initWithTitle:(NSString *)title image:(UIImage *)image style:(LCHActionStyle)style handler:(LCHActionHandler)handler {
    self = [super init];
    if (self) {
        static dispatch_once_t token;
        dispatch_once(&token, ^(void) {
            _defaultFonts = @{
                              @(LCHActionStyleDestructive): [UIFont fontWithName:@"HelveticaNeue" size:18.0f],
                              @(LCHActionStyleDefault): [UIFont fontWithName:@"HelveticaNeue" size:18.0f],
                              @(LCHActionStyleCancel): [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]
                              };
            
            _defaultColors = @{
                               @(LCHActionStyleDestructive): [UIColor colorWithRed:1.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0f],
                               @(LCHActionStyleDefault): [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f],
                               @(LCHActionStyleCancel): [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f]
                               };
        });
        
        self.isActionInSelectedState = NO;
        self.handler = handler;
        self.style = style;
        self.title = title;
        self.font = [self.defaultFonts objectForKey:@(style)];
        self.image = image;
        self.titleColor = [self.defaultColors objectForKey:@(style)];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    LCHActionItem *clone = [[[self class] allocWithZone:zone] initWithTitle:_title image:_image style:_style handler:_handler];
    self.font = [_font copyWithZone:zone];
    self.titleColor = [_titleColor copyWithZone:zone];
    return clone;
}

- (void) setIsActionInSelectedState:(BOOL)isActionInSelectedState{
    _isActionInSelectedState = isActionInSelectedState;
}

- (NSDictionary *)defaultFonts {
    return _defaultFonts;
}

- (NSDictionary *)defaultColors {
    return _defaultColors;
}

@end

#pragma mark - LCHActionViewController Class
@interface LCHActionViewController ()<UIViewControllerTransitioningDelegate, LCHActionViewPresentationDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *actionSheetTitle;
@property (nonatomic, strong) NSString *actionSheetMessage;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasourceArray;
@end

@implementation LCHActionViewController

+ (instancetype) initWithTitle:(NSString *)title message:(NSString *)message{
    LCHActionViewController *actionViewController = [[LCHActionViewController alloc] init];
    actionViewController.actionSheetTitle = title;
    actionViewController.actionSheetMessage = message;
    return actionViewController;
}

- (id) init{
    self = [super init];
    if(self){
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id) initWithTitle:(NSString *)title message:(NSString *)message{
    self = [super init];
    if(self){
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.modalPresentationStyle = UIModalPresentationPopover;
        }
    }
    return self;
}

- (void)commonInit {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    else {
        self.modalPresentationStyle = UIModalPresentationPopover;
        
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.datasourceArray = [NSMutableArray array];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellIdentifier];
    [self.view addSubview:self.tableView];
    
    id topLayoutGuide = self.topLayoutGuide;
    id bottomLayoutGuide = self.bottomLayoutGuide;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_tableView, topLayoutGuide, bottomLayoutGuide);
    
    NSArray *constraints = @[
                             @"H:|-0-[_tableView]-0-|",
                             @"V:|-0-[_tableView]-0-|"
                             ];
    for (NSString *constraint in constraints){
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraint options:0 metrics:nil views:viewsDictionary]];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.preferredContentSize = CGSizeMake(300, [self frameForPresentationViewController].size.height);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Public methods -

- (void) addAction:(LCHActionItem *)action{
    [self.datasourceArray addObject:[self dictionaryFromLCHActionItem:action]];
    [self.tableView reloadData];
}

# pragma mark - Accessor methods -

- (void) setSeparatorColor:(UIColor *)separatorColor{
    _separatorColor = separatorColor;
    self.tableView.separatorColor = separatorColor;
}

# pragma mark - Private methods -
- (void) tappedOnViewToDismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)dictionaryFromLCHActionItem:(LCHActionItem *)actionItem{
    NSDictionary *dictionary = @{@"title": actionItem.title ? actionItem.title : @"", @"style":@(actionItem.style), @"font":actionItem.font, @"titleColor":actionItem.titleColor, @"isActionItemInSelectedState":@(actionItem.isActionInSelectedState), @"handler":actionItem.handler, @"actionItem":actionItem};
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    if(actionItem.image){
        [mutableDictionary setObject:actionItem.image forKey:@"image"];
    }
    return mutableDictionary;
}

-(CGRect) boundingRectForString:(NSString *)string withMaxSize:(CGSize)maxSize withFont:(UIFont *)font{
    CGRect rect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                  NSFontAttributeName:font
                                                                                                                  } context:nil];
    return rect;
}

# pragma mark - UIViewController transition delegate methods -
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[LCHSlidingAnimationController alloc] init];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    LCHActionViewPresentionController *presentationController = [[LCHActionViewPresentionController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    presentationController.backgroundTapDismissalGestureEnabled = self.backgroundTapDismissalGestureEnabled;
    presentationController.actionViewPresentationDelegate = self;
    return presentationController;
}

# pragma mark - LCHActionViewPresentation delegate method -

- (CGRect) frameForPresentationViewController
{
    CGRect actionSheetTitleLabelRect = CGRectZero;
    CGRect actionSheetMessageLabelRect = CGRectZero;
    CGSize maxSize;
    CGFloat heightOfHeaderView;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        maxSize = CGSizeMake(300 - kPaddingFromScreenEdgesForLabel, MAXFLOAT);
    }
    else {
        maxSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - kPaddingFromScreenEdgesForLabel, MAXFLOAT);
    }
    
    if(self.actionSheetTitle){
        actionSheetTitleLabelRect = [self boundingRectForString:self.actionSheetTitle withMaxSize:maxSize withFont:[UIFont systemFontOfSize:15]];
    }
    
    if(self.actionSheetMessage){
        actionSheetMessageLabelRect = [self boundingRectForString:self.actionSheetMessage withMaxSize:maxSize withFont:[UIFont systemFontOfSize:13]];
    }
    
    if(!self.actionSheetTitle && !self.actionSheetMessage){
        heightOfHeaderView = 0.0f;
    }
    else if(self.actionSheetMessage && self.actionSheetTitle){
        heightOfHeaderView = (3*kPaddingBetweenLabelsAndScreen);
    }
    else{
        heightOfHeaderView = 2*kPaddingBetweenLabelsAndScreen;
    }
    
    CGFloat headerViewRectHeight = ceilf(CGRectGetHeight(actionSheetMessageLabelRect)) + ceilf(CGRectGetHeight(actionSheetTitleLabelRect)) + heightOfHeaderView;
    
    CGFloat totalTableViewCellHeight = [self.datasourceArray count] * 50.0f;
    CGRect rectToBeReturned =  CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - headerViewRectHeight - totalTableViewCellHeight , CGRectGetWidth([UIScreen mainScreen].bounds), headerViewRectHeight + totalTableViewCellHeight);
    return rectToBeReturned;
}

# pragma mark - UITableView datasource methods -

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datasourceArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(!self.actionSheetMessage && !self.actionSheetTitle){
        return nil;
    }
    
    CGSize maxSize = CGSizeMake(CGRectGetWidth(tableView.bounds) - kPaddingFromScreenEdgesForLabel, MAXFLOAT);
    CGRect actionSheetTitleLabelRect = CGRectZero;
    CGRect actionSheetMessageLabelRect = CGRectZero;
    
    if(self.actionSheetTitle){
        actionSheetTitleLabelRect = [self boundingRectForString:self.actionSheetTitle withMaxSize:maxSize withFont:[UIFont systemFontOfSize:15]];
    }
    
    if(self.actionSheetMessage){
        actionSheetMessageLabelRect = [self boundingRectForString:self.actionSheetMessage withMaxSize:maxSize withFont:[UIFont systemFontOfSize:13]];
    }
    
    UIView *containerView = [[UIView alloc] init];
    containerView.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(actionSheetMessageLabelRect)+CGRectGetHeight(actionSheetTitleLabelRect)+ (3*kPaddingBetweenLabelsAndScreen));
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.frame = CGRectMake(kPaddingFromScreenEdgesForLabel/2, kPaddingBetweenLabelsAndScreen, CGRectGetWidth(tableView.bounds) - kPaddingFromScreenEdgesForLabel, ceilf(CGRectGetHeight(actionSheetTitleLabelRect)));
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.actionSheetTitle;
    [containerView addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.numberOfLines = 0;
    messageLabel.frame = CGRectMake(kPaddingFromScreenEdgesForLabel/2, (2* kPaddingBetweenLabelsAndScreen) + ceilf(CGRectGetHeight(actionSheetTitleLabelRect)), CGRectGetWidth(tableView.bounds) - kPaddingFromScreenEdgesForLabel, ceilf(CGRectGetHeight(actionSheetMessageLabelRect)));
    messageLabel.font = [UIFont systemFontOfSize:13];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = self.actionSheetMessage;
    [containerView addSubview:messageLabel];
    
    UIView *headerSeparatorLine = [[UIView alloc] init];
    headerSeparatorLine.frame = CGRectMake(0, CGRectGetMaxY(messageLabel.frame) + kPaddingBetweenLabelsAndScreen, CGRectGetWidth(tableView.frame), kHeaderSepartorLineHeight);
    headerSeparatorLine.backgroundColor = [UIColor blackColor];
    [containerView addSubview:headerSeparatorLine];
    
    return containerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(!self.actionSheetTitle && !self.actionSheetMessage){
        return 0;
    }
    CGRect actionSheetTitleLabelRect = CGRectZero;
    CGRect actionSheetMessageLabelRect = CGRectZero;
    CGSize maxSize = CGSizeMake(CGRectGetWidth(tableView.bounds) - kPaddingFromScreenEdgesForLabel, MAXFLOAT);
    if(self.actionSheetTitle){
        actionSheetTitleLabelRect = [self boundingRectForString:self.actionSheetTitle withMaxSize:maxSize withFont:[UIFont systemFontOfSize:15]];
    }
    
    if(self.actionSheetMessage){
        actionSheetMessageLabelRect = [self boundingRectForString:self.actionSheetMessage withMaxSize:maxSize withFont:[UIFont systemFontOfSize:13]];
    }
    CGRect headerViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), ceilf(CGRectGetHeight(actionSheetMessageLabelRect)) + ceilf(CGRectGetHeight(actionSheetTitleLabelRect)) + (3*kPaddingBetweenLabelsAndScreen)+ kHeaderSepartorLineHeight);
    return CGRectGetHeight(headerViewRect);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    if(cell){
        NSDictionary *actionDictionary = self.datasourceArray[indexPath.row];
        cell.textLabel.text = actionDictionary[@"title"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        if(actionDictionary[@"image"]){
            cell.imageView.image = actionDictionary[@"image"];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

# pragma mark - UITableView delegate methods -

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LCHActionHandler handler = self.datasourceArray[indexPath.row][@"handler" ];
    handler(self.datasourceArray[indexPath.row][@"actionItem"]);
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

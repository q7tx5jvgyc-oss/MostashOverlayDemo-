#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const kMostashActivationKey = @"MOSTAH77669";
static NSString * const kMostashActivationFlag = @"mostash_overlay_activated";

@interface MostashTargetView : UIView
@end

@implementation MostashTargetView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = frame.size.width / 2.0;
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor systemYellowColor].CGColor;

        UILabel *crown = [[UILabel alloc] initWithFrame:self.bounds];
        crown.text = @"♛";
        crown.textAlignment = NSTextAlignmentCenter;
        crown.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
        crown.textColor = [UIColor systemYellowColor];
        [self addSubview:crown];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}
@end

@interface MostashOverlayManager : NSObject
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UISlider *speedSlider;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) NSMutableArray<MostashTargetView *> *targets;
@property (nonatomic, assign) BOOL panelVisible;
@property (nonatomic, assign) BOOL isRunning;
+ (instancetype)shared;
- (void)showOverlayIfNeeded;
@end

@implementation MostashOverlayManager

+ (instancetype)shared {
    static MostashOverlayManager *mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [MostashOverlayManager new];
        mgr.targets = [NSMutableArray array];
    });
    return mgr;
}

- (BOOL)isActivated {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kMostashActivationFlag];
}

- (void)setActivated:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kMostashActivationFlag];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showOverlayIfNeeded {
    if (self.overlayWindow) return;

    CGRect screenBounds = UIScreen.mainScreen.bounds;
    self.overlayWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    self.overlayWindow.windowLevel = UIWindowLevelAlert + 999;
    self.overlayWindow.backgroundColor = [UIColor clearColor];
    self.overlayWindow.hidden = NO;

    UIViewController *root = [UIViewController new];
    root.view.backgroundColor = [UIColor clearColor];
    self.overlayWindow.rootViewController = root;

    [self buildFloatingButton];
    [self buildPanel];

    [root.view addSubview:self.floatingButton];
    [root.view addSubview:self.panel];

    if (![self isActivated]) {
        [self presentActivationOverlay];
    }
}

- (void)buildFloatingButton {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(40, 180, 76, 76);
    self.floatingButton.layer.cornerRadius = 38;
    self.floatingButton.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.12 alpha:0.95];
    self.floatingButton.layer.borderWidth = 2.0;
    self.floatingButton.layer.borderColor = [UIColor systemMintColor].CGColor;
    self.floatingButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.floatingButton.layer.shadowOpacity = 0.35;
    self.floatingButton.layer.shadowRadius = 12;
    self.floatingButton.layer.shadowOffset = CGSizeMake(0, 6);

    [self.floatingButton setTitle:@"موستاش" forState:UIControlStateNormal];
    self.floatingButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    [self.floatingButton addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleButtonPan:)];
    [self.floatingButton addGestureRecognizer:pan];
}

- (UIButton *)makeButtonWithTitle:(NSString *)title frame:(CGRect)frame color:(UIColor *)color action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    btn.layer.cornerRadius = 12;
    btn.backgroundColor = color;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)buildPanel {
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(40, 270, 230, 230)];
    self.panel.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.10 alpha:0.96];
    self.panel.layer.cornerRadius = 18;
    self.panel.layer.borderWidth = 1.5;
    self.panel.layer.borderColor = [UIColor systemTealColor].CGColor;
    self.panel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.panel.layer.shadowOpacity = 0.28;
    self.panel.layer.shadowRadius = 10;
    self.panel.layer.shadowOffset = CGSizeMake(0, 5);
    self.panel.hidden = YES;
    self.panel.alpha = 0.0;

    UIPanGestureRecognizer *panelPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanelPan:)];
    [self.panel addGestureRecognizer:panelPan];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 206, 24)];
    title.text = @"لوحة موستاش";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    [self.panel addSubview:title];

    self.speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 40, 206, 18)];
    self.speedLabel.text = @"السرعة: 1.0x";
    self.speedLabel.textColor = UIColor.systemGray2Color;
    self.speedLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [self.panel addSubview:self.speedLabel];

    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(12, 62, 206, 30)];
    self.speedSlider.minimumValue = 0.2;
    self.speedSlider.maximumValue = 5.0;
    self.speedSlider.value = 1.0;
    [self.speedSlider addTarget:self action:@selector(speedChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:self.speedSlider];

    UIButton *startBtn = [self makeButtonWithTitle:@"بدء" frame:CGRectMake(12, 102, 95, 38) color:[UIColor systemGreenColor] action:@selector(startTapped)];
    UIButton *stopBtn  = [self makeButtonWithTitle:@"توقف" frame:CGRectMake(123, 102, 95, 38) color:[UIColor systemRedColor] action:@selector(stopTapped)];
    UIButton *addBtn   = [self makeButtonWithTitle:@"إضافة هدف" frame:CGRectMake(12, 150, 95, 38) color:[UIColor systemBlueColor] action:@selector(addTargetTapped)];
    UIButton *clrBtn   = [self makeButtonWithTitle:@"مسح الهدف" frame:CGRectMake(123, 150, 95, 38) color:[UIColor systemOrangeColor] action:@selector(clearTargetsTapped)];

    UIButton *toolsBtn = [self makeButtonWithTitle:@"تفعيل أدوات موستاش" frame:CGRectMake(12, 196, 206, 24) color:[UIColor systemPurpleColor] action:@selector(toolsTapped)];

    [self.panel addSubview:startBtn];
    [self.panel addSubview:stopBtn];
    [self.panel addSubview:addBtn];
    [self.panel addSubview:clrBtn];
    [self.panel addSubview:toolsBtn];
}

- (void)togglePanel {
    if (![self isActivated]) {
        [self presentActivationOverlay];
        return;
    }

    self.panelVisible = !self.panelVisible;
    self.panel.hidden = NO;

    [UIView animateWithDuration:0.22 animations:^{
        self.panel.alpha = self.panelVisible ? 1.0 : 0.0;
        self.panel.transform = self.panelVisible ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        self.panel.hidden = !self.panelVisible;
    }];
}

- (void)handleButtonPan:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint t = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + t.x, view.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}

- (void)handlePanelPan:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint t = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + t.x, view.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}

- (void)speedChanged:(UISlider *)slider {
    self.speedLabel.text = [NSString stringWithFormat:@"السرعة: %.1fx", slider.value];
}

- (void)startTapped {
    self.isRunning = YES;
    [self toast:@"تم بدء الوضع التجريبي"];
}

- (void)stopTapped {
    self.isRunning = NO;
    [self toast:@"تم الإيقاف"];
}

- (void)addTargetTapped {
    CGRect frame = CGRectMake(arc4random_uniform(220) + 30, arc4random_uniform(360) + 100, 44, 44);
    MostashTargetView *target = [[MostashTargetView alloc] initWithFrame:frame];
    [self.overlayWindow.rootViewController.view addSubview:target];
    [self.targets addObject:target];

    target.alpha = 0.0;
    target.transform = CGAffineTransformMakeScale(0.4, 0.4);
    [UIView animateWithDuration:0.25 animations:^{
        target.alpha = 1.0;
        target.transform = CGAffineTransformIdentity;
    }];
}

- (void)clearTargetsTapped {
    for (UIView *v in self.targets) {
        [v removeFromSuperview];
    }
    [self.targets removeAllObjects];
    [self toast:@"تم مسح الأهداف"];
}

- (void)toolsTapped {
    [self toast:@"أدوات موستاش في النسخة الآمنة شكلية وتجريبية فقط"];
}

- (void)presentActivationOverlay {
    if ([self.overlayWindow.rootViewController.view viewWithTag:909090]) return;

    UIView *cover = [[UIView alloc] initWithFrame:self.overlayWindow.bounds];
    cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.72];
    cover.tag = 909090;

    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(30, 180, self.overlayWindow.bounds.size.width - 60, 220)];
    card.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    card.layer.cornerRadius = 18;
    card.center = cover.center;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, card.bounds.size.width - 32, 28)];
    title.text = @"تفعيل الاشتراك في أوتو موستاش";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [card addSubview:title];

    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(16, 56, card.bounds.size.width - 32, 42)];
    desc.text = @"أدخل كود التفعيل داخل تطبيق الاختبار.";
    desc.numberOfLines = 2;
    desc.textAlignment = NSTextAlignmentCenter;
    desc.textColor = UIColor.systemGray2Color;
    desc.font = [UIFont systemFontOfSize:14];
    [card addSubview:desc];

    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(16, 112, card.bounds.size.width - 32, 42)];
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.placeholder = @"Activation Code";
    field.textAlignment = NSTextAlignmentCenter;
    field.tag = 7001;
    [card addSubview:field];

    UIButton *activate = [UIButton buttonWithType:UIButtonTypeSystem];
    activate.frame = CGRectMake(16, 166, card.bounds.size.width - 32, 40);
    activate.backgroundColor = [UIColor systemMintColor];
    activate.layer.cornerRadius = 12;
    [activate setTitle:@"تفعيل" forState:UIControlStateNormal];
    [activate setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    activate.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    [activate addTarget:self action:@selector(handleActivationButton:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:activate];

    [cover addSubview:card];
    [self.overlayWindow.rootViewController.view addSubview:cover];
}

- (void)handleActivationButton:(UIButton *)sender {
    UIView *cover = [self.overlayWindow.rootViewController.view viewWithTag:909090];
    UITextField *field = [cover viewWithTag:7001];
    NSString *value = field.text ?: @"";

    if ([value isEqualToString:kMostashActivationKey]) {
        [self setActivated:YES];
        [cover removeFromSuperview];
        [self toast:@"اهلا تم تفعيل الاوتو الخاص في المطور موستاش استمتع🤗!" duration:5.0];
    } else {
        [self toast:@"كود غير صحيح"];
    }
}

- (void)toast:(NSString *)text {
    [self toast:text duration:2.0];
}

- (void)toast:(NSString *)text duration:(NSTimeInterval)duration {
    UILabel *toast = [[UILabel alloc] initWithFrame:CGRectMake(24, self.overlayWindow.bounds.size.height - 140, self.overlayWindow.bounds.size.width - 48, 44)];
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.78];
    toast.textColor = UIColor.whiteColor;
    toast.textAlignment = NSTextAlignmentCenter;
    toast.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    toast.layer.cornerRadius = 12;
    toast.layer.masksToBounds = YES;
    toast.text = text;
    toast.alpha = 0.0;

    [self.overlayWindow.rootViewController.view addSubview:toast];

    [UIView animateWithDuration:0.2 animations:^{
        toast.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                toast.alpha = 0.0;
            } completion:^(BOOL finished2) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

@end

__attribute__((constructor))
static void mostash_overlay_entry() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MostashOverlayManager shared] showOverlayIfNeeded];
    });
}

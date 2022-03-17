//
//  ViewController.m
//  FloatingRestScreenVideoPlayer
//
//  Created by 董帅文 on 2021/6/21.
//

#import "ViewController.h"

#import "SuperPlayer.h"

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>


// 主要是用于区分是否是 刘海屏
#define isXSeriesPhone \
({BOOL isLiuHaiPhone = NO;\
if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {\
    (isLiuHaiPhone);\
}\
CGSize size = [UIScreen mainScreen].bounds.size;\
NSInteger notchValue = size.width / size.height * 100;\
if (216 == notchValue || 46 == notchValue) {\
    isLiuHaiPhone = YES;\
}\
(isLiuHaiPhone);})

/*导航栏高度*/
#define kNavHeight (44)
/*tab栏高度*/
#define kTabHeight (49)
/*状态栏高度(iPhoneX+ 状态栏高度认为是safeAreaInsets.top顶部安全区的高度44)*/
#define kStatusBarHeight (CGFloat)(isXSeriesPhone?(44.0):(20.0))
/*底部安全区高度(iPhoneX+ :safeAreaInsets.bottom底部安全区的高度34)*/
#define kSafeAreaBottomHeight (CGFloat)(isXSeriesPhone?(34.0):(0.0))
/*状态栏高度+导航栏高度*/
#define kNavAndStatusHeight (kNavHeight+kStatusBarHeight)

@interface ViewController () <SuperPlayerDelegate, SuperPlayerWindowDelegate>
@property (strong, nonatomic) UIView *playerFatherView;
@property (strong, nonatomic) SuperPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *floatingBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadUIView];
    
    self.title = @"悬浮窗后台播放器";
    self.playerView.fatherView = self.playerFatherView;
    [self.playerView setHidden:YES];
    [self.playerFatherView setHidden:YES];
}


- (SuperPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[SuperPlayerView alloc] init];
        _playerView.fatherView = _playerFatherView;
        _playerView.loop = YES;
        _playerView.supportBackgroundPlayer = NO;
        _playerView.delegate = self;
    }
    return _playerView;
}

- (void)loadUIView {
    UIView* bannerView = [[UIView alloc] init];
    [self.view addSubview:bannerView];
    float navAndStatusHeight = kNavAndStatusHeight;
    [bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(navAndStatusHeight);
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(240);
    }];
    
    UIImageView* bannerImageView = [[UIImageView alloc] init];
    [bannerView addSubview:bannerImageView];
    [bannerImageView setImage:[UIImage imageNamed:@"theme"]];
    [bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.leading.trailing.mas_equalTo(0);
    }];
    
    self.playerFatherView = [[UIView alloc] init];
    [self.playerFatherView setBackgroundColor:[UIColor clearColor]];
    [bannerView addSubview:self.playerFatherView];
    [self.playerFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.leading.trailing.mas_equalTo(0);
    }];
}

- (IBAction)playVideo1:(id)sender {
    SuperPlayerModel *model = [SuperPlayerModel new];
    model.videoURL = @"https://stream7.iqilu.com/10339/upload_transcode/202002/18/20200218114723HDu3hhxqIT.mp4";
    [self playModel:model];
}

- (IBAction)playVideo2:(id)sender {
    SuperPlayerModel *model = [SuperPlayerModel new];
    model.videoURL = @"https://stream7.iqilu.com/10339/upload_transcode/202002/18/20200218093206z8V1JuPlpe.mp4";
    [self playModel:model];
}

- (IBAction)playVideo3:(id)sender {
    SuperPlayerModel *model = [SuperPlayerModel new];
    model.videoURL = @"https://stream7.iqilu.com/10339/article/202002/18/2fca1c77730e54c7b500573c2437003f.mp4";
    [self playModel:model];
}

- (void)playModel:(SuperPlayerModel *)model {
    if (!SuperPlayerWindowShared.isShowing) {
        [self.floatingBtn setHidden:NO];
    }
//    [self.playerView.controlView setTitle:@"这是新播放的视频"];
    [self.playerView.coverImageView setImage:nil];
    [self.playerView playWithModel:model];
    [self.playerView setHidden:NO];
    [self.playerFatherView setHidden:NO];
}

- (IBAction)supportBackgroundPlayerSwitch:(id)sender {
    UISwitch* control = (UISwitch*)sender;
    if (control.on) {
        self.playerView.supportBackgroundPlayer = YES;
    } else {
        self.playerView.supportBackgroundPlayer = NO;
    }
}

- (IBAction)floatingBtnClick:(id)sender {
    [self.floatingBtn setHidden:YES];
    
    // 悬浮窗播放设置
    [SuperPlayerWindowShared setSuperPlayer:self.playerView];
    [SuperPlayerWindowShared show];
    SuperPlayerWindowShared.backController = self;
    
    UIWindow * window = nil;
    if (@available(iOS 13.0, *)) {
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene* windowScene = (UIWindowScene *)array[0];
        SceneDelegate* sceDelegate =(SceneDelegate *)windowScene.delegate;
        window = sceDelegate.window;
    } else {
        AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        window = appDelegate.window;
    }
    [window addSubview:SuperPlayerWindowShared];
}


#pragma mark - SuperPlayerDelegate
- (void)superPlayerBackAction:(SuperPlayerView *)player {

}

/// 返回事件
- (void)superPlayerWindowBackBtnClick {
    [self.floatingBtn setHidden:NO];
}

/// 关闭事件
- (void)superPlayerWindowCloseBtnClick {
//    [self.playerView pause];
    [self.playerView resetPlayer];
    [self.playerView setHidden:YES];
}

@end

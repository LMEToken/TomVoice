//
//  LXActivity.h
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpectrumView.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>


@protocol TomActivityDelegate <NSObject>

- (void)didClickOnButtonWithUrl:(NSURL *)url;

@optional
- (void)didClickOnCancelButton;
@end
typedef NS_ENUM(NSInteger, VoiceButtonStatus) {
    VoiceStatusLuyinStar,
    VoiceStatusLuyinIng,
    VoiceStatusLuyinEnd
};
@interface TomActivity : UIView

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机;

@property (nonatomic,assign) VoiceButtonStatus status;

- (id)initWithTitle:(NSString *)title delegate:(id<TomActivityDelegate>)delegate height:(CGFloat)heigt;

- (void)showInView:(UIView *)view;



@end

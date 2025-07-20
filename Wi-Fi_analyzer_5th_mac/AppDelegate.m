//
//  AppDelegate.m
//  Wi-Fi_analyzer_5th_mac
//
//  Created by 上川雅弘 on 2025/07/08.
//
//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "ViewController.h" // ViewControllerをインポート

@interface AppDelegate ()

// ウィンドウをプロパティとして保持
@property (strong, nonatomic) NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // 位置情報サービスの許可を要求
    [self requestLocationPermission];

    // ウィンドウを作成
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600)
                                              styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"Wi-Fi Analyzer"];
    [self.window center];

    // ViewControllerをインスタンス化してウィンドウに設定
    ViewController *viewController = [[ViewController alloc] init];
    self.window.contentViewController = viewController;

    // ウィンドウを表示
    [self.window makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // アプリケーション終了時の処理
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

// 以下、位置情報関連のコードは変更なし
- (void)requestLocationPermission {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
         NSLog(@"位置情報の許可状態: 未決定");
    } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [self showLocationPermissionAlert];
    } else {
        NSLog(@"位置情報の使用が許可されています");
    }
}

- (void)showLocationPermissionAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"位置情報の許可が必要です";
    alert.informativeText = @"Wi-Fi情報を取得するためには位置情報の使用許可が必要です。システム環境設定から許可してください。";
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"システム環境設定を開く"];
    
    NSModalResponse response = [alert runModal];
    
    if (response == NSAlertSecondButtonReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"]];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [self showLocationPermissionAlert];
    } else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"位置情報の使用が許可されました");
    }
}

@end
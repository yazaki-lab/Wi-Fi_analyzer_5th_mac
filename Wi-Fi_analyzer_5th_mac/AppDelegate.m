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

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // 位置情報サービスの許可を要求（macOS 10.15以降でWi-Fi情報にアクセスするため）
    [self requestLocationPermission];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // アプリケーション終了時の処理
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (void)requestLocationPermission {
    // 位置情報マネージャーを初期化
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // 位置情報の許可状態を確認
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            // macOSでは自動的に許可を要求
            NSLog(@"位置情報の許可状態: 未決定");
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            // 許可が拒否されている場合の処理
            [self showLocationPermissionAlert];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // macOSでは常に許可のみ
            NSLog(@"位置情報の使用が許可されています");
            break;
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
        // システム環境設定を開く
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"]];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            // macOSでは常に許可のみ
            NSLog(@"位置情報の使用が許可されました");
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [self showLocationPermissionAlert];
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            // まだ決定されていない
            break;
    }
}

@end


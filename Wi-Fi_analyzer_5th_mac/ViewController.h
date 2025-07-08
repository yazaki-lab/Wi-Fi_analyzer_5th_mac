//
//  ViewController.h
//

#import <Cocoa/Cocoa.h>
#import <CoreWLAN/CoreWLAN.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *scanButton;
@property (weak) IBOutlet NSTextField *currentSSIDLabel;
@property (weak) IBOutlet NSTextField *currentBSSIDLabel;
@property (weak) IBOutlet NSTableView *scanResultsTableView;

- (IBAction)scanButtonPressed:(id)sender;

@end

//
//  ViewController.m
//

#import "ViewController.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) CWWiFiClient *wifiClient;
@property (strong, nonatomic) NSArray<CWNetwork *> *scanResults;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *displayData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Wi-Fiクライアントを初期化
    self.wifiClient = [[CWWiFiClient alloc] init];
    self.displayData = [[NSMutableArray alloc] init];
    
    // テーブルビューの設定
    [self setupTableView];
    
    // 現在の接続情報を取得
    [self getCurrentWiFiInfo];
}

- (void)setupTableView {
    // テーブルビューのカラムを設定
    NSTableColumn *ssidColumn = [[NSTableColumn alloc] initWithIdentifier:@"SSID"];
    ssidColumn.title = @"SSID";
    ssidColumn.width = 200;
    [self.scanResultsTableView addTableColumn:ssidColumn];
    
    NSTableColumn *bssidColumn = [[NSTableColumn alloc] initWithIdentifier:@"BSSID"];
    bssidColumn.title = @"BSSID";
    bssidColumn.width = 200;
    [self.scanResultsTableView addTableColumn:bssidColumn];
    
    NSTableColumn *rssiColumn = [[NSTableColumn alloc] initWithIdentifier:@"RSSI"];
    rssiColumn.title = @"RSSI";
    rssiColumn.width = 80;
    [self.scanResultsTableView addTableColumn:rssiColumn];
    
    self.scanResultsTableView.dataSource = self;
    self.scanResultsTableView.delegate = self;
}

- (void)getCurrentWiFiInfo {
    // 現在の接続情報を取得
    NSSet *interfaceNames = [CWWiFiClient interfaceNames];
    
    if (interfaceNames.count > 0) {
        NSString *interfaceName = [interfaceNames anyObject];
        CWInterface *interface = [self.wifiClient interfaceWithName:interfaceName];
        
        if (interface) {
            NSString *currentSSID = interface.ssid ?: @"未接続";
            NSString *currentBSSID = interface.bssid ?: @"未接続";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentSSIDLabel.stringValue = [NSString stringWithFormat:@"現在のSSID: %@", currentSSID];
                self.currentBSSIDLabel.stringValue = [NSString stringWithFormat:@"現在のBSSID: %@", currentBSSID];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentSSIDLabel.stringValue = @"現在のSSID: Wi-Fiインターフェースが見つかりません";
            self.currentBSSIDLabel.stringValue = @"現在のBSSID: Wi-Fiインターフェースが見つかりません";
        });
    }
}

- (IBAction)scanButtonPressed:(id)sender {
    // スキャンボタンを無効化
    self.scanButton.enabled = NO;
    self.scanButton.title = @"スキャン中...";
    
    // バックグラウンドでスキャンを実行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performWiFiScan];
    });
}

- (void)performWiFiScan {
    // Wi-Fiインターフェースを取得
    NSSet *interfaceNames = [CWWiFiClient interfaceNames];
    if (interfaceNames.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:@"Wi-Fiインターフェースが見つかりません"];
            [self resetScanButton];
        });
        return;
    }
    
    NSString *interfaceName = [interfaceNames anyObject];
    CWInterface *interface = [self.wifiClient interfaceWithName:interfaceName];
    
    if (!interface) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:@"Wi-Fiインターフェースの取得に失敗しました"];
            [self resetScanButton];
        });
        return;
    }
    
    // スキャンを実行
    NSError *error;
    NSSet<CWNetwork *> *networks = [interface scanForNetworksWithName:nil error:&error];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:[NSString stringWithFormat:@"スキャンエラー: %@", error.localizedDescription]];
            [self resetScanButton];
        });
        return;
    }
    
    // 結果を配列に変換してソート
    self.scanResults = [[networks allObjects] sortedArrayUsingComparator:^NSComparisonResult(CWNetwork *network1, CWNetwork *network2) {
        return [@(network2.rssiValue) compare:@(network1.rssiValue)];
    }];
    
    // 表示用データを準備
    [self.displayData removeAllObjects];
    for (CWNetwork *network in self.scanResults) {
        NSDictionary *networkInfo = @{
            @"SSID": network.ssid ?: @"(Hidden)",
            @"BSSID": network.bssid ?: @"N/A",
            @"RSSI": [NSString stringWithFormat:@"%ld dBm", (long)network.rssiValue]
        };
        [self.displayData addObject:networkInfo];
    }
    
    // UIを更新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scanResultsTableView reloadData];
        [self resetScanButton];
        
        // 現在の接続情報も更新
        [self getCurrentWiFiInfo];
    });
}

- (void)resetScanButton {
    self.scanButton.enabled = YES;
    self.scanButton.title = @"Wi-Fiスキャン";
}

- (void)showAlert:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Wi-Fiスキャナー";
    alert.informativeText = message;
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.displayData.count;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= self.displayData.count) {
        return nil;
    }
    
    NSDictionary *networkInfo = self.displayData[row];
    NSString *identifier = tableColumn.identifier;
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    if (!cellView) {
        cellView = [[NSTableCellView alloc] init];
        
        NSTextField *textField = [[NSTextField alloc] init];
        textField.bordered = NO;
        textField.backgroundColor = [NSColor clearColor];
        textField.editable = NO;
        textField.selectable = YES;
        
        [cellView addSubview:textField];
        cellView.textField = textField;
        
        // Auto Layoutの設定
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [textField.leadingAnchor constraintEqualToAnchor:cellView.leadingAnchor constant:5],
            [textField.trailingAnchor constraintEqualToAnchor:cellView.trailingAnchor constant:-5],
            [textField.centerYAnchor constraintEqualToAnchor:cellView.centerYAnchor]
        ]];
    }
    
    cellView.textField.stringValue = networkInfo[identifier] ?: @"";
    
    return cellView;
}

@end

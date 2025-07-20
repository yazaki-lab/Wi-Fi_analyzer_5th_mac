//
//  ViewController.m
//  Wi-Fi_analyzer_5th_mac
//
//  Created by 上川雅弘 on 2025/07/08.
//

//
//  ViewController.m
//

#import "ViewController.h"

//
//  ViewController.m
//

#import "ViewController.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate>

// Wi-Fi関連のプロパティ
@property (strong, nonatomic) CWWiFiClient *wifiClient;
@property (strong, nonatomic) NSArray<CWNetwork *> *scanResults;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *displayData;

// UI要素のプロパティ
@property (strong, nonatomic) NSButton *scanButton;
@property (strong, nonatomic) NSTextField *currentSSIDLabel;
@property (strong, nonatomic) NSTextField *currentBSSIDLabel;
@property (strong, nonatomic) NSTableView *scanResultsTableView;
@property (strong, nonatomic) NSScrollView *tableScrollView;

@end

@implementation ViewController

// loadViewメソッドでプログラムによるUI構築を行う
- (void)loadView {
    // ViewControllerのルートとなるビューを作成
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Wi-Fiクライアントを初期化
    self.wifiClient = [[CWWiFiClient alloc] init];
    self.displayData = [[NSMutableArray alloc] init];
    
    // UIコンポーネントをセットアップ
    [self setupUI];
    
    // 現在の接続情報を取得
    [self getCurrentWiFiInfo];
}

- (void)setupUI {
    // --- ラベルの作成 ---
    self.currentSSIDLabel = [self createLabelWithText:@"現在のSSID:"];
    self.currentBSSIDLabel = [self createLabelWithText:@"現在のBSSID:"];
    
    // --- ボタンの作成 ---
    self.scanButton = [[NSButton alloc] init];
    self.scanButton.title = @"Wi-Fiスキャン";
    self.scanButton.bezelStyle = NSBezelStyleRounded;
    self.scanButton.target = self;
    self.scanButton.action = @selector(scanButtonPressed:);
    
    // --- テーブルビューの作成 ---
    self.scanResultsTableView = [[NSTableView alloc] init];
    [self setupTableView]; // テーブルビューの初期設定

    // テーブルビューをスクロール可能にする
    self.tableScrollView = [[NSScrollView alloc] init];
    self.tableScrollView.documentView = self.scanResultsTableView;
    self.tableScrollView.hasVerticalScroller = YES;

    // --- UI要素をビューに追加 ---
    [self.view addSubview:self.currentSSIDLabel];
    [self.view addSubview:self.currentBSSIDLabel];
    [self.view addSubview:self.scanButton];
    [self.view addSubview:self.tableScrollView];
    
    // --- Auto Layoutで制約を設定 ---
    [self setupConstraints];
}

- (NSTextField *)createLabelWithText:(NSString *)text {
    NSTextField *label = [[NSTextField alloc] init];
    label.stringValue = text;
    label.bezeled = NO;
    label.drawsBackground = NO;
    label.editable = NO;
    label.selectable = NO;
    return label;
}

- (void)setupConstraints {
    // Auto Layoutを有効にする
    self.currentSSIDLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.currentBSSIDLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.scanButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 制約を有効化
    [NSLayoutConstraint activateConstraints:@[
        // 現在のSSIDラベル
        [self.currentSSIDLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20],
        [self.currentSSIDLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // 現在のBSSIDラベル
        [self.currentBSSIDLabel.topAnchor constraintEqualToAnchor:self.currentSSIDLabel.bottomAnchor constant:8],
        [self.currentBSSIDLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // スキャンボタン
        [self.scanButton.topAnchor constraintEqualToAnchor:self.currentBSSIDLabel.bottomAnchor constant:20],
        [self.scanButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // テーブルビュー（スクロールビュー）
        [self.tableScrollView.topAnchor constraintEqualToAnchor:self.scanButton.bottomAnchor constant:20],
        [self.tableScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.tableScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.tableScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20]
    ]];
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
    rssiColumn.width = 100;
    [self.scanResultsTableView addTableColumn:rssiColumn];
    
    self.scanResultsTableView.dataSource = self;
    self.scanResultsTableView.delegate = self;
}

- (void)getCurrentWiFiInfo {
    // 現在の接続情報を取得
    CWInterface *interface = [CWWiFiClient sharedWiFiClient].interface;
    
    if (interface) {
        NSString *currentSSID = interface.ssid ?: @"未接続";
        NSString *currentBSSID = interface.bssid ?: @"未接続";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentSSIDLabel.stringValue = [NSString stringWithFormat:@"現在のSSID: %@", currentSSID];
            self.currentBSSIDLabel.stringValue = [NSString stringWithFormat:@"現在のBSSID: %@", currentBSSID];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentSSIDLabel.stringValue = @"現在のSSID: Wi-Fiインターフェースが見つかりません";
            self.currentBSSIDLabel.stringValue = @"現在のBSSID: Wi-Fiインターフェースが見つかりません";
        });
    }
}

// scanButtonPressedのIBActionをvoidに変更
- (void)scanButtonPressed:(id)sender {
    self.scanButton.enabled = NO;
    self.scanButton.title = @"スキャン中...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performWiFiScan];
    });
}

- (void)performWiFiScan {
    CWInterface *interface = [CWWiFiClient sharedWiFiClient].interface;
    if (!interface) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:@"Wi-Fiインターフェースが見つかりません"];
            [self resetScanButton];
        });
        return;
    }
    
    NSError *error;
    NSSet<CWNetwork *> *networks = [interface scanForNetworksWithName:nil error:&error];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:[NSString stringWithFormat:@"スキャンエラー: %@", error.localizedDescription]];
            [self resetScanButton];
        });
        return;
    }
    
    self.scanResults = [[networks allObjects] sortedArrayUsingComparator:^NSComparisonResult(CWNetwork *network1, CWNetwork *network2) {
        return [@(network2.rssiValue) compare:@(network1.rssiValue)];
    }];
    
    [self.displayData removeAllObjects];
    for (CWNetwork *network in self.scanResults) {
        NSDictionary *networkInfo = @{
            @"SSID": network.ssid ?: @"(Hidden)",
            @"BSSID": network.bssid ?: @"N/A",
            @"RSSI": [NSString stringWithFormat:@"%ld dBm", (long)network.rssiValue]
        };
        [self.displayData addObject:networkInfo];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scanResultsTableView reloadData];
        [self resetScanButton];
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
    
    // セルビューを再利用または新規作成
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    if (!cellView) {
        cellView = [[NSTableCellView alloc] init];
        cellView.identifier = identifier;
        
        NSTextField *textField = [[NSTextField alloc] init];
        textField.bordered = NO;
        textField.backgroundColor = [NSColor clearColor];
        textField.editable = NO;
        textField.selectable = YES;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        [cellView addSubview:textField];
        cellView.textField = textField;
        
        // Auto Layoutの設定
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
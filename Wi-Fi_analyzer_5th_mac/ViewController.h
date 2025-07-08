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

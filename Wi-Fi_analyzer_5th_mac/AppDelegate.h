//
//  AppDelegate.h
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end


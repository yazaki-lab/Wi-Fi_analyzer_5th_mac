//
//  Wi_Fi_analyzer_5th_macUITestsLaunchTests.m
//  Wi-Fi_analyzer_5th_macUITests
//
//  Created by 上川雅弘 on 2025/07/08.
//

#import <XCTest/XCTest.h>

@interface Wi_Fi_analyzer_5th_macUITestsLaunchTests : XCTestCase

@end

@implementation Wi_Fi_analyzer_5th_macUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end

#import "SimulateData.h"

@interface SimulateData ()
@property (nonatomic, strong) NSTimer *dataTimer;
@property (nonatomic, weak) FlutterViewController *controller;
@end

@implementation SimulateData

- (void)startReceivingDataWithController:(FlutterViewController *)controller {
    NSLog(@"startReceivingData method called");
    self.controller = controller;
    self.dataTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(sendDataToFlutter)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)sendDataToFlutter {
    // Simulate data update
    NSDictionary *data = @{@"symbol": @"AAPL", @"price": @(arc4random_uniform(1000) / 10.0 + 100)};
    FlutterMethodChannel *realTimeChannel = [FlutterMethodChannel
                                             methodChannelWithName:@"com.example.trading_app/realtime"
                                             binaryMessenger:self.controller.binaryMessenger];
    [realTimeChannel invokeMethod:@"onDataReceived" arguments:data];
}

@end

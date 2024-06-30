#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface SimulateData : NSObject

- (void)startReceivingDataWithController:(FlutterViewController *)controller;
- (void)sendDataToFlutter;

@end

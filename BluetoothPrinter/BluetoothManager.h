//
//  BluetoothManager.h
//  BluetoothPrinter
//
//  Created by aleksey kosylo on 07/10/16.
//  Copyright © 2016 Cube Innovations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@protocol BluetoothManagerDelegate <NSObject>

- (void)bluetoothCenterOff;
- (void)bluetoothCenterOn;
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)didConnectPeripheral:(CBPeripheral *)peripherial;
- (void)readyToPrint:(CBPeripheral *)peripherial;
- (void)didFailToConnectPeripheral:(CBPeripheral *)peripherial error:(NSError *)error;
- (void)didDiscoverPeripheral:(NSArray *)peripherails;
- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characterisitc error:(NSError *)error;

@end

@interface BluetoothManager : NSObject

@property (nonatomic, weak) id<BluetoothManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary<CBPeripheral *, CBCharacteristic *> *peripheral;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripheralArray;
@property (nonatomic, strong) CBCentralManager *centralManager;

- (void)startScan;
- (void)stopScan;
- (void)connectPeripheral:(CBPeripheral *)peripheral;

- (void)writeValue:(CBPeripheral *)peripheral data:(NSData *)data;
@end

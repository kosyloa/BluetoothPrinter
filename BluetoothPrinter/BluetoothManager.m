//
//  BluetoothManager.m
//  BluetoothPrinter
//
//  Created by aleksey kosylo on 07/10/16.
//  Copyright © 2016 Cube Innovations Inc. All rights reserved.
//

#import "BluetoothManager.h"

@interface BluetoothManager()<CBCentralManagerDelegate, CBPeripheralDelegate>

@end

@implementation BluetoothManager

- (NSMutableDictionary<CBPeripheral *,CBCharacteristic *> *)peripheral {
  if(!_peripheral) {
    _peripheral = @{}.mutableCopy;
  }
  return _peripheral;
}

- (NSMutableArray<CBPeripheral *> *)peripheralArray {
  if(!_peripheralArray) {
    _peripheralArray = [NSMutableArray new];
  }
  return _peripheralArray;
}

- (CBCentralManager *)centralManager {
  if(!_centralManager) {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  }
  return _centralManager;
}

- (void)startScan {
  [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@(YES)}];
}

- (void)stopScan {
  [self.peripheralArray removeAllObjects];
  [self.centralManager stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {
  [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
  [self.centralManager cancelPeripheralConnection:peripheral];
}

- (void)writeValue:(CBPeripheral *)peripheral data:(NSData *)data {
  CBCharacteristic *characteristic = self.peripheral[peripheral];
  [peripheral setNotifyValue:YES forCharacteristic:characteristic];
  [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)addPeripheral:(CBPeripheral *)peripheral {
  if(![self.peripheralArray containsObject:peripheral]) {
    [self.peripheralArray addObject:peripheral];
  }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  switch (central.state) {
    case CBCentralManagerStateUnknown:
      NSLog(@"unknown state");
      break;
    case CBCentralManagerStateResetting:
      NSLog(@"Resetting");
      break;
    case CBCentralManagerStateUnsupported:
      NSLog(@"Unsupported");
      break;
    case CBCentralManagerStateUnauthorized:
      NSLog(@"Unath");
      break;
    case CBCentralManagerStatePoweredOff: {
      if([self.delegate respondsToSelector:@selector(bluetoothCenterOff)]) {
        [self.delegate bluetoothCenterOff];
      }
      break;
    }
    case CBCentralManagerStatePoweredOn: {
      if([self.delegate respondsToSelector:@selector(bluetoothCenterOn)]) {
        [self.delegate bluetoothCenterOn];
      }
      [self.centralManager scanForPeripheralsWithServices:nil options:nil];
      break;
    }
    default:
      break;
  }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  [self.peripheral removeObjectForKey:peripheral];
  if([self.delegate respondsToSelector:@selector(didDisconnectPeripheral:error:)]) {
    [self.delegate didDisconnectPeripheral:peripheral error:error];
  }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  self.peripheral[peripheral] = nil;
  peripheral.delegate = self;
  [peripheral discoverServices:nil];
  if([self.delegate respondsToSelector:@selector(didConnectPeripheral:)]) {
    [self.delegate didConnectPeripheral:peripheral];
  }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  if ([self.delegate respondsToSelector:@selector(didFailToConnectPeripheral:error:)]) {    
    [self.delegate didFailToConnectPeripheral:peripheral error:error];
  }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
  [self addPeripheral:peripheral];
  if([self.delegate respondsToSelector:@selector(didDiscoverPeripheral:)]) {
    [self.delegate didDiscoverPeripheral:self.peripheralArray];
  }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  if(error) {
    NSLog(@"error : %@",error);
    return;
  }
  [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [peripheral discoverCharacteristics:nil forService:obj];
  }];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
  if(error) {
    NSLog(@"error : %@",error);
    return;
  }
  [service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [peripheral readValueForCharacteristic:obj];
  }];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  if ((characteristic.properties & CBCharacteristicPropertyWrite) > 0) {
    self.peripheral[peripheral] = characteristic;
    if ([self.delegate respondsToSelector:@selector(readyToPrint:)]) {
      [self.delegate readyToPrint:peripheral];
    }
  }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  if([self.delegate respondsToSelector:@selector(didWriteValueForCharacteristic:error:)]) {
    [self.delegate didWriteValueForCharacteristic:characteristic error:error];
  }
}

@end

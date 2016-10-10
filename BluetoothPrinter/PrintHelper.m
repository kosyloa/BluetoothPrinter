//
//  PrintHelper.m
//  BluetoothPrinter
//
//  Created by aleksey kosylo on 09/10/16.
//  Copyright © 2016 Cube Innovations Inc. All rights reserved.
//

#import "PrintHelper.h"

@interface NSMutableData (AppendDataPrintHelper)

- (void)appendByte:(UInt8)byte;

@end

@implementation NSMutableData (AppendDataPrintHelper)

- (void)appendByte:(UInt8)byte {
  UInt8 a = byte;
  [self appendBytes:&a length:1];
}

@end

@implementation PrintHelper


+ (NSData *)printerInitialize {
  return [self dataWithByteArray:@[@27, @64]];
}

+ (NSData *)printerHorizontalPositioning {
  return [self dataWithByteArray:@[@9]];
}

+ (NSData *)println {
  return [self dataWithByteArray:@[@10]];
}

+ (NSData *)printerLeftSpacing:(UInt8)nL nH:(UInt8)nH {
  return [self dataWithByteArray:@[@29, @76, @(nL), @(nH)]];
}

+ (NSData *)printerRightSpacing:(UInt8)n {
  return [self dataWithByteArray:@[@27, @32, @(n)]];
}

+ (NSData *)printerModel:(UInt8)n {
  return [self dataWithByteArray:@[@27, @33, @(n)]];
}

+ (NSData *)printerCharacterSize:(UInt8)n {
  return [self dataWithByteArray:@[@29, @33, @(n)]];
}

+ (NSData *)printerAbsolutePosition:(UInt8)nL nH:(UInt8)nH {
  return [self dataWithByteArray:@[@27, @33, @(nL), @(nH)]];
}

+ (NSData *)printerCustomCharacter:(BOOL)isCustom {
  return [self dataWithByteArray:@[@27, @37, @(isCustom)]];
}

+ (NSData *)printerUnderlineMode:(UInt8)n {
  return [self dataWithByteArray:@[@27, @45, @(n)]];
}

+ (NSData *)printerDefaultLineSpacing {
  return [self dataWithByteArray:@[@27, @50]];
}

+ (NSData *)printerSetTheLineSpacing:(UInt8)n {
  return [self dataWithByteArray:@[@27, @51, @(n)]];
}

+ (NSData *)printerBoldPatterns:(BOOL)isBold {
  return [self dataWithByteArray:@[@27, @29, @(isBold)]];
}

+ (NSData *)printerDoublePrintMode:(BOOL)isDoublePrintMode {
  return [self dataWithByteArray:@[@27, @71, @(isDoublePrintMode)]];
}

+ (NSData *)printerFont:(UInt8)n {
  return [self dataWithByteArray:@[@27, @77, @(n)]];
}

+ (NSData *)printerCharacter:(UInt8)n {
  return [self dataWithByteArray:@[@27, @82, @(n)]];
}

+ (NSData *)printerAlignment:(UInt8)n {
  return [self dataWithByteArray:@[@27, @97, @(n)]];
}

+ (NSData *)printerPaperFeed:(UInt8)n {
  return [self dataWithByteArray:@[@27, @100, @(n)]];
}

+ (NSData *)printerQRCodeSize:(UInt8)n {
  return [self dataWithByteArray:@[@29, @40, @107, @3, @0, @49, @67, @(n)]];
}

+ (NSData *)printerQRCodeECC:(UInt8)n {
  return [self dataWithByteArray:@[@29, @40, @107, @3, @0, @49, @69, @(n)]];
}

+ (NSData *)printerStoringData:(NSString *)qrCode {
  NSInteger nLength = qrCode.length + 3;
  NSMutableData *tempData = [self dataWithByteArray:@[@29, @40, @107, @(nLength % 256), @(nLength % 256), @49, @80, @48]].mutableCopy;
  [tempData appendData:[qrCode dataUsingEncoding:NSUTF8StringEncoding]];
  return tempData;
}

+ (NSData *)printerQRCodeStorageData {
  return [self dataWithByteArray:@[@29, @40, @107, @3, @0, @49, @81, @48]];
}

+ (NSData *)printerQRCode:(UInt8)size ecc:(UInt8)ecc qrCode:(NSString *)qrCode {
  NSMutableData *cmmData = [NSMutableData new];
  [cmmData appendData:[self printerQRCodeSize:size]];
  [cmmData appendData:[self printerQRCodeECC:ecc]];
  [cmmData appendData:[self printerStoringData:qrCode]];
  [cmmData appendData:[self printerQRCodeStorageData]];
  return cmmData;
}

+ (NSData *)printerState {
  return [self dataWithByteArray:@[@27, @118]];
}

+ (NSData *)printerQRCode:(NSString *)qrCode {
  NSMutableData *cmmData = [NSMutableData new];
  NSInteger len = qrCode.length;
  NSData *tempData = [self dataWithByteArray:@[@29, @119, @11, @29, @107, @97, @0, @1]];
  [cmmData appendData:tempData];
  [cmmData appendByte:(UInt8) len];
  [cmmData appendData:[qrCode dataUsingEncoding:NSUTF8StringEncoding]];
  return cmmData;
}


+ (NSData *)dataWithByteArray:(NSArray<NSNumber *> *)byteArray {
  __block NSMutableData *cmmData = [NSMutableData new];
  [byteArray enumerateObjectsUsingBlock:^(NSNumber *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
    [cmmData appendByte:(UInt8) obj.intValue];
  }];
  return cmmData;
}


@end

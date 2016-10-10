//
//  PrintHelper.h
//  BluetoothPrinter
//
//  Created by aleksey kosylo on 09/10/16.
//  Copyright © 2016 Cube Innovations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrintHelper : NSObject

+ (NSData *)printerInitialize;

+ (NSData *)printerHorizontalPositioning;

+ (NSData *)println;

+ (NSData *)printerLeftSpacing:(UInt8)nL nH:(UInt8)nH;

+ (NSData *)printerRightSpacing:(UInt8)n;

+ (NSData *)printerModel:(UInt8)n;

+ (NSData *)printerCharacterSize:(UInt8)n;

+ (NSData *)printerAbsolutePosition:(UInt8)nL nH:(UInt8)nH;

+ (NSData *)printerCustomCharacter:(BOOL)isCustom;

+ (NSData *)printerUnderlineMode:(UInt8)n;

+ (NSData *)printerDefaultLineSpacing;

+ (NSData *)printerSetTheLineSpacing:(UInt8)n;

+ (NSData *)printerBoldPatterns:(BOOL)isBold;

+ (NSData *)printerDoublePrintMode:(BOOL)isDoublePrintMode;

+ (NSData *)printerFont:(UInt8)n;

+ (NSData *)printerCharacter:(UInt8)n;

+ (NSData *)printerAlignment:(UInt8)n;

+ (NSData *)printerPaperFeed:(UInt8)n;

+ (NSData *)printerQRCodeSize:(UInt8)n;

+ (NSData *)printerQRCodeECC:(UInt8)n;

+ (NSData *)printerStoringData:(NSString *)qrCode;

+ (NSData *)printerQRCodeStorageData;

+ (NSData *)printerQRCode:(UInt8)size ecc:(UInt8)ecc qrCode:(NSString *)qrCode;

+ (NSData *)printerState;

+ (NSData *)printerQRCode:(NSString *)qrCode;
@end

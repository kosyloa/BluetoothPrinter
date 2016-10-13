//
//  ViewController.m
//  BluetoothPrinter
//
//  Created by aleksey kosylo on 07/10/16.
//  Copyright © 2016 Cube Innovations Inc. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothManager.h"
#import "PrintHelper.h"

@import CoreBluetooth;

static NSString *const kCellIdentifier = @"CellIdentifier";
static NSInteger const kMaxCount = 32;

@interface DeviceTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *stateLabel;

@end

@implementation DeviceTableViewCell


@end

@interface ViewController ()<BluetoothManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) BluetoothManager *bluetoothManager;
@property (nonatomic, strong) NSArray<CBPeripheral *> *printerArrary;
@property (nonatomic, weak) IBOutlet UITableView *devicesTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.bluetoothManager.delegate = self;
  [self.bluetoothManager startScan];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)searchTap:(UIButton *)sender {
  if (sender.selected) {
    sender.selected = NO;
    [self.bluetoothManager startScan];
    
  } else {
    sender.selected = YES;
    [self.bluetoothManager stopScan];
  }
}

#pragma mark - Print

- (void)printToPeripherial:(CBPeripheral *)peripherial {
  CFStringEncodings cfEnc = kCFStringEncodingGB_18030_2000;
  unsigned long enc = CFStringConvertEncodingToNSStringEncoding(cfEnc);

  {
  NSMutableData *cmmData = [NSMutableData new];
  [cmmData appendData:[PrintHelper printerInitialize]];
  [cmmData appendData:[PrintHelper printerModel:0]];
  [cmmData appendData:[PrintHelper printerCharacterSize:1]];
  [cmmData appendData:[PrintHelper printerAlignment:1]];


  NSData *nameData = [@"Order #15 21.07.16 16:54"  dataUsingEncoding:enc];
  [cmmData appendData:nameData];
  [cmmData appendData:[PrintHelper printerPaperFeed:2]];
  [self.bluetoothManager writeValue:peripherial data:cmmData];
  }
  NSInteger itemsCount = 10;
  for (int i = 0; i < itemsCount; i++) {
    NSString *name = [NSString stringWithFormat:@"%@Burger%d",i%3 == 0 ? @"" : @"   ", i];
    NSMutableData *itemData = [NSMutableData new];
    NSMutableString *resultString = @"".mutableCopy;

    NSString *priceString = [NSString stringWithFormat:@"__$ %.2f",i * 3.4f];
    NSString *countString = [NSString stringWithFormat:@"__x%d",i * 12];

    NSInteger availableCount = kMaxCount - (priceString.length + countString.length);
    if(availableCount > 0) {
      NSString *nameSubstring = @"";
      if(name.length <= availableCount) {
        nameSubstring = name;
      }
      else {
        nameSubstring = [name substringWithRange:NSMakeRange(0, availableCount)];
      }
      for (NSUInteger i = nameSubstring.length; i < availableCount; ++i) {
        nameSubstring = [nameSubstring stringByAppendingString:@"_"];
      }
      [resultString appendString:nameSubstring];
    }
    [resultString appendString:countString];
    [resultString appendString:priceString];

    [itemData appendData:[PrintHelper printerInitialize]];
    [itemData appendData:[PrintHelper printerModel:0]];
    [itemData appendData:[PrintHelper printerCharacterSize:0]];
    [itemData appendData:[PrintHelper printerAlignment:0]];
    NSData *goodsData = [resultString  dataUsingEncoding:enc];
    [itemData appendData:goodsData];
    [itemData appendData:[PrintHelper printerPaperFeed:i == (itemsCount - 1) ? 2 : 1]];
    [self.bluetoothManager writeValue:peripherial data:itemData];
  }

  {
  NSMutableData *cmmData = [NSMutableData new];
  [cmmData appendData:[PrintHelper printerInitialize]];
  [cmmData appendData:[PrintHelper printerModel:0]];
  [cmmData appendData:[PrintHelper printerCharacterSize:17]];
  [cmmData appendData:[PrintHelper printerAlignment:2]];


  NSData *nameData = [@"TOTAL $ 10.5"  dataUsingEncoding:enc];
  [cmmData appendData:nameData];
  [cmmData appendData:[PrintHelper printerPaperFeed:1]];
  [self.bluetoothManager writeValue:peripherial data:cmmData];
  }
  
}

#pragma mark - Getters

- (BluetoothManager *)bluetoothManager {
  if(!_bluetoothManager) {
    _bluetoothManager = [BluetoothManager new];
  }
  return _bluetoothManager;
}

- (NSArray<CBPeripheral *> *)printerArrary {
  if(!_printerArrary) {
    _printerArrary = [NSArray new];
  }
  return _printerArrary;
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.printerArrary.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceTableViewCell class])];
  CBPeripheral *peripherial = self.printerArrary[indexPath.row];
  cell.nameLabel.text = peripherial.name;
  NSLog(@"%@ %@",self.printerArrary, peripherial.name);
  switch (peripherial.state) {
    case CBPeripheralStateConnected:
      cell.stateLabel.text = @"Connected";
      break;
    case CBPeripheralStateConnecting:
      cell.stateLabel.text = @"Connecting";
      break;
    default:
      cell.stateLabel.text = @"Disconnected";
      break;
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  CBPeripheral *peripherial = self.printerArrary[indexPath.row];
  [self.bluetoothManager connectPeripheral:peripherial];
  [self.devicesTableView reloadData];
}

#pragma mark - BluetoothManagerDelegate

- (void)bluetoothCenterOn {
  
}

- (void)bluetoothCenterOff {
  
}

- (void)didDiscoverPeripheral:(NSArray *)peripherails {
  self.printerArrary = peripherails;
  [self.devicesTableView reloadData];
}

- (void)didConnectPeripheral:(CBPeripheral *)peripherial {
  [self.devicesTableView reloadData];
}

- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  [self.devicesTableView reloadData];
}

- (void)didFailToConnectPeripheral:(CBPeripheral *)peripherial error:(NSError *)error {
  
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characterisitc error:(NSError *)error {
  
}

- (void)readyToPrint:(CBPeripheral *)peripherial {
  [self printToPeripherial:peripherial];
}

@end

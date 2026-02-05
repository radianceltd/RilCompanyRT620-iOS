//
//  CommonUtilOC.h
//  TMW041RT
//
//  Created by RND on 2023/3/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
//#import <Charts/Charts-Swift.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonUtilOC : NSObject

@property (strong,nonatomic) NSUserDefaults *userDefaults;

- (NSString *)convertDataToHexStr:(NSData *)data;

//得到温度单位
-(NSString *)getDeviceUnit:(NSString *)mac;

-(id)initWithDateArr:(NSMutableArray *)arr;

- (UIColor *) stringToColor:(NSString *)str;

-(NSString *)getTmpData:(CBCharacteristic *)characteristic;

-(NSString *)getTempTMWData:(CBCharacteristic *)characteristic;

-(NSString *)getPOPData:(CBCharacteristic *)characteristic;

-(NSDate*)dateFromLongLong:(long)msSince1970;

-(NSString*)stringFromDate:(NSDate*)date;

-(float)convertCelciusToFahren:(float)celcius;

-(float)convertFahrenheitToCelcius:(float)fahrenheit;

-(NSData *)writeFourData:(NSString *)data;

///OTA
-(unsigned int) getIntegerFromHexString:(NSString *)hexString;

-(NSMutableData *)dataFromHexString:(NSString *)string;

-(void)tenNotification:(NSString*)ntitle title:(NSString*)nsubtitle content:(NSString *)ncontent;

//转为OC的代码
-(NSDictionary *)changerDictionary:(NSArray *)array;

-(NSArray *)removeData:(NSArray *) array;

-(NSDictionary *)changeLastPacketDict:(NSArray *) array row:(NSInteger) number dict:(NSDictionary*) dict;

-(NSMutableArray* )changes:(NSDictionary *) dict;

-(NSDictionary *)changeVerifyRow:(NSArray*) array currentIndex:(NSInteger) index currentRow:(NSInteger) row;

-(uint8_t) rowCheckSumUint8:(NSArray *)array currentIndex:(NSInteger) index;

-(uint8_t *)getPointer:(CBCharacteristic *)characteristic;

-(NSString *)getErrorCode:(uint8_t *) dataPointer;

-(NSDictionary*)changerFirstData:(NSArray *)array currentIndex:(NSInteger) index;

-(NSString *) currentArrayId:(NSArray *)array currentIndex:(NSInteger) index;

//存储开始时间
-(void)saveBgTime:(long)bgTime macAddre:(NSString*) mac;

//获取开始的时间
-(long)getBgTime:(NSString *)mac;

//存储结束时间
-(void)saveEdTime:(long)edTime macAddre:(NSString*) mac;

//获取结束的时间
-(long)getEdTime:(NSString *)mac;


// 新增解析文件名数据代码

- (NSArray *)parseFileNamesFromData:(NSArray *)data;


@end

NS_ASSUME_NONNULL_END

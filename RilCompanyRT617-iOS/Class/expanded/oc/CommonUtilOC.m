//
//  CommonUtilOC.m
//  TMW041RT
//
//  Created by RND on 2023/3/24.
//

#import "CommonUtilOC.h"

#define MAX_DATA_SIZE   133

#define CHECK_SUM   @"checkSum"
#define CRC_16      @"crc_16"
#define ROW_DATA    @"rowData"

#define SILICON_ID          @"SiliconID"
#define SILICON_REV         @"SiliconRev"
#define CHECKSUM_TYPE       @"CheckSumType"
#define ROW_ID              @"RowID"
#define ROW_COUNT           @"RowCount"
#define ARRAY_ID            @"ArrayID"
#define ROW_NUMBER          @"RowNumber"
#define DATA_LENGTH         @"DataLength"
#define DATA_ARRAY          @"DataArray"
#define CHECKSUM_OTA        @"CheckSum"


#define FLASH_ARRAY_ID   @"flashArrayID"
#define FLASH_ROW_NUMBER  @"flashRowNumber"

@interface CommonUtilOC(){
    NSMutableArray *_dateArr;
}

@end

@implementation CommonUtilOC
/*
    转进制
 */
- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}


/*
    字符串转为颜色值
 */
- (UIColor *) stringToColor:(NSString *)str
{
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }
    unsigned red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color= [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
    return color;
}

-(uint8_t *)getPointer:(CBCharacteristic *)characteristic{
    uint8_t *dataPointer = (uint8_t *) [characteristic.value bytes];
    return dataPointer;
}

-(NSString *)getErrorCode:(uint8_t *) dataPointer{
    if (dataPointer != NULL) {
        NSString *errorCode = [NSString stringWithFormat:@"0x%2x",dataPointer[1]];
        errorCode = [errorCode stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        return errorCode;
    }
    return NULL;
}

//对外发布chart x轴的数据
- (id)initWithDateArr:(NSMutableArray *)arr{
    if (self = [super init]) {
        if(arr!=nil){
            _dateArr = [NSMutableArray arrayWithArray:arr];
        }
    }
    return self;
}

//转换数据

-(NSDictionary*)changerFirstData:(NSArray *)array currentIndex:(NSInteger) index{
    /* Write the GET_FLASH_SIZE command */
    NSDictionary *rowDataDict = [array objectAtIndex:index];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[rowDataDict objectForKey:ARRAY_ID] forKey:FLASH_ARRAY_ID];
    return dataDict;
}

-(NSString *) currentArrayId:(NSArray *)array currentIndex:(NSInteger) index{
    NSDictionary *rowDataDict = [array objectAtIndex:index];
    return [rowDataDict objectForKey:ARRAY_ID];
}


/*
    解析温度数据
 */
-(NSString *)getTmpData:(CBCharacteristic *)characteristic{
    NSData *data = characteristic.value;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


//解析温度数据
-(NSString *)getTempTMWData:(CBCharacteristic *)characteristic{
    NSData *data = characteristic.value;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

//解析开关数据
-(NSString *)getPOPData:(CBCharacteristic *)characteristic{
    NSData *data = characteristic.value;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/*
    先替用一下
 */
-(NSString *)getTempTMWDataOld:(CBCharacteristic *)characteristic{
    NSString *tempUnit;
    int temps = 0;
    int alarm = 0;
    //报警开关默认为开
    int alarmswitch=1;
    int muteswitch;
    int normal = 0;
    NSString *macAddre;
    NSData *data = characteristic.value;
    //默认电压正常
    int tension=0;
    //静音
    int mute = 0;
    if(data!=nil){
        const uint8_t *bytes = [data bytes];
        int b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b12,b13,b14,b15,b16,b17,b18,b19;
        //b0是 是否显示温度数据正常
        b0 = bytes[0]&0xff;
        normal = b0;
        //b1-b4是显示温度值
        b1 = bytes[1]&0xff;
        b2 = bytes[2]&0xff;
        b3 = bytes[3]&0xff;
        b4 = bytes[4]&0xff;
        
        //解析温度数据
        temps = (b4<<24)|(b3<<16)|(b2<<8)|b1;
        
        //b5-b8是显示高温报警临界值
        b5 = bytes[5]&0xff;
        b6 = bytes[6]&0xff;
        b7 = bytes[7]&0xff;
        b8 = bytes[8]&0xff;
        
        alarm = (b8<<24)|(b7<<16)|(b6<<8)|b5;
        
        //静音开关 声音关掉
        b9 = bytes[9]&0xff;
        mute = b9;
        
        //接受高低温报警开关
        b10 = bytes[10]&0xff;
        alarmswitch = b10;
        
        //温度单位
        const uint8_t flagByte = bytes[11];
        if ((flagByte & 0x01) != 0) {
            tempUnit = @"°F";
            //[_userDefaults setObject:tempUnit forKey:@"tempUnit"]; //存储温度数据
        } else {
            tempUnit = @"°C";
            //[_userDefaults setObject:tempUnit forKey:@"tempUnit"];
        }
        
        //电压数据
        b12 = bytes[12]&0xff;
        tension = b12;
        
        //地址处理
        b13 = bytes[13]&0xff;
        b14 = bytes[14]&0xff;
        b15 = bytes[15]&0xff;
        b16 = bytes[16]&0xff;
        b17 = bytes[17]&0xff;
        b18 = bytes[18]&0xff;
        
        //静音开关
        b19 = bytes[19]&0xff;
        muteswitch = b19;
        
        macAddre = [self setone:b13 settwo:b14 setthree:b15 setfour:b16 setfive:b17 setsix:b18];
        NSString *macAddres = [NSString stringWithFormat:@"S/N:%@",macAddre];
        
        //顺序依次为 温度是否正常->温度值->温度符号->温度地址->温度报警值->温度报警静音->温度报警开关->电压提示
        NSString *sendData = [NSString stringWithFormat:@"%d,%d,%@,%@,%d,%d,%d,%d,%d",normal,temps,tempUnit
                              ,macAddres,alarm,mute,alarmswitch,tension,muteswitch];
        return sendData;
    }
    return @"";
}

/*
 * 十进制转为十六进制
 */
-(NSString *)setone:(int) one settwo:(int) two setthree:(int)three setfour:(int)four setfive:(int)five
             setsix:(int)six{
    NSString *all=@"";
    NSString *ones = [self addZero:[self ToHex:one]];
    NSString *twos = [self addZero:[self ToHex:two]];
    NSString *threes = [self addZero:[self ToHex:three]];
    NSString *fours = [self addZero:[self ToHex:four]];
    NSString *fives = [self addZero:[self ToHex:five]];
    NSString *sixs = [self addZero:[self ToHex:six]];
    
    //增加1个0
    all = [NSString stringWithFormat:@"%@%@%@%@%@%@",ones,twos,threes,fours,fives,sixs];
    return all;
}

/*
 * 十进制转为16进制
 */
- (NSString *)ToHex:(uint16_t)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

//字符串补零操作
-(NSString *)addZero:(NSString *)str{
    NSString *string = nil;
    if (str.length>=2) {
        return str;
    }else{
        string = [NSString stringWithFormat:@"0%@",str];
    }
    
    return string;
}

//时间的转换
-(NSDate*)dateFromLongLong:(long)msSince1970{
    return [NSDate dateWithTimeIntervalSince1970:msSince1970];
}

//时间的转换
-(NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

// 摄氏度转为华氏度
-(float)convertCelciusToFahren:(float)celcius{
    return  celcius*1.8+32;
}

// 华氏度转换为摄氏度
-(float)convertFahrenheitToCelcius:(float)fahrenheit{
    return (fahrenheit - 32)/1.8;
}

//- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
//    //必须要有2个数才能组成一个曲线表
//    //数组越界的处理方法 下标要小于他的总和
//    if (_dateArr.count > 1&&(int)value<_dateArr.count) {
//        NSString *dateStr = _dateArr[(int)value];
//        return dateStr;
//    }
//    return @"";
//}

/*
    获取设备的单位
 */
-(NSString *)getDeviceUnit:(NSString *)mac{
    if(mac!=nil){
        NSString *deviceunit = [mac stringByAppendingString:@"deviceUnit"];
        NSString *unit = [_userDefaults stringForKey:deviceunit];
        if(unit!=nil){
            return unit;
        }
        return @"°F";
    }
    return @"°F";
}

-(void)saveBgTime:(long)bgTime macAddre:(NSString*) mac{
    if(bgTime>0&&mac!=nil){
        NSString *devicetime = [mac stringByAppendingString:@"beginTime"];
        [_userDefaults setDouble:bgTime forKey:devicetime];
    }
}

-(long)getBgTime:(NSString *)mac{
    if(mac!=nil){
        NSString *begin = [mac stringByAppendingString:@"beginTime"];
        long begintime = [_userDefaults doubleForKey:begin];
        if(begintime!=0){
            return begintime;
        }
    }
    return 0;
}

//存储结束时间
-(void)saveEdTime:(long)edTime macAddre:(NSString*) mac{
    if(edTime>0&&mac!=nil){
        NSString *devicetime = [mac stringByAppendingString:@"endTime"];
        [_userDefaults setDouble:edTime forKey:devicetime];
    }
}

//获取结束的时间
-(long)getEdTime:(NSString *)mac{
    if(mac!=nil){
        NSString *end = [mac stringByAppendingString:@"endTime"];
        long endtime = [_userDefaults doubleForKey:end];
        if(endtime!=0){
            return endtime;
        }
    }
    return 0;
}


////<<========OTA=========>>
/*
 设置iOS的通知
 */
-(void)tenNotification:(NSString*)ntitle title:(NSString*)nsubtitle content:(NSString *)ncontent{
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = ntitle;
        content.subtitle = nsubtitle;
        content.body = ncontent;
        //content.badge = @1;
        //使用通知的声音
        UNNotificationSound *sound = [UNNotificationSound soundNamed:@"/System/Library/Audio/UISounds/sms-received1.caf"];
        content.sound = sound;
        
        //第三步：通知触发机制。（重复提醒，时间间隔要大于60s） 1秒钟执行一次 马上执行通知
        UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        //第四步：创建UNNotificationRequest通知请求对象
        NSString *requertIdentifier = @"RequestIdentifier";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requertIdentifier content:content trigger:trigger1];
        
        //第五步：将通知加到通知中心
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"Error:%@",error);
        }];
    } else {
        // Fallback on earlier versions
    }
    
}


-(NSData *)writeFourData:(NSString *)data{
    int a = [data intValue];
    NSData *aData = [data dataUsingEncoding: NSUTF8StringEncoding];
    Byte *testByte = (Byte *)[aData bytes];
    testByte[0] = (Byte)(a&0xff);
    testByte[1] = (Byte)(a>>8&0xff);
    testByte[2] = (Byte) (a>>16&0xff);
    testByte[3] = (Byte)(a>>24&0xff);
    
    NSData *adata = [[NSData alloc] initWithBytes:testByte length:4];
    return adata;
}

///=======================OTA==============================
/*!
 *  @method getIntegerFromHexString:
 *
 *  @discussion Method that returns the integer from hex string
 *
 */
-(unsigned int) getIntegerFromHexString:(NSString *)hexString
{
    unsigned int integerValue;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&integerValue];
    
    return integerValue;
}

/**
 * Method to convert hex to byteArray
 */

-(NSMutableData *)dataFromHexString:(NSString *)string
{
    NSMutableData *data = [NSMutableData new];
    NSCharacterSet *hexSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF "] invertedSet];
    
    // Check whether the string is a valid hex string. Otherwise return empty data
    if ([string rangeOfCharacterFromSet:hexSet].location == NSNotFound) {
        
        string = [string lowercaseString];
        unsigned char whole_byte;
        char byte_chars[3] = {'\0','\0','\0'};
        int i = 0;
        int length = (int)string.length;
        
        while (i < length-1)
        {
            char c = [string characterAtIndex:i++];
            
            if (c < '0' || (c > '9' && c < 'a') || c > 'f')
                continue;
            byte_chars[0] = c;
            byte_chars[1] = [string characterAtIndex:i++];
            whole_byte = strtol(byte_chars, NULL, 16);
            [data appendBytes:&whole_byte length:1];
        }
    }
    return data;
}


-(NSDictionary *)changerDictionary:(NSArray *)array{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[array subarrayWithRange:NSMakeRange(0, MAX_DATA_SIZE)],ROW_DATA, nil];
    return dataDict;
}


-(NSArray *)removeData:(NSArray *) array{
    NSMutableArray *arrays = [array mutableCopy];
    [arrays removeObjectsInRange:NSMakeRange(0, MAX_DATA_SIZE)];
    NSArray *newarray = [arrays copy];
    return newarray;
}

//拆分成各种小部分
-(NSDictionary *)changeLastPacketDict:(NSArray *) array row:(NSInteger) number dict:(NSDictionary*) dict{
    NSDictionary *lastPacketDict = [NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:ARRAY_ID],FLASH_ARRAY_ID,
    @(number),FLASH_ROW_NUMBER,
    array,ROW_DATA, nil];
    
    return lastPacketDict;
}

-(NSDictionary *)changeVerifyRow:(NSArray*) array currentIndex:(NSInteger) index currentRow:(NSInteger) row{
    /* Write the VERIFY_ROW command */
    NSDictionary *rowDataDict = [array objectAtIndex:index];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[rowDataDict objectForKey:ARRAY_ID],FLASH_ARRAY_ID,
                              @(row),FLASH_ROW_NUMBER,
                              nil];
    return dataDict;
}

-(uint8_t) rowCheckSumUint8:(NSArray *)array currentIndex:(NSInteger) index{
    
    NSDictionary *rowDataDict = [array objectAtIndex:index];
    uint8_t rowCheckSum = [self getIntegerFromHexString:[rowDataDict objectForKey:CHECKSUM_OTA]];
    uint8_t arrayID = [self getIntegerFromHexString:[rowDataDict objectForKey:ARRAY_ID]];
    unsigned short rowNumber = [self getIntegerFromHexString:[rowDataDict objectForKey:ROW_NUMBER]];
    unsigned short dataLength = [self getIntegerFromHexString:[rowDataDict objectForKey:DATA_LENGTH]];
    
    uint8_t sum = rowCheckSum + arrayID + rowNumber + (rowNumber >> 8) + dataLength + (dataLength >> 8);
    
    return sum;
}


// 计算代码解析文件名代码

- (NSArray *)parseFileNamesFromData:(NSArray *)data {
    NSNumber *len = data[1];
        NSArray *fileNamesData = [data subarrayWithRange:NSMakeRange(5, len.integerValue)];

        NSMutableArray *fileNames = [NSMutableArray array];
        NSMutableString *currentFileName = [NSMutableString string];
        NSInteger currentIndex = 0;

        for (NSNumber *byte in fileNamesData) {
            if (currentIndex == 0) {
                NSInteger fileSize = byte.integerValue;
                [currentFileName appendString:[NSString stringWithFormat:@"文件容量值：%ld，", (long)fileSize]];
            } else if (byte.integerValue != 0) {
                unichar character = (unichar)byte.integerValue;
                [currentFileName appendString:[NSString stringWithCharacters:&character length:1]];
            } else {
                [fileNames addObject:[currentFileName copy]];
                [currentFileName setString:@""];
            }
            
            currentIndex++;
        }
        
        return [fileNames copy];
}


@end

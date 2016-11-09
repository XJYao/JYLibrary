//
//  XTool.m
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTool.h"
#import "XThread.h"
#import "XFileManager.h"
#import "XIOSVersion.h"

@implementation XTool

+ (BOOL)isObjectNull:(id)obj {
    if(!obj || obj == nil || obj == Nil || obj == NULL || [obj isEqual:[NSNull null]] || obj == (id)kCFNull) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isStringEmpty:(NSString *)str {
    if ([self isObjectNull:str] || [str isEqualToString:@""] || str.length <= 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isArrayEmpty:(NSArray *)array {
    if ([self isObjectNull:array] || array.count <= 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isDictionaryEmpty:(NSDictionary *)dictionary {
    if ([self isObjectNull:dictionary] || dictionary.count <= 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isSetEmpty:(NSSet *)aSet {
    if ([self isObjectNull:aSet] || aSet.count <= 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isIndexSetEmpty:(NSIndexSet *)indexSet {
    if ([self isObjectNull:indexSet] || indexSet.count <= 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isDataEmpty:(NSData *)data {
    if ([self isObjectNull:data] || data.length <= 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isClassNull:(Class)cls {
    if (!cls || cls == Nil) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isEqualFromString:(NSString *)fromString toString:(NSString *)toString {
    BOOL isFromStringEmpty = [self isStringEmpty:fromString];
    BOOL isToStringEmpty = [self isStringEmpty:toString];
    if (!isFromStringEmpty && !isToStringEmpty) {
        return [fromString isEqualToString:toString];
    } else {
        if (isFromStringEmpty && isToStringEmpty) {
            return YES;
        } else {
            return NO;
        }
    }
}

+ (NSString *)getCurrentTime:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    return time;
}

+ (NSString *)getCurrentAppVersion {
    NSString *plistPath = [XFileManager getBundleResourcePathWithName:@"Info" type:@"plist"];
    NSDictionary *plistDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *currentVersion = [plistDic objectForKey:@"CFBundleShortVersionString"];
    return currentVersion;
}

+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateMobile:(NSString *)mobileNum {
    /**
     * 手机号码
     * 移动:134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通:130,131,132,152,155,156,185,186
     * 电信:133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动:China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通:China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信:China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号:010,020,021,022,023,024,025,027,028,029
     27         * 号码:七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum])
        || ([regextestcm evaluateWithObject:mobileNum])
        || ([regextestct evaluateWithObject:mobileNum])
        || ([regextestcu evaluateWithObject:mobileNum])) {
        return YES;
    } else {
        return NO;
    }
}

+ (CGSize)labelSize:(NSString *)text font:(UIFont *)font {
    return ([self isStringEmpty:text] ? CGSizeZero : [text sizeWithFont:font]);
}

+ (CGSize)labelSize:(NSString *)text font:(UIFont *)font maximumSize:(CGSize)maximumSize {
    CGSize labelSize;
    if ([self isStringEmpty:text]) {
        labelSize = CGSizeZero;
    } else {
        if ([XIOSVersion isIOS7OrGreater]) {
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
            labelSize = [text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        } else {
            labelSize = [text sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:NSLineBreakByWordWrapping];
        }
    }
    return labelSize;
}

+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    CGSize maximumLabelSize = CGSizeMake(width, MAXFLOAT);
    CGSize labelSize = [self labelSize:text font:font maximumSize:maximumLabelSize];
    
    return labelSize.height + 1;
}

+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width maxHeight:(CGFloat)maxHeight {
    CGSize maximumLabelSize = CGSizeMake(width, maxHeight);
    CGSize labelSize = [self labelSize:text font:font maximumSize:maximumLabelSize];
    return labelSize.height + 1;
}

+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font height:(CGFloat)height {
    CGSize maximumLabelSize = CGSizeMake(MAXFLOAT, height);
    CGSize labelSize = [self labelSize:text font:font maximumSize:maximumLabelSize];
    return labelSize.width;
}

+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font height:(CGFloat)height maxWidth:(CGFloat)maxWidth {
    CGSize maximumLabelSize = CGSizeMake(maxWidth, height);
    CGSize labelSize = [self labelSize:text font:font maximumSize:maximumLabelSize];
    return labelSize.width;
}

+ (NSString *)charToString:(char *)c {
    if(!c || strcmp(c, "") == 0) {
        return @"";
    } else {
        return [[NSString alloc] initWithUTF8String:c];
    }
}

+ (BOOL)appNotFirstLaunch {
    NSString *key = @"appNotFirstLaunch";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL appNotFirstLaunch = [userDefaults boolForKey:key];
    if (!appNotFirstLaunch) {
        [userDefaults setBool:YES forKey:key];
    }
    return appNotFirstLaunch;
}

+ (NSString *)getAppName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return appName;
}

+ (CGAffineTransform)rotationWithAngle:(CGFloat)angle {
    return CGAffineTransformMakeRotation(angle);
}

+ (CGSize)getResolution {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat screenWidth = width * scale;
    CGFloat screenHeight = height * scale;
    
    return CGSizeMake(screenWidth, screenHeight);
}

+ (NSString *)getLaunchImageName {
    NSString *launchImageName = @"";
    
    CGSize resolution = [self getResolution];
    if (resolution.width == 320 && resolution.height == 480) {
        launchImageName = @"Default@1x";
    } else if (resolution.width == 640 && resolution.height == 960) {
        launchImageName = @"Default@2x";
    } else if (resolution.width == 640 && resolution.height == 1136) {
        launchImageName = @"Default-568h@2x";
    } else if (resolution.width == 750 && resolution.height == 1334) {
        launchImageName = @"Default-667h@2x";
    } else if (resolution.width == 1242 && resolution.height == 2208) {
        launchImageName = @"Default-736h@3x";
    }
    
    return launchImageName;
}

+ (NSAttributedString *)attributeStringWithString:(NSString *)textString attributeTextRangesAndAttributeNamesAndValues:(NSValue *)rangeValue, ... NS_REQUIRES_NIL_TERMINATION {
    if ([self isStringEmpty:textString]) {
        return nil;
    }
    
    NSMutableArray *mutableObjects = [[NSMutableArray alloc] init];
    
    x_getMutableParams(rangeValue, mutableObjects);
    
    if ([self isArrayEmpty:mutableObjects]) {
        return nil;
    }
    
    if (mutableObjects.count % 3 != 0) {
        return nil;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textString];
    
    for (NSInteger i = 0; i < mutableObjects.count; i = i + 3) {
        NSRange range = [[mutableObjects x_objectAtIndex:i] rangeValue];
        NSString *name = [mutableObjects x_objectAtIndex:i+1];
        id value = [mutableObjects x_objectAtIndex:i+2];
        
        if (range.location == NSNotFound || range.length == 0) {
            break;
        }
        
        if ([self isStringEmpty:name]) {
            break;
        }
        
        if (!value) {
            break;
        }
        
        [attributedString addAttribute:name value:value range:range];
    }
    
    return attributedString;
}

+ (NSAttributedString *)attributeStringWithString:(NSString *)textString attributeTextsAndAttributeNamesAndValues:(NSString *)attributeText, ... NS_REQUIRES_NIL_TERMINATION {
    
    if ([self isStringEmpty:textString]) {
        return nil;
    }
    
    NSMutableArray *mutableObjects = [[NSMutableArray alloc] init];

    x_getMutableParams(attributeText, mutableObjects);
    
    if ([self isArrayEmpty:mutableObjects]) {
        return nil;
    }
    
    if (mutableObjects.count % 3 != 0) {
        return nil;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textString];
    
    for (NSInteger i = 0; i < mutableObjects.count; i = i + 3) {
        NSString *text = [mutableObjects x_objectAtIndex:i];
        NSString *name = [mutableObjects x_objectAtIndex:i+1];
        id value = [mutableObjects x_objectAtIndex:i+2];
        
        if ([self isStringEmpty:text]) {
            break;
        }
        
        if ([self isStringEmpty:name]) {
            break;
        }
        
        if (!value) {
            break;
        }
        
        NSInteger beginIndex = [textString rangeOfString:text].location;
        if (beginIndex == NSNotFound) {
            break;
        }
        [attributedString addAttribute:name value:value range:NSMakeRange(beginIndex, text.length)];
    }
    
    return attributedString;
}

+ (NSString *)urlWithMainUrl:(NSString *)mainUrl relativeUrl:(NSString *)relativeUrl {
    NSString *url = @"";
    
    if ([self isStringEmpty:relativeUrl]) {
        url = mainUrl;
    } else {
        url = [mainUrl stringByAppendingPathComponent:relativeUrl];
    }
    
    return url;
}

+ (NSInteger)getKeyIndexForData:(NSData *)data key:(NSString *)key {
    Byte *srcBytes = (Byte *)[data bytes];
    NSInteger keyIndex = NSNotFound;
    
    //搜索关键字位置
    for (NSInteger i = 0; i < data.length; i ++) {
        if (keyIndex != NSNotFound && keyIndex >= 0) {
            break;
        }
        
        for (NSInteger j = 0; j < key.length; j ++) {
            unichar tmpChar = srcBytes[i+j];
            if (tmpChar == [key characterAtIndex:j]) {
                if (j == key.length - 1) {
                    keyIndex = i;
                    break;
                }
            } else {
                break;
            }
        }
    }
    
    return keyIndex;
}

+ (NSString *)getValueOnResponseHead:(NSData *)headData key:(NSString *)key {
    NSInteger keyIndex = [self getKeyIndexForData:headData key:key];
    NSString *value = @"";
    
    if (keyIndex == NSNotFound || keyIndex < 0) {
        return value;
    }
    
    NSInteger endIndex = 0;
    Byte *headBytes = (Byte *)[headData bytes];
    //从关键字开始往后搜索换行符位置
    for (NSInteger i = keyIndex; i < headData.length; i++) {
        unichar tmpChar = headBytes[i];
        if (tmpChar == '\r') {
            endIndex = i;
            break;
        }
    }
    //endIndex-keyIndex关键字与换行符之间的长度,再减去关键字长度,即为值长度,如Content-Length:90
    NSInteger valueLength = endIndex - keyIndex - key.length;
    Byte *valueBytes = malloc(sizeof(Byte)*valueLength);
    //headBytes+keyIndex+key.length从关键字开始拷贝值长度个字符
    memcpy(valueBytes, headBytes + keyIndex + key.length, valueLength);
    NSData *valueData = [[NSData alloc] initWithBytes:valueBytes length:valueLength];
    free(valueBytes);
    value = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    
    return value;
}

//从响应头获取编码
+ (NSStringEncoding)getEncodingFromResponseHead:(NSData *)headData {
    NSStringEncoding encoding = NSNotFound;
    
    NSString *contentType = [self getValueOnResponseHead:headData key:@"Content-Type"];
    if ([self isStringEmpty:contentType]) {
        return encoding;
    }
    
    NSArray *contentTypeArray = [contentType componentsSeparatedByString:@"charset="];
    if ([self isArrayEmpty:contentTypeArray]) {
        return encoding;
    }

    NSString *charset = [contentTypeArray lastObject];
    if ([self isStringEmpty:charset]) {
        return encoding;
    }
    
    encoding = [self getEncodingWithCharset:charset];
    
    return encoding;
}

//从Response获取编码
+ (NSStringEncoding)getEncodingFromResponse:(NSHTTPURLResponse *)httpResponse {
    NSStringEncoding stringEncoding = NSNotFound;
    
    if (!httpResponse) {
        return stringEncoding;
    }
    
    if (![httpResponse respondsToSelector:@selector(allHeaderFields)]) {
        return stringEncoding;
    }
    
    NSDictionary *allHeaderFields = httpResponse.allHeaderFields;
    
    if ([self isDictionaryEmpty:allHeaderFields]) {
        return stringEncoding;
    }
    
    NSArray *contentTypeArray =[[allHeaderFields objectForKey:@"Content-Type"] componentsSeparatedByString:@"charset="];
    
    if ([self isArrayEmpty:contentTypeArray]) {
        return stringEncoding;
    }
    
    NSString *charset = [contentTypeArray lastObject];
    
    if ([self isStringEmpty:charset]) {
        return stringEncoding;
    }
    
    stringEncoding = [self getEncodingWithCharset:charset];
    
    return stringEncoding;
}

+ (NSStringEncoding)getEncodingWithCharset:(NSString *)charset {
    NSStringEncoding encoding = NSNotFound;
    
    if ([self isStringEmpty:charset]) {
        return encoding;
    }
    
    if ([charset caseInsensitiveCompare:@"utf-8"] == NSOrderedSame) {
        
        encoding = NSUTF8StringEncoding;
        
    } else if ([charset caseInsensitiveCompare:@"gbk"] == NSOrderedSame ||
               [charset caseInsensitiveCompare:@"gb2312"] == NSOrderedSame) {
        
        encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
    } else if ([charset caseInsensitiveCompare:@"iso-8859-1"] == NSOrderedSame) {
        encoding = NSISOLatin1StringEncoding;
    }
    
    return encoding;
}

+ (void)allowLockScreen:(BOOL)allow {
    [[UIApplication sharedApplication] setIdleTimerDisabled:!allow];
}

+ (BOOL)isDigit:(NSString *)string {
    return !([string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].length > 0);
}

+ (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

+ (id)performSelectorFromString:(NSString *)aSelectorName withSender:(id)sender hasReturn:(BOOL)hasReturn {
    if ([XTool isStringEmpty:aSelectorName]) {
        return nil;
    }
    SEL aSelector = NSSelectorFromString(aSelectorName);
    return [self performSelector:aSelector withSender:sender hasReturn:hasReturn];
}

+ (id)performSelector:(SEL)aSelector withSender:(id)sender hasReturn:(BOOL)hasReturn {
    id result = nil;
    if (![XTool isObjectNull:sender] && aSelector) {
        if ([sender respondsToSelector:aSelector]) {
            SuppressPerformSelectorLeakWarning
            ({
                if (hasReturn) {
                    result = [sender performSelector:aSelector];
                } else {
                    [sender performSelector:aSelector];
                }
            });
        }
    }
    return result;
}

+ (id)performSelectorFromString:(NSString *)aSelectorName withSendor:(id)sender withObject:(id)object hasReturn:(BOOL)hasReturn {
    if ([XTool isStringEmpty:aSelectorName]) {
        return nil;
    }
    SEL aSelector = NSSelectorFromString(aSelectorName);
    return [self performSelector:aSelector withSendor:sender withObject:object hasReturn:hasReturn];
}

+ (id)performSelector:(SEL)aSelector withSendor:(id)sender withObject:(id)object hasReturn:(BOOL)hasReturn {
    id result = nil;
    if (![XTool isObjectNull:sender] && aSelector) {
        if([sender respondsToSelector:aSelector]) {
            SuppressPerformSelectorLeakWarning({
                if (hasReturn) {
                    result = [sender performSelector:aSelector withObject:object];
                } else {
                    [sender performSelector:aSelector withObject:object];
                }
            });
        }
    }
    return result;
}

+ (id)performSelectorFromString:(NSString *)aSelectorName withSendor:(id)sender withObject:(id)object1 withObject:(id)object2 hasReturn:(BOOL)hasReturn {
    if ([XTool isStringEmpty:aSelectorName]) {
        return nil;
    }
    SEL aSelector = NSSelectorFromString(aSelectorName);
    return [self performSelector:aSelector withSendor:sender withObject:object1 withObject:object2 hasReturn:hasReturn];
}

+ (id)performSelector:(SEL)aSelector withSendor:(id)sender withObject:(id)object1 withObject:(id)object2 hasReturn:(BOOL)hasReturn {
    id result = nil;
    if (![XTool isObjectNull:sender] && aSelector) {
        if([sender respondsToSelector:aSelector]) {
            SuppressPerformSelectorLeakWarning({
                if (hasReturn) {
                    result = [sender performSelector:aSelector withObject:object1 withObject:object2];
                } else {
                    [sender performSelector:aSelector withObject:object1 withObject:object2];
                }
            });
        }
    }
    return result;
}

+ (void)releaseObject:(id)anObject {
    id tmp = anObject;
    anObject = nil;
    x_dispatch_async_default(^{
        [tmp class];
    });
}

+ (BOOL)isURL:(NSString *)URL {
    NSString *GOOD_IRI_CHAR = @"a-zA-Z0-9\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF";
    NSString *IRI = [NSString stringWithFormat:@"[%@]([%@\\-]{0,61}[%@]){0,1}",GOOD_IRI_CHAR,GOOD_IRI_CHAR,GOOD_IRI_CHAR];
    NSString *GOOD_GTLD_CHAR =@"a-zA-Z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF";
    NSString *GTLD = [NSString stringWithFormat:@"[%@]{2,63}",GOOD_GTLD_CHAR];
    NSString *HOST_NAME = [NSString stringWithFormat:@"(%@\\.)%@",IRI,GTLD];
    NSString *IP_ADDRESS = @"((25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9]))";
    NSString *DOMAIN_NAME = [NSString stringWithFormat:@"(%@|%@)",HOST_NAME,IP_ADDRESS];
    NSString *regex = [NSString stringWithFormat:@"((?:(http|https|Http|Https|rtsp|Rtsp):\\/\\/(?:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%%[a-fA-F0-9]{2})){1,64}(?:\\:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%%[a-fA-F0-9]{2})){1,25})?\\@)?)?(?:%@)(?:\\:\\d{1,5})?)(\\/(?:(?:[%@\\;\\/\\?\\:\\@\\&\\=\\#\\~\\-\\.\\+\\!\\*\\'\\(\\)\\,\\_])|(?:\\%%[a-fA-F0-9]{2}))*)?(?:\\b|$)",DOMAIN_NAME,GOOD_IRI_CHAR];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:URL];
}

+ (NSString *)insertHTTPAtURLPrefixIfNotFound:(NSString *)URL {
    if ([XTool isStringEmpty:URL]) {
        return URL;
    }
    if ([URL hasPrefix:@"http"]) {
        return URL;
    }
    return [@"http://" stringByAppendingString:URL];
}

@end

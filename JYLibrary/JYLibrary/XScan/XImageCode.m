//
//  XImageCode.m
//  XScan
//
//  Created by XJY on 16/2/26.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XImageCode.h"
#import "XIOSVersion.h"


@implementation XImageCode

+ (NSString *)readStringFromImage:(UIImage *)image {
    NSString *string = nil;

    if ([XIOSVersion isIOS8OrGreater]) {
        CIContext *context = [CIContext contextWithOptions:nil];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
        NSArray *features = [detector featuresInImage:ciImage];

        if (features && features.count > 0) {
            CIQRCodeFeature *feature = [features firstObject];
            string = feature.messageString;
        }
    }

    return string;
}

+ (UIImage *)imageFromString:(NSString *)string size:(CGSize)size frontColor:(UIColor *)frontColor backColor:(UIColor *)backColor {
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];

    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];

    if (!frontColor) {
        frontColor = [UIColor blackColor];
    }
    if (!backColor) {
        backColor = [UIColor whiteColor];
    }

    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                                           @"inputImage", qrFilter.outputImage,
                                           @"inputColor0", [CIColor colorWithCGColor:frontColor.CGColor],
                                           @"inputColor1", [CIColor colorWithCGColor:backColor.CGColor],
                                           nil];

    CIImage *qrImage = colorFilter.outputImage;

    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRelease(cgImage);

    return codeImage;
}

@end

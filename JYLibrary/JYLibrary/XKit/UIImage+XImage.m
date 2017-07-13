//
//  UIImage+XImage.m
//  JYLibrary
//
//  Created by XJY on 16/1/19.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "UIImage+XImage.h"
#import "XTool.h"
#import "XFileManager.h"
#import "NSArray+XArray.h"
#import "XMacro.h"


@implementation UIImage (XImage)

+ (UIImage *)initImageWithContentsOfName:(NSString *)imageName {
    if ([XTool isStringEmpty:imageName]) {
        return nil;
    } else {
        UIImage *image = nil;
        if ([imageName rangeOfString:@"."].location == NSNotFound) {
            image = [self initImageWithContentsOfName:imageName type:@"png"];
            if (!image) {
                image = [self initImageWithContentsOfName:imageName type:@"jpg"];
            }
            if (!image) {
                image = [self initImageWithContentsOfName:imageName type:@"jpeg"];
            }
            if (!image) {
                image = [self initImageWithContentsOfName:imageName type:@"bmp"];
            }
        } else {
            NSString *name = [XFileManager getFileNameWithoutSufixForName:imageName];
            NSString *type = [XFileManager getSufixForName:imageName];
            image = [self initImageWithContentsOfName:name type:type];
        }
        return image;
    }
}

+ (UIImage *)imageWithContentsOfName:(NSString *)imageName {
    if ([XTool isStringEmpty:imageName]) {
        return nil;
    } else {
        UIImage *image = nil;
        if ([imageName rangeOfString:@"."].location == NSNotFound) {
            image = [self imageWithContentsOfName:imageName type:@"png"];
            if (!image) {
                image = [self imageWithContentsOfName:imageName type:@"jpg"];
            }
            if (!image) {
                image = [self imageWithContentsOfName:imageName type:@"jpeg"];
            }
            if (!image) {
                image = [self imageWithContentsOfName:imageName type:@"bmp"];
            }
        } else {
            NSString *name = [XFileManager getFileNameWithoutSufixForName:imageName];
            NSString *type = [XFileManager getSufixForName:imageName];
            image = [self imageWithContentsOfName:name type:type];
        }
        return image;
    }
}

+ (UIImage *)initImageWithContentsOfName:(NSString *)imageName type:(NSString *)type {
    if ([XTool isStringEmpty:imageName]) {
        return nil;
    } else {
        NSString *imagePath = [XFileManager getBundleResourcePathWithName:imageName type:type];
        return [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
}

+ (UIImage *)imageWithContentsOfName:(NSString *)imageName type:(NSString *)type {
    if ([XTool isStringEmpty:imageName]) {
        return nil;
    } else {
        NSString *imagePath = [XFileManager getBundleResourcePathWithName:imageName type:type];
        return [UIImage imageWithContentsOfFile:imagePath];
    }
}

+ (UIImage *)imageWithNamed:(NSString *)imageName {
    if ([XTool isStringEmpty:imageName]) {
        return nil;
    } else {
        return [UIImage imageNamed:imageName];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return theImage;
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }

    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.height, aImage.size.width), aImage.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.width, aImage.size.height), aImage.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];

    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }

    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.

    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }

    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (UIImage *)subImageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

+ (NSData *)dataWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    return UIImagePNGRepresentation(image);
}

+ (UIImage *)changeImageSize:(UIImage *)sourceImage size:(CGSize)destSize {
    if (!sourceImage) {
        return sourceImage;
    }
    if (destSize.width <= 0 || destSize.height <= 0) {
        return nil;
    }

    UIGraphicsBeginImageContext(destSize);
    [sourceImage drawInRect:CGRectMake(0, 0, destSize.width, destSize.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return destImage;
}

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
+ (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size {
    NSParameterAssert(asset);
    NSParameterAssert(size > 0);

    ALAssetRepresentation *rep = [asset defaultRepresentation];

    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };

    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);

    CGImageRef imageRef =
        CGImageSourceCreateThumbnailAtIndex(source, 0,
                                            (__bridge CFDictionaryRef)
                                                @{
                                                    (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                    (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedLong:size],
                                                    (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                    (NSString *)kCGImagePropertyOrientation : [NSNumber numberWithInt:2],
                                                });
    CFRelease(source);
    CFRelease(provider);

    if (!imageRef) {
        return nil;
    }

    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];

    CFRelease(imageRef);

    return toReturn;
}

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;

    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];

    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
    }

    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

+ (UIImage *)thumbnailForImage:(UIImage *)asset maxPixelSize:(NSUInteger)size {
    NSParameterAssert(asset);
    NSParameterAssert(size > 0);

    NSData *data = UIImagePNGRepresentation(asset);

    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge const void *_Nullable)data, nil);

    CGImageRef imageRef =
        CGImageSourceCreateThumbnailAtIndex(source, 0,
                                            (__bridge CFDictionaryRef)
                                                @{
                                                    (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                    (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedLong:size],
                                                    (NSString *)kCGImagePropertyOrientation : [NSNumber numberWithInt:8],

                                                    (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,

                                                });

    CFRelease(source);

    if (!imageRef) {
        return nil;
    }

    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];

    CFRelease(imageRef);

    return toReturn;
}

+ (UIImage *)compressImage:(UIImage *)sourceImage pixels:(long long)destPixels {
    if (!sourceImage) {
        return sourceImage;
    }
    if (destPixels <= 0) {
        return nil;
    }

    CGSize sourceImageSize = sourceImage.size;
    CGFloat sourceImageWidth = sourceImageSize.width;
    CGFloat sourceImageHeight = sourceImageSize.height;

    if (sourceImageWidth <= 0 || sourceImageHeight <= 0) {
        return sourceImage;
    }

    long long sourceTotalPixels = (long long)(sourceImageWidth * sourceImageHeight);

    if (sourceTotalPixels <= destPixels) {
        return sourceImage;
    }

    CGFloat imageScale = sourceImageWidth / sourceImageHeight;

    CGFloat destImageHeight = (CGFloat)sqrt(destPixels / imageScale);
    CGFloat destImageWidth = destImageHeight * imageScale;

    return [self changeImageSize:sourceImage size:CGSizeMake(destImageWidth, destImageHeight)];
}

+ (NSArray *)imagesWithData:(NSData *)data {
    if (!data) {
        return nil;
    }

    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);

    size_t count = CGImageSourceGetCount(source);

    NSMutableArray *images = [[NSMutableArray alloc] init];

    if (count <= 1) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if (image) {
            [images x_addObject:image];
        }
    } else {
        for (size_t i = 0; i < count; i++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
            [images x_addObject:image];
            CGImageRelease(imageRef);
        }
    }

    CFRelease(source);

    return images;
}

+ (UIImage *)mergeImages:(NSArray *)images {
    if ([XTool isArrayEmpty:images]) {
        return nil;
    }

    CGFloat totalImageWidth = 0;
    CGFloat totalImageHeight = 0;

    for (UIImage *subImage in images) {
        if (!subImage) {
            continue;
        }

        totalImageWidth = MAX(totalImageWidth, subImage.size.width);
        totalImageHeight += subImage.size.height;
    }

    UIGraphicsBeginImageContext(CGSizeMake(totalImageWidth, totalImageHeight));

    totalImageHeight = 0;
    for (UIImage *subImage in images) {
        if (!subImage) {
            continue;
        }

        CGFloat subImageWidth = subImage.size.width;
        CGFloat subImageHeight = subImage.size.height;
        CGFloat subImageX = (totalImageWidth - subImageWidth) / 2.0;
        CGFloat subImageY = totalImageHeight;
        totalImageHeight += subImageHeight;

        [subImage drawInRect:CGRectMake(subImageX, subImageY, subImageWidth, subImageHeight)];
    }

    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return finalImage;
}

+ (UIImage *)mergeImagesWithImage:(UIImage *)image, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    x_getMutableParams(image, images);

    if ([XTool isArrayEmpty:images]) {
        return image;
    }

    return [self mergeImages:images];
}

+ (UIImage *)thumbnailImageFromData:(NSData *)data imageSize:(int)imageSize {
    if ([XTool isObjectNull:data]) {
        return nil;
    }

    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge const void *_Nullable)data, nil);
    if (!imageSource) {
        return nil;
    }

    //创建缩略图等比缩放大小，会根据长宽值比较大的作为imageSize进行缩放
    CFNumberRef thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);

    CFStringRef imageKeys[3];
    CFTypeRef imageValues[3];

    imageKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    imageValues[0] = (CFTypeRef)kCFBooleanTrue;

    imageKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    imageValues[1] = (CFTypeRef)kCFBooleanTrue;
    //缩放键值对
    imageKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    imageValues[2] = (CFTypeRef)thumbnailSize;

    CFDictionaryRef imageOptions = CFDictionaryCreate(NULL, (const void **)imageKeys,
                                                      (const void **)imageValues, 3,
                                                      &kCFTypeDictionaryKeyCallBacks,
                                                      &kCFTypeDictionaryValueCallBacks);
    //获取缩略图
    CGImageRef thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, imageOptions);
    CFRelease(imageOptions);
    CFRelease(thumbnailSize);
    CFRelease(imageSource);
    
    if (!thumbnailImage) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithCGImage:thumbnailImage];

    CFRelease(thumbnailImage);
    
    return image;
}

@end

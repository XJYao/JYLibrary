//
//  XScan.m
//  XScan
//
//  Created by XJY on 16/2/25.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XScan.h"
#import <AVFoundation/AVFoundation.h>
#import "XDeviceAuthorization.h"
#import "XIOSVersion.h"

typedef void (^XScanCompletedBlock)(NSString *);

@interface XScan () <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureMetadataOutput *output;
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *layer;
    
    XScanCompletedBlock scanCompletedBlock;
}

@end

@implementation XScan

- (instancetype)initWithView:(UIView *)view accessCompletion:(void (^)(XScanAuthorizationStatus))block {
    self = [super init];
    
    if (self) {

        if ([XIOSVersion isIOS7OrGreater]) {
            NSString *mediaType = AVMediaTypeVideo;
            
            [XDeviceAuthorization cameraAuthorizationStatus:^(XDeviceAuthorizationStatus authorizationStatus) {
                
                if (authorizationStatus == XDeviceAuthorizationStatusNotDetermined) {
                    
                    if (block) {
                        block(XScanAuthorizationStatusNotDetermined);
                    }
                    
                } else if (authorizationStatus == XDeviceAuthorizationStatusRestricted) {
                    
                    if (block) {
                        block(XScanAuthorizationStatusRestricted);
                    }
                    
                } else if (authorizationStatus == XDeviceAuthorizationStatusDenied) {
                    
                    if (block) {
                        block(XScanAuthorizationStatusDenied);
                    }
                    
                } else if (authorizationStatus == XDeviceAuthorizationStatusAuthorized) {
                    
                    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:mediaType];
                    
                    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
                    
                    output = [[AVCaptureMetadataOutput alloc] init];
                    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
                    
                    session = [[AVCaptureSession alloc]init];
                    [session setSessionPreset:AVCaptureSessionPresetHigh];
                    if ([session canAddInput:input]) {
                        [session addInput:input];
                    }
                    if ([session canAddOutput:output]) {
                        [session addOutput:output];
                    }
                    [output setMetadataObjectTypes:@[
                                                     AVMetadataObjectTypeQRCode,
                                                     AVMetadataObjectTypeEAN13Code,
                                                     AVMetadataObjectTypeEAN8Code,
                                                     AVMetadataObjectTypeCode128Code
                                                     ]];
                    
                    layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
                    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                    [view.layer insertSublayer:layer atIndex:0];
                    
                    [self setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
                    
                    if (block) {
                        block(XScanAuthorizationStatusAuthorized);
                    }
                }
            }];
            
        } else {
            if (block) {
                block(XScanAuthorizationStatusDenied);
            }
        }
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    if ([XIOSVersion isIOS7OrGreater]) {
        _frame = frame;
        [layer setFrame:_frame];
    }
}

- (void)setScanRect:(CGRect)scanRect {
    if ([XIOSVersion isIOS7OrGreater]) {
        _scanRect = CGRectMake(scanRect.origin.y * 1.0 / _frame.size.height, scanRect.origin.x * 1.0 / _frame.size.width, scanRect.size.height * 1.0 / _frame.size.height, scanRect.size.width * 1.0 / _frame.size.width);
        [output setRectOfInterest:_scanRect];
    }
}

- (void)start:(XScanCompletedBlock)block {
    scanCompletedBlock = block;
    
    if ([XIOSVersion isIOS7OrGreater]) {
        if (!session.isRunning) {
            [session startRunning];
        }
    }
}

- (void)stop {
    if ([XIOSVersion isIOS7OrGreater]) {
        if (session.isRunning) {
            [session stopRunning];
        }
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (scanCompletedBlock) {
        if (metadataObjects && metadataObjects.count > 0) {
            AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects x_objectAtIndex:0];
            scanCompletedBlock(metadataObject.stringValue);
        }
    }
}

@end

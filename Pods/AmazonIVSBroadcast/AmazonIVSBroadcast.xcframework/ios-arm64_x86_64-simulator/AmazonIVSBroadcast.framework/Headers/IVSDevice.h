//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "IVSBase.h"

@class IVSDeviceDescriptor;

NS_ASSUME_NONNULL_BEGIN

/// Types of input devices.
typedef NS_ENUM(NSInteger, IVSDeviceType) {
    /// The device type is unknown.
    IVSDeviceTypeUnknown = 0,
    /// The device is a video camera.
    IVSDeviceTypeCamera = 1,
    /// The device is a audio microphone.
    IVSDeviceTypeMicrophone = 2,
    /// The device is a user provided image stream.
    IVSDeviceTypeUserImage = 5,
    /// The device is user provided audio.
    IVSDeviceTypeUserAudio = 6,
};

/// Media types present in a stream.
typedef NS_ENUM(NSInteger, IVSDeviceStreamType) {
    /// The device stream will contain audio PCM encoded samples.
    IVSDeviceStreamTypePCM,
    /// The device stream will contain image samples.
    IVSDeviceStreamTypeImage,
};

/// The position of the input device relative to the host device.
typedef NS_ENUM(NSInteger, IVSDevicePosition) {
    /// The device's position is unknown.
    IVSDevicePositionUnknown,
    /// The input device is located on the front of the host device.
    IVSDevicePositionFront,
    /// The input device is located on the back of the host device.
    IVSDevicePositionBack,
    /// The input device is connected to the host device via USB.
    IVSDevicePositionUSB,
    /// The input device is connected to the host device via bluetooth.
    IVSDevicePositionBluetooth,
    /// The input device is connected via an auxiliary cable.
    IVSDevicePositionAUX,
};

/// Represents an input device such as a camera or microphone.
IVS_EXPORT
@protocol IVSDevice <NSObject>

/// A descriptor of the device and its capabilities.
- (IVSDeviceDescriptor *)descriptor;
/// A unique tag for this device.
- (NSString *)tag;

@end

NS_ASSUME_NONNULL_END

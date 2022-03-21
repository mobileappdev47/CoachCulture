//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "IVSDevice.h"
#import "IVSBroadcastConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class IVSImagePreviewView;

/// This represents an IVSDevice that provides video samples.
IVS_EXPORT
@protocol IVSImageDevice <IVSDevice>

/// Sets the current rotation of the video device. This will be used to transform the output stream
///
/// This is handled automatically when attaching a camera via in `IVSDeviceDescriptor`.
///
/// @param rotation The rotation in radians
- (void)setHandsetRotation:(float)rotation;

/// Gets a view that will render a preview image of this device.
/// @param outError On input, a pointer to an error object. If an error occurs, the pointer is an NSError object that describes the error. If you don’t want error information, pass in nil.
///
/// @note this must be called on the main thread
- (nullable IVSImagePreviewView *)previewViewWithError:(NSError *__autoreleasing *)error;

/// Gets a view that will render a preview image of this device with the provided aspect ratio.
/// @param aspectMode the aspect mode to apply to the image stream rendering on the view.
/// @param outError On input, a pointer to an error object. If an error occurs, the pointer is an NSError object that describes the error. If you don’t want error information, pass in nil.
///
/// @note this must be called on the main thread
- (nullable IVSImagePreviewView *)previewViewWithAspectMode:(IVSAspectMode)aspectMode error:(NSError *__autoreleasing *)outError;

@end

/// An extention of `IVSImageDevice` that allows for submitting `CMSampleBuffer`s manually.
/// The currently supported pixel formats are:
/// `kCVPixelFormatType_32BGRA`
/// `kCVPixelFormatType_420YpCbCr8BiPlanarFullRange`
/// `kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange`
/// On devices that support it, the `Lossless` and `Lossy` equivalents of these formats are also supported.
///
/// @note Make sure you have an `IVSMixerSlotConfiguration` that requests the `preferredVideoInput` value of `IVSDeviceTypeUserVideo`.
IVS_EXPORT
@protocol IVSCustomImageSource <IVSImageDevice>

/// Submit a frame to the broadcaster for processing.
/// @param sampleBuffer a sample buffer with a `CVPixelBuffer` with a supported pixel format.
- (void)onSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

/// An extention of `IVSCustomImageSource` that is used to pre-encode an image or video to be rendered when the application
/// goes into the background.
///
/// The timing information on the samples provided via `onSampleBuffer` is ignored on this image source, every image submitted will
/// be encoded as the next frame based on the `targetFramerate` on the provided `IVSVideoConfiguration`.
///
/// @note samples submitted will be processed on the invoking thread. For large amounts samples, submit them on a background queue.
///
/// Generating large numbers of samples from MP4 files is fairly straight forward using AVFoundation. There are multiple ways to do it in fact
/// You can use `AVAssetImageGenerator` and `generateCGImagesAsynchronously` to generate an image at every 1 / FPS increment.
/// Be certain to set `requestedTimeToleranceAfter` and `requestedTimeToleranceBefore` to `.zero`, otherwise it will batch the same frame multiple times.
///
/// You can also use an `AVPlayer` instance with `AVPlayerItemVideoOutput` and a `DisplayLink`, using the `copyPixelBuffer` API from the video output.
///
/// Both can provide a series of CVPixelBuffers to submit to this API in order to broadcast a looping clip while in the background.
///
IVS_EXPORT
@protocol IVSBackgroundImageSource <IVSCustomImageSource>

/// Signals that no more images will be submitted for encoding and final processing should begin.
- (void)finish;

/// A convenience API that doesn't require creating a `CMSampleBufferRef` to provide to the `IVSCustomImageSource` API, since timing data is ignored for the background source.
/// @param pixelBuffer The PixelBuffer to be encoded.
- (void)addPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end



NS_ASSUME_NONNULL_END

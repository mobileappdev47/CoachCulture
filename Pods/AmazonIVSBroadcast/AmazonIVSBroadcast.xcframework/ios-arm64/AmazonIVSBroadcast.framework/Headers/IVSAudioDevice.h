//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import "IVSDevice.h"

@class IVSDeviceDescriptor;
@protocol IVSMicrophoneDelegate;

NS_ASSUME_NONNULL_BEGIN

/// A description of the sample size and structure for audio samples.
typedef NS_ENUM(NSInteger, IVSAudioFormat) {
    /// 16 bit signed integer audio, interleaved
    IVSAudioFormatInt16,
    /// 16 bit signed integer audio, planar
    IVSAudioFormatInt16_Planar,
    /// 32 bit floating point audio, interleaved
    IVSAudioFormatFloat32,
    /// 32 bit floating point audio, planar
    IVSAudioFormatFloat32_Planar,
    /// 32 bit signed integer audio, interleaved
    IVSAudioFormatInt32,
    /// 32 bit signed integer audio, planar
    IVSAudioFormatInt32_Planar,
    /// 64 bit floating point audio, interleaved
    IVSAudioFormatFloat64,
    /// 64 bit floating point audio, planar
    IVSAudioFormatFloat64_Planar,
};

/// This represents an IVSDevice that provides audio samples.
IVS_EXPORT
@protocol IVSAudioDevice <IVSDevice>

/// Sets the gain for this audio device. This will be clamped between 0 and 2.
/// A gain of 1 means no change. A gain less than 1 will suppress, and greater than 1 will amplify.
/// @param gain the requested gain
- (void)setGain:(float)gain;

@end

/// An extention of `IVSAudioDevice` that allows for submitting `CMSampleBuffer`s manually. This can be used to submit
/// PCM audio directly to the SDK.
///
/// @note Make sure you have an `IVSMixerSlotConfiguration` that requests the `preferredAudioInput` value of `IVSDeviceTypeUserAudio`.
IVS_EXPORT
@protocol IVSCustomAudioSource <IVSAudioDevice>

/// Submit a frame to the broadcaster for processing.
/// @param sampleBuffer a sample buffer with a PCM audio data.
- (void)onSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// Submit raw PCM data with its sample time for processing.
/// @param pcmBuffer A PCM audio buffer
/// @param audioTime The time the PCM audio buffer was recorded
- (void)onPCMBuffer:(AVAudioPCMBuffer *)pcmBuffer at:(AVAudioTime *)audioTime;

@end

/// An extension of `IVSAudioDevice` that represents a physical microphone accessible by the host device.
IVS_EXPORT
@protocol IVSMicrophone <IVSAudioDevice>

/// Assign a delegate to receive updates about the attached microphone.
@property (nonatomic, weak) id<IVSMicrophoneDelegate> delegate;

@end

/// A delegate that provides updates about the attached microphone.
IVS_EXPORT
@protocol IVSMicrophoneDelegate

/// Invoked when the underlying input source providing audio samples to the microphone changes. This could be the result of a bluetooth headset being connected
/// or disconnected, a wired headset being plugged in or unplugged, or any other audio device hardware change that might trigger a system route change. Always invoked on the main queue.
/// @param microphone The microphone that had it's underlying input source changed
/// @param inputSource The new input source. If this is `nil` it means there is no available input source to record from. This might happen if the AVAudioSession gets deactivated. When
/// this happens the SDK will wait for another input source to become available and switch to it when it can.
- (void)underlyingInputSourceChangedForMicrophone:(id<IVSMicrophone>)microphone toInputSource:(nullable IVSDeviceDescriptor *)inputSource;

@end

NS_ASSUME_NONNULL_END

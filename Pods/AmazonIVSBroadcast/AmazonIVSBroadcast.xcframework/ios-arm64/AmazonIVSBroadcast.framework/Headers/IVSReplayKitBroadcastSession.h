//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMSampleBuffer.h>
#import "IVSBase.h"

@class IVSVideoConfiguration;
@class IVSAudioConfiguration;
@protocol IVSBroadcastSessionDelegate;
@protocol IVSCustomImageSource;
@protocol IVSCustomAudioSource;

NS_ASSUME_NONNULL_BEGIN

/// This is a streamlined version of an `IVSBroadcastSession` to be used in a Broadcast Upload Extension.
/// The extensions are under strict memory constraints, and this class removes some of the SDK features in exchange
/// for a reduction in memory footprint.
///
/// For example, there are no attach or detach APIs. There are 3 devices created for you, corresponding to the screen,
/// app audio, and the microphone. Pass CMSampleBuffers to these devices from your `RPBroadcastSampleHandler`
/// implementation. In addition, there is no mixer configuration and no access to an `IVSBroadcastMixer`. This class
/// does not support multiple image layers, and the primary layer (the device screen) is always sized to the full output
/// stream scaled to fit. Transparency is also disabled regardless of what is provided in the video configuration.
///
/// Finally, you can not create a preview for the `systemImageSource` or the session as a whole, they will not render anything.
///
/// @note this will automatically set `IVSBroadcastSession.applicationAudioSessionStrategy` to `noAction`.
IVS_EXPORT
@interface IVSReplayKitBroadcastSession : NSObject

/// A device that is meant to be associated with the `video` samples in your `RPBroadcastSampleHandler` implementation.
@property (nonatomic, readonly) id<IVSCustomImageSource> systemImageSource;

/// A device that is meant to be associated with the `audioApp` samples in your `RPBroadcastSampleHandler` implementation.
@property (nonatomic, readonly) id<IVSCustomAudioSource> systemAudioSource;

/// A device that is meant to be associated with the `audioMic` samples in your `RPBroadcastSampleHandler` implementation.
@property (nonatomic, readonly) id<IVSCustomAudioSource> microphoneSource;

/// Creates an instance of `IVSReplayKitBroadcastSession`.
/// @param videoConfig the video configuration for the output stream.
/// @param audioConfig the audio configuration for the output stream.
/// @param delegate an `IVSBroadcastSessionDelegate` to receive callbacks from the broadcast session.
/// @param outError On input, a pointer to an error object. If an error occurs, the pointer is an NSError object that describes the error. If you don’t want error information, pass in nil.
- (nullable instancetype)initVideoConfiguration:(IVSVideoConfiguration *)videoConfig
                                    audioConfig:(IVSAudioConfiguration *)audioConfig
                                       delegate:(nullable id<IVSBroadcastSessionDelegate>)delegate
                                          error:(NSError *__autoreleasing *)outError;

/// Start the configured broadcast session.
/// @param url the RTMPS endpoint provided by IVS.
/// @param streamKey the broadcaster's stream key that has been provided by IVS.
/// @param outError A reference to an NSError that would be set if an error occurs.
/// @return if the operation is successful. If it returns NO check `isReady`.
- (BOOL)startWithURL:(NSURL *)url streamKey:(NSString *)streamKey error:(NSError *__autoreleasing *)outError;

/// Stop the broadcast session, but do not deallocate resources.
- (void)stop;

@end

NS_ASSUME_NONNULL_END

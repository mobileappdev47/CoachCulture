//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import "IVSBase.h"
#import "IVSBroadcastConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class IVSBroadcastConfiguration;
@class IVSVideoConfiguration;
@class IVSDeviceDescriptor;
@class IVSBroadcastMixer;
@class IVSImagePreviewView;
@class IVSBroadcastSessionTest;
@class IVSBroadcastSessionTestResult;
@class UIView;
@protocol IVSDevice;
@protocol IVSCustomImageSource;
@protocol IVSCustomAudioSource;
@protocol IVSBackgroundImageSource;
@protocol IVSBroadcastSessionDelegate;
@protocol MTLDevice;
@protocol MTLCommandQueue;

/// A callback to recieve `IVSBroadcastSessionTestResult`s asynchronously.
typedef void (^IVSSessionTestResultCallback)(IVSBroadcastSessionTestResult * _Nonnull);

/// A value representing the `IVSBroadcastSession`s current state.
typedef NS_ENUM(NSInteger, IVSBroadcastSessionState) {
    /// The session is invalid. This is the initial state after creating a session but before starting a stream.
    IVSBroadcastSessionStateInvalid,
    /// The session has disconnected. After stopping a stream the session should return to this state unless it has errored.
    IVSBroadcastSessionStateDisconnected,
    /// The session is connecting to the ingest server.
    IVSBroadcastSessionStateConnecting,
    /// The session has connected to the ingest server and is currently sending data.
    IVSBroadcastSessionStateConnected,
    /// The session has had an error. Use the `IVSBroadcastSessionDelegate` to catch errors thrown by the session.
    IVSBroadcastSessionStateError,
} NS_SWIFT_NAME(IVSBroadcastSession.State);

/// A value representing how the `IVSBroadcastSession` will interact with `AVAudioSession`.
typedef NS_ENUM(NSInteger, IVSBroadcastSessionAudioSessionStrategy) {
    /// The SDK controls `AVAudioSession` completely and will set the category to `playAndRecord`.
    IVSBroadcastSessionAudioSessionStrategyPlayAndRecord,
    /// The SDK controls `AVAudioSession` completely and will set the category to `record`.
    /// There is a known issue with the `recordOnly` category and AirPods. Please use `playAndRecord` if you wish to use AirPods.
    IVSBroadcastSessionAudioSessionStrategyRecordOnly,
    /// The SDK does not control `AVAudioSession` at all. If this strategy is selected only custom audio sources will be allowed.
    /// Microphone based sources will not be returned or added by any APIs.
    IVSBroadcastSessionAudioSessionStrategyNoAction,
} NS_SWIFT_NAME(IVSBroadcastSession.AudioSessionStrategy);

/// BroadcastSession is the primary interaction point with the IVS Broadcast SDK.
/// You must create a BroadcastSession in order to begin broadcasting.
///
/// @note If there as a live broadcast when this object deallocates, internally `stop` will be called during deallocation, and it will block
/// until the stream has been gracefully terminated or a timeout is reeached. Because of that it is recommended that you always explicitly
/// stop a live broadcast before deallocating.
IVS_EXPORT
@interface IVSBroadcastSession : NSObject

/// The broadcast SDK version.
@property (nonatomic, class, readonly) NSString *sdkVersion;

/// The unique ID of this broadcast session. This will be updated every time the stream is stopped.
@property (nonatomic, strong, readonly) NSString *sessionId;

/// Whether or not the session is ready for use.
///
/// This state is constant once the session has been initialized with the exception of when your app
/// is backgrounded. When backgrounded, isReady will become NO regardless of its previous state when the SDK tears
/// down some resources. When coming back to the foreground isReady will receive a new `isReady` value. Outside
/// of backgrounding and foregrounding the value of `isReady` will never change. If this method returns NO, be sure to assign
/// the `delegate` property in the `IVSBroadcastSession` initializer so that you receive the relevant error.
@property (nonatomic, readonly) BOOL isReady;

/// A protocol for client apps to listen to important updates from the Broadcast SDK.
@property (nonatomic, weak, nullable) id<IVSBroadcastSessionDelegate> delegate;

/// The session mixer instance. This allows you to control on-screen elements.
@property (nonatomic, nonnull, readonly) IVSBroadcastMixer *mixer;

/// Logging level for the broadcast session. Default is `IVSBroadcastLogLevelError`.
@property (nonatomic) IVSBroadcastLogLevel logLevel;

/// A value that indicates whether the broadcast session automatically changes settings in the app’s shared audio session.
///
/// @note Changing this property can impact the devices return by `listAvailableDevices`.
///
/// The value of this property defaults to `playAndRecord`, causing the broadcast session to automatically configure the app’s
/// shared `AVAudioSession` instance . You can also set it to `.recordOnly` to still let the SDK manage
/// the settings, but use the `record` `AVAudioSession` category instead of `playAndRecord`. Note there is an issue with recording
/// audio with AirPods using `recordOnly`, so `playAndRecord` is recommended.
/// If you set this property’s value to `noAction`, your app is responsible for selecting appropriate audio session settings.
/// Recording may fail if the audio session’s settings are incompatible with the the desired inputs.
/// Letting the broadcast SDK manage the audio session is especially useful when dealing with audio input devices other than
/// the built in microphone, as it will allow the SDK to manage all of the routing for you.
/// If this value is anything except `noAction`, it is expected that your app will not interact with `AVAudioSession` while an `IVSBroadcastSession` is allocated.
/// If you switch this to `noAction` after, setting up the `IVSBroadcastSession`, the broadcast SDK will immediately stop interacting with AVAudioSession.
/// It will not reset any values to their original state, so if your app needs control, be prepared to set all relevant properties since the broadcast SDK may have
/// changed many things.
@property (nonatomic, class) IVSBroadcastSessionAudioSessionStrategy applicationAudioSessionStrategy;

/// Create an IVSBroadcastSession object that can stream to an IVS endpoint via RTMP
/// @param config a Broadcast configuration, either one of the `IVSPresets` or a custom configuration.
/// @param descriptors an optional list of devices to instantiate immediately. To get a list of devices see `listAvailableDevices`.
/// @param delegate an `IVSBroadcastSessionDelegate` to receive callbacks from the broadcast session.
/// @param outError On input, a pointer to an error object. If an error occurs, the pointer is an NSError object that describes the error. If you don’t want error information, pass in nil.
- (nullable instancetype)initWithConfiguration:(IVSBroadcastConfiguration *)config
                                   descriptors:(nullable NSArray<IVSDeviceDescriptor *> *)descriptors
                                      delegate:(nullable id<IVSBroadcastSessionDelegate>)delegate
                                         error:(NSError *__autoreleasing *)outError;

/// Create a BroadcastSession object that can stream to an IVS endpoint via RTMP.
///
/// This initializer is specific to allowing a  `MTLDevice` and `MTLCommandQueue` to be provided.
/// These are expensive resources, and Apple recommends only allocating a single instance of each per application.
/// If your app is going to be using Metal outside of the broadcast SDK, you should provide your `MTLDevice`
/// and `MTLCommandQueue` here so they can be reused.
///
/// @param config a Broadcast configuration, either one of the `IVSPresets` or a custom configuration.
/// @param descriptors an optional list of devices to instantiate immediately. To get a list of devices see `listAvailableDevices`.
/// @param delegate an `IVSBroadcastSessionDelegate` to receive callbacks from the broadcast session.
/// @param metalDevice the `MTLDevice` for the broadcast SDK to use.
/// @param metalCommandQueue the `MTLCommandQueue` for the broadcast SDK to use.
/// @param outError On input, a pointer to an error object. If an error occurs, the pointer is an NSError object that describes the error. If you don’t want error information, pass in nil.
- (nullable instancetype)initWithConfiguration:(IVSBroadcastConfiguration *)config
                                   descriptors:(nullable NSArray<IVSDeviceDescriptor *> *)descriptors
                                      delegate:(nullable id<IVSBroadcastSessionDelegate>)delegate
                                   metalDevice:(nullable id<MTLDevice>)metalDevice
                             metalCommandQueue:(nullable id<MTLCommandQueue>)metalCommandQueue
                                         error:(NSError *__autoreleasing *)outError;

/// List available devices for use with a broadcast session.
/// The value of `applicationAudioSessionStrategy` will impact the devices returned by this API.
+ (NSArray<IVSDeviceDescriptor *> *)listAvailableDevices;

/// List attached, active devices being used with this broadcast session.
///
/// @note since devices are attached and detached asynchronously, this might not include the most recent changes. Use
/// `awaitDeviceChanges` to wait for all changes to complete before calling this to guarantee up to date results.
- (NSArray<id<IVSDevice>> *)listAttachedDevices;

/// Create and attach a device based on a descriptor for use with the broadcast session.
/// @param device The device descriptor for the device to be attached
/// @param slotName The name of a slot to bind to when attaching. If `nil` is provided it will attach to the first compatible slot.
/// @param onComplete A callback that contains the new device or any error that occured while attaching. Invoked when the operation has completed. Always invoked on the main queue.
- (void)attachDeviceDescriptor:(IVSDeviceDescriptor *)descriptor
                toSlotWithName:(nullable NSString *)slotName
                    onComplete:(nullable void (^)(id<IVSDevice> _Nullable, NSError * _Nullable))onComplete;

/// Attach a device for use with the broadcast session.
/// @param device The device to be attached
/// @param slotName The name of a slot to bind to when attaching. If `nil` is provided it will attach to the first compatible slot.
/// @param onComplete A callback that contains any error that occured while attaching. Invoked when the operation has completed. Always invoked on the main queue.
- (void)attachDevice:(id<IVSDevice>)device
      toSlotWithName:(nullable NSString *)slotName
          onComplete:(nullable void (^)(NSError * _Nullable))onComplete;

/// Close and detach a device based on its descriptor.
/// @param device The descriptor for the device to close.
/// @param onComplete Invoked when the operation has completed. Always invoked on the main queue.
- (void)detachDeviceDescriptor:(IVSDeviceDescriptor *)descriptor
                    onComplete:(nullable void (^)())onComplete;

/// Close and detach a device.
/// @param device The device to close.
/// @param onComplete Invoked when the operation has completed. Always invoked on the main queue.
- (void)detachDevice:(id<IVSDevice>)device
          onComplete:(nullable void (^)())onComplete;

/// Exchange a device with another device of the same type. For hardware backed devices, this API might make
/// performance optimizations around locking compared to detaching and attaching the devices separately.
/// This method should not be used for custom audio and image sources.
/// @param oldDevice The device to replace
/// @param newDevice The descriptor of the new device to attach
/// @param onComplete A callback that contains the new device or any error that occured while attaching. Invoked when the operation has completed. Always invoked on the main queue.
- (void)exchangeOldDevice:(id<IVSDevice>)oldDevice
            withNewDevice:(IVSDeviceDescriptor *)newDevice
               onComplete:(nullable void (^)(id<IVSDevice> _Nullable, NSError * _Nullable))onComplete;

/// Waits for all pending device operations to complete, then invokes onComplete.
/// @param onComplete Always invoked on the main queue.
- (void)awaitDeviceChanges:(void (^)())onComplete;

/// Start the configured broadcast session.
/// @param url the RTMPS endpoint provided by IVS.
/// @param streamKey the broadcaster's stream key that has been provided by IVS.
/// @param outError A reference to an NSError that would be set if an error occurs.
/// @return if the operation is successful. If it returns NO check `isReady`.
- (BOOL)startWithURL:(NSURL *)url streamKey:(NSString *)streamKey error:(NSError *__autoreleasing *)outError;

/// Stop the broadcast session, but do not deallocate resources. Stopping the stream happens asynchronously while the SDK attempts to gracefully end the
/// broadcast. Please obverse state changes in the `IVSBroadcastSessionDelegate` to know when you can start a new stream.
- (void)stop;

/// Create an image input for a custom source. This should only be used if you intend to generate and feed image data to the SDK manually.
- (id<IVSCustomImageSource>)createImageSourceWithName:(NSString *)name;

/// Create an audio input for a custom source. This should only be used if you intend to generate and feed pcm audio data to the SDK manually.
- (id<IVSCustomAudioSource>)createAudioSourceWithName:(NSString *)name;

/// Gets a view that will render a preview image of the composited video stream. This will match what consumers see when watching the broadcast.
/// @param aspectMode the aspect mode to apply to the image stream rendering on the view.
/// @param outError On input, a pointer to an error object. If an error occurs, the pointer is an NSError object that describes the error. If you don’t want error information, pass in nil.
///
/// @note this must be called on the main thread
- (nullable IVSImagePreviewView *)previewViewWithAspectMode:(IVSAspectMode)aspectMode error:(NSError *__autoreleasing *)outError;

/// Runs a network test with a default duration of 8 seconds.
/// @see `-[IVSBroadcastSession recommendedVideoSettingsWithURL:streamKey:duration:results:]`
- (nullable IVSBroadcastSessionTest *)recommendedVideoSettingsWithURL:(NSURL *)url
                                                            streamKey:(NSString *)streamKey
                                                              results:(IVSSessionTestResultCallback)onNewResult;

/// This will perform a network test and provide recommendations for video configurations. It will not publish live video, it will only test the connection quality.
/// The callback will be called periodically and provide you with a status, progress, and continuously updated recommendations. The longer the test runs
/// the more refined the suggestions will be, however you can cancel the test at any time and make use of previous recommendations. But these recommendations
/// might not be as stable, or as high quality as a fully completed test.
///
/// @note This can not be called while an existing broadcast is in progress, and a new broadcast can not be started while a test is in progress.
///
/// @param url the RTMPS endpoint provided by IVS.
/// @param streamKey the broadcaster's stream key that has been provided by IVS.
/// @param duration How long to run the test for. It's recommended the test runs for at least 8 seconds, and the minimum is 3 seconds. The test can always be cancelled early.
/// @param onNewResult a block that will be called periodically providing you with an update on the test's progress and recommendations.
/// @return a handle to the network test, providing you a way to cancel it, or `nil` if there is an error starting the test.
- (nullable IVSBroadcastSessionTest *)recommendedVideoSettingsWithURL:(NSURL *)url
                                                            streamKey:(NSString *)streamKey
                                                             duration:(NSTimeInterval)duration
                                                              results:(IVSSessionTestResultCallback)onNewResult;

/// Invoking this API changes the default behavior when your application goes into the background. By default any active broadcast will
/// stop, and all I/O devices will be shutdown until the app is foregrounded again. After calling this API and receiving an error free callback,
/// the broadcast will remain active in the background and will loop the video provided to the `IVSBackgroundImageSource` returned
/// by this API. The audio sources will stay live.
///
/// The total duration of the background video must be an internal of the keyframe interval provided to the `IVSVideoConfiguration.keyframeInterval`
/// If the `keyframeInterval` is 2 seconds, the `targetFramerate` is 30, and you provide 45 images, the last 15 images will be trimmed, or the last image
/// will be repeated 15 times based on the value of the `attemptTrim` param.
/// Because of this, the API will work best if the number of images provide is a multiple of (`keyframeInterval` * `targetFramerate`).
/// A single image can also be provided to this source before calling `finish`, and that image will be encoded to a full GOP for a static background.
///
/// @note This is an expensive API, it is recommended that you call this before going live to prevent dropping frames. Additionally, this API
/// must be called while the application is in the foreground.
///
/// @note In order to continue to operate in the background, you will need to enable the background audio entilement for your application.
///
/// @param pixelBuffer A `CVPixelBuffer` that will be streamed while the app is in the background.
/// @param onComplete A callback that is invoked when the setup for background image broadcasting is complete. Always invoked on the main queue.
/// @param attemptTrim if this is YES, this API will attempt to trim the submitted samples to create a perfect looping clip, which means
/// some samples might be dropped to correctly end on a keyframe. If this is NO, the last frame will be repeated until the GOP is closed.
/// If this is YES and there were not enough samples submitted to create a full GOP, the last frame will always be repeated and the trim will not occur.
- (nullable id<IVSBackgroundImageSource>)createAppBackgroundImageSourceWithAttemptTrim:(BOOL)attemptTrim
                                                                            OnComplete:(nullable void (^)(NSError * _Nullable))onComplete;

/// Removes the behavior change from calling `createAppBackgroundImageSourceOnComplete` and cleans up the artifacts
/// generated by that API. Which means if the app goes into the background, the stream will be stopped again.
/// This API must be called while the application is in the foreground, otherwise an error will be returned.
///
/// @note This does not need to be called to resume streaming in the foreground. Only call this API if you want to disable the ability to stream in the background.
///
/// @param outError On input, a pointer to an error object. If an error occurs, the pointer is an NSError object that describes the error. If you don’t want error information, pass in nil.
- (BOOL)removeImageSourceOnAppBackgroundedWithError:(NSError *__autoreleasing *)outError;

@end

/// Provide a delegate to receive status updates and errors from the SDK. Updates may be run on arbitrary threads and not the main thread.
IVS_EXPORT
NS_SWIFT_NAME(IVSBroadcastSession.Delegate)
@protocol IVSBroadcastSessionDelegate <NSObject>

@required

/// Indicates that the broadcast state changed.
/// @param session The `IVSBroadcastSession` that just changed state
/// @param state current broadcast state
- (void)broadcastSession:(IVSBroadcastSession *)session
          didChangeState:(IVSBroadcastSessionState)state;

/// Indicates that an error occurred. Errors may or may not be fatal and will be marked as such
/// with the `IVSBroadcastErrorIsFatalKey` in the `userInfo` property of the error.
///
/// @note In the case of a fatal error the broadcast session moves into disconnected state.
///
/// @param session The `IVSBroadcastSession` that just emitted the error.
/// @param error error emitted by the SDK.
- (void)broadcastSession:(IVSBroadcastSession *)session
            didEmitError:(NSError *)error;

@optional

/// Indicates that a device has become available.
///
/// @note In the case of audio devices, it is possible the system has automatically rerouted audio to this device.
/// You can check `listAttachedDevices` to see if the attached audio devices have changed.
///
/// @param session The `IVSBroadcastSession` that added the device
/// @param descriptor the device's descriptor
- (void)broadcastSession:(IVSBroadcastSession *)session
            didAddDevice:(IVSDeviceDescriptor *)descriptor;

/// Indicates that a device has become unavailable.
///
/// @note In the case of audio devices, it is possible the system has automatically rerouted audio from this device
/// to another device. You can check `listAttachedDevices` to see if the attached audio devices have changed.
///
/// It is possible that this will not be called if a device that is not in use gets disconnected. For example, if you have
/// attached the built-in microphone to the broadcast session, but also have a bluetooth microphone paired with the device,
/// this may not be called if the bluetooth device disconnects. Anything impacting an attached device will result in this being called however.
///
/// @param session The `IVSBroadcastSession` that removed the device
/// @param descriptor the device's descriptor. This may not contain specific hardware information other than IDs.
- (void)broadcastSession:(IVSBroadcastSession *)session
         didRemoveDevice:(IVSDeviceDescriptor *)descriptor;

/// Periodically called with audio peak and rms in dBFS. Range is -100 (silent) to 0.
/// @param session The `IVSBroadcastSession` associated with the audio stats.
/// @param peak Audio Peak over the time period
/// @param rms Audio RMS over the time period
- (void)broadcastSession:(IVSBroadcastSession *)session
audioStatsUpdatedWithPeak:(double)peak
                     rms:(double)rms;

/// A number between 0 and 1 that represents the qualty of the stream based on bitrate minimum and maximum provided
/// on session configuration. 0 means the stream is at the lowest possible quality, or streaming is not possible at all.
/// 1 means the bitrate is near the maximum allowed.
///
/// @discussion If the video configuration looks like:
/// initial bitrate = 1000 kbps
/// minimum bitrate = 300 kbps
/// maximum bitrate = 5,000 kbps
///
/// It will be expected that a low quality is provided to this callback initially, since the initial bitrate is much closer to the minimum
/// allowed bitrate than the maximum. If network conditions are good the quality should improve over time towards the allowed maximum.
///
/// @param session The `IVSBroadcastSession` associated with the quality change.
/// @param quality The quality of the stream
- (void)broadcastSession:(IVSBroadcastSession *)session
 broadcastQualityChanged:(double)quality;

/// A number between 0 and 1 that represents the current health of the network. 0 means the network is struggling to keep up and the broadcast
/// may be experiencing latency spikes. The SDK may also reduce the quality of the broadcast on low values in order to keep it stable, depending
/// on the minimum allowed bitrate in the broadcast configuration. A value of 1 means the network is easily able to keep up with the current demand
/// and the SDK will be trying to increase the broadcast quality over time, depending on the maximum allowed bitrate.
///
/// Lower values like 0.5 are not necessarily bad, it just means the network is being saturated, but it is still able to keep up.
///
/// @param session The `IVSBroadcastSession` that associated with the quality change.
/// @param health The instantaneous health of the network
- (void)broadcastSession:(IVSBroadcastSession *)session
 networkHealthChanged:(double)health;

@end

NS_ASSUME_NONNULL_END

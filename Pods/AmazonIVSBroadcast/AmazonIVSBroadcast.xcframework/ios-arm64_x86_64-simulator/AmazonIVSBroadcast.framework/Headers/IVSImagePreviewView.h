//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MTKView.h>

NS_ASSUME_NONNULL_BEGIN

/// A view that will auto update its contents with a live preview of either an `IVSImageDevice`, or the
/// composited output image of the broadcast session.
@interface IVSImagePreviewView : MTKView

/// Set the preview mirroring state. For front cameras the default is on, for everything else the default is off.
/// @param mirrored Should the image in the preview be horizontally mirrored?
- (void)setMirrored:(BOOL)mirrored;

@end

NS_ASSUME_NONNULL_END

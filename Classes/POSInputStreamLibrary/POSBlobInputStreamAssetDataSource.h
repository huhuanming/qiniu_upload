//
//  POSBlobInputStreamAssetDataSource.h
//  POSInputStreamLibrary
//
//  Created by Pavel Osipov on 16.07.13.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSBlobInputStreamDataSource.h"
#import <AssetsLibrary/AssetsLibrary.h>

/// These are the only types of errors which raises POSBlobInputStreamAssetDataSource.
typedef NS_ENUM(NSInteger, POSBlobInputStreamAssetDataSourceErrorCode) {
    POSBlobInputStreamAssetDataSourceErrorCodeOpen = 0,
    POSBlobInputStreamAssetDataSourceErrorCodeRead = 1
};

/// Data source for streaming ALAsset from AssetsLibrary.
@interface POSBlobInputStreamAssetDataSource : NSObject <POSBlobInputStreamDataSource>
/*!
    @brief Indicates that the stream should block calling thread until opening
           will not complete.
 
    @discussion This flag should be YES for streams which are used in NSURLRequest
                or some other synchronous client's code. The only limitation of
                sync mode is that you can not use it while working with a stream
                in the main thread.
 */
@property (nonatomic, assign, getter = shouldOpenSynchronously) BOOL openSynchronously;

/*!
    @brief Value within [0, 1] range which determines compression quality for
           adjusted JPEGs. The default value is 0.93.
 
    @discussion Adjustment filters on iOS7 applied by data source manually using
                hardware acceleration. After applying them on JPEG images
                UIImageJPEGRepresentation function will be used to get raw bytes
                for resulted UIImage. The value of that property will be bypassed
                to it as a second argument.
 */
@property (nonatomic, assign) CGFloat adjustedJPEGCompressionQuality;

/*!
    @brief The suspicious size of assets to detect adjusted photos in iOS 8 gallery.
           The default value is 1M.
 
    @discussion System Camera app has a strange behaviour on iOS 8. If you turn ON
                built-in filters and make a photo with them, then metadata of that
                photo will not have adjustent XML. At the same time the size of the
                asset will be something about 150-300K instead of usual 1.5-3M. This
                property is used for detecting that kind of adjusted images on iOS 8.
                If asset is smaller than adjustedImageMaximumSize value then iOS 8
                Photos framework will be used for reading asset's data. The drawback
                is the app will consume much more RAM, because instead of streaming
                asset directly from ALAssetsLibrary it will allocate RAM for the whole
                UIImage at once.
 
    @remarks See comments in POSAdjustedAssetReaderIOS8.h for more info.
 */
@property (nonatomic, assign) long long adjustedImageMaximumSize;

/*!
    @brief Dispatch queue for fetching ALAsset from ALAssetsLibrary.

    @discussion By default when stream is opened, current dispatch queue is locked and
                ALAsset is retrieved on main dispatch queue. AFNetworking also uses
                main dispatch queue to open NSInputStream so we cannot use it.
 */
@property (nonatomic, strong) dispatch_queue_t openDispatchQueue;

/// The designated initializer.
- (instancetype)initWithAssetURL:(NSURL *)assetURL;

/// Shared queue for fetching ALAssets from ALAssetsLibrary.
+ (dispatch_queue_t)sharedOpenDispatchQueue;

@end

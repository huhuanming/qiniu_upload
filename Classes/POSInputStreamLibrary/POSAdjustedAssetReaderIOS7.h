//
//  POSAdjustedAssetReaderIOS7.h
//  POSInputStreamLibrary
//
//  Created by Pavel Osipov on 12.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSAssetReader.h"

@interface POSAdjustedAssetReaderIOS7 : NSObject <POSAssetReader>

@property (nonatomic, assign) CGFloat JPEGCompressionQuality;

/*!
    @brief Dispatch queue for fetching ALAsset from ALAssetsLibrary.
    @remarks See POSBlobInputStreamAssetDataSource.h
 */
@property (nonatomic, strong) dispatch_queue_t completionDispatchQueue;

@end

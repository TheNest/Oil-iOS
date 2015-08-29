//
// Created by Marcel Bradea on 2015-08-29.
// Copyright (c) 2015 Happ. All rights reserved.
//

import Bolts


public class RemoteOperation<TResult> {

	//
	// PRAG: properties
	//

	var remoteDataTask:BFTask!/*<TResult>*/


	//
	// PRAG: operations
	//

	public init(remoteData:BFTask/*<TResult>*/) {
		self.remoteDataTask = remoteData
	}

}

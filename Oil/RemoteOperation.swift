//
// Created by Marcel Bradea on 2015-08-29.
// Copyright (c) 2015 Happ. All rights reserved.
//

import Foundation
import Bolts


// TODO(arch): Create a base DomainOperation class/protocol which this extends
public class RemoteOperation<TResult> {

	//
	// PRAG: properties
	//

	private var _fetchRemoteDataTask:BFTask!/*<TResult>*/
	private var _asyncIndicatorsActivateCallback: (() -> ())!
	private var _asyncIndicatorsDeactivateCallback: (() -> ())!
	private var _hydrateViewSuccessCallback: ((TResult) -> ())!
	private var _hydrateViewErrorCallback: ((NSError) -> ())!
	private var _asyncIndicationWasProvided = false
	private var _viewHydrationWasProvided = false


	//
	// PRAG: operations
	//

	public init(_ fetchRemoteData:BFTask/*<TResult>*/) {
		_fetchRemoteDataTask = fetchRemoteData
	}


	public func hydrateView(
		success success: (TResult) -> () = { (result) in /*do nothing*/ },
		error: (NSError) -> () = { (error) in /*do nothing*/ }
	) -> RemoteOperation<TResult> {
		_hydrateViewSuccessCallback = success
		_hydrateViewErrorCallback = error

		return self
	}


	public func asyncIndicators(
		activate activate: () -> () = { /*do nothing*/ },
		deactivate: () -> () = { /*do nothing*/ }
//		activateSecondary: (() -> Unit)? = null,
//		deactivateSecondary: (() -> Unit)? = null
	) -> RemoteOperation<TResult> {
		_asyncIndicatorsActivateCallback = activate
		_asyncIndicatorsDeactivateCallback = deactivate
//		_asyncIndicatorsActivateSecondaryCallback = activateSecondary
//		_asyncIndicatorsDeactivateSecondaryCallback = deactivateSecondary
		_asyncIndicationWasProvided = true

		return self
	}


	public func perform() -> BFTask/*<TResult>*/ {
		// TODO: activate this in Swift 2.0 when error throwing is standardized
//		// ensure everything required was specified
//		if (!_asyncIndicationWasSpecified)
//			throw IllegalStateException("Async indication was not provided. Please specify .asyncIndicators(..).")
//		if (!_viewHydrationWasSpecified)
//			throw IllegalStateException("View hydration was not provided. Please specify .hydrateView(..).")

		// activate async indicators
		BFTask(result: true) // NOTE: perform UI work on on main thread
			.continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { _ in
				self._asyncIndicatorsActivateCallback()

				return nil
			})

		// fetch remote data
		let fetchRemoteDataTask:BFTask/*<TResult>*/ = _fetchRemoteDataTask
			.continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { task in
				// deactivate async indicators
				self._asyncIndicatorsDeactivateCallback()
//				if (_asyncIndicatorsDeactivateSecondaryCallback != nill) {
//					_asyncIndicatorsDeactivateSecondaryCallback!!()
//				}

				// hydrate view
				if task.faulted {
					self._hydrateViewErrorCallback(task.error)
				} else {
//					remoteDataSucceeded = true
					self._hydrateViewSuccessCallback(task.result as! TResult)
				}

				return task.result
			})

		return fetchRemoteDataTask
	}

}

//
//  CallDirectoryHandler.swift
//  CallKitTutorialExtension
//
//  Created by Paul Wilkinson on 14/3/19.
//  Copyright © 2019 Paul Wilkinson. All rights reserved.
//

import Foundation
import CallKit
import CallerData
import CoreData

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    private let callerData = CallerData()
    
    private func callers(blocked: Bool, includeRemoved: Bool = false, since date: Date? = nil) throws -> [Caller]  {
        let fetchRequest:NSFetchRequest<Caller> = self.callerData.fetchRequest(blocked: blocked, includeRemoved: includeRemoved, since: date)
        let callers = try self.callerData.context.fetch(fetchRequest)
        return callers
    }
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        let defaults = UserDefaults.standard
        
        if let lastUpdate = defaults.object(forKey: "lastUpdate") as? Date, context.isIncremental {
            addOrRemoveIncrementalBlockingPhoneNumbers(to: context, since: lastUpdate)
            
            addOrRemoveIncrementalIdentificationPhoneNumbers(to: context, since: lastUpdate)
        } else {
            addAllBlockingPhoneNumbers(to: context)
            
            addAllIdentificationPhoneNumbers(to: context)
        }
        
        defaults.set(Date(), forKey:"lastUpdate")
        
        context.completeRequest()
    }
    
    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        if let callers = try? self.callers(blocked: true) {
            for caller in callers {
                context.addBlockingEntry(withNextSequentialPhoneNumber: caller.number)
            }
        }
    }
    
    
    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext, since date: Date) {
        if let callers = try? self.callers(blocked: true, includeRemoved: true, since: date) {
            for caller in callers {
                if caller.isRemoved {
                    context.removeBlockingEntry(withPhoneNumber: caller.number)
                } else {
                    context.addBlockingEntry(withNextSequentialPhoneNumber: caller.number)
                }
            }
        }
    }
    
    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        if let callers = try? self.callers(blocked: false) {
            for caller in callers {
                if let name = caller.name {
                    context.addIdentificationEntry(withNextSequentialPhoneNumber: caller.number, label: name)
                }
            }
        }
    }
    
    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext, since date: Date) {
        if let callers = try? self.callers(blocked: false, includeRemoved: true, since: date) {
            for caller in callers {
                if caller.isRemoved {
                    context.removeIdentificationEntry(withPhoneNumber: caller.number)
                } else {
                    if let name = caller.name {
                        context.addIdentificationEntry(withNextSequentialPhoneNumber: caller.number, label: name)
                    }
                }
            }
        }
    }
    
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }
    
}

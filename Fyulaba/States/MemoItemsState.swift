//
//  MemoItemsState.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

enum MemoItemsState: StateType {
    case none
    case loading
    case list([MemoItem])
    case detail(MemoItem)
    case error(Error?)
}

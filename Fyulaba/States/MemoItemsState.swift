//
//  MemoItemsState.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

struct MemoItemsState: StateType {
    let items: [MemoItem]
    let selectedItem: MemoItem?
}

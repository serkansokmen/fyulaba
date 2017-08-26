//
//  MemoDetailState.swift
//  Fyulaba
//
//  Created by Etem Serkan Sökmen on 27/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

enum MemoDetailState: StateType {
    case loading
    case success(MemoItem)
    case error(Error?)
}

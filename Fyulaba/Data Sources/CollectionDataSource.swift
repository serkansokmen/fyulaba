//
//  CollectionDataSource.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//


import UIKit

final class CollectionDataSource<V, T>: NSObject, UICollectionViewDataSource where V: UICollectionViewCell {
  
  typealias CellConfiguration = (V, T) -> V
  
  var models: [T]
  private let configureCell: CellConfiguration
  private let cellIdentifier: String
  
  init(cellIdentifier: String, models: [T], configureCell: @escaping CellConfiguration) {
    self.models = models
    self.cellIdentifier = cellIdentifier
    self.configureCell = configureCell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? V
    
    guard let currentCell = cell else {
      fatalError("Identifier or class not registered with this collection view")
    }
    
    let model = models[indexPath.row]

    return configureCell(currentCell, model)
  }
}

//
//  ItemStore.swift
//  Homepwner
//
//  Created by Andy Wong on 10/30/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ItemStore {
    var allItems = [Item]()

    func createItem() -> Item {
        let newItem = Item(random: true)

        allItems.append(newItem)

        return newItem
    }

    func removeItem(_ item: Item) {
        if let index = allItems.index(of: item) {
            allItems.remove(at: index)
        }
    }

    func moveItemAtIndex(_ fromIndex: Int, toIndex: Int) {
        if fromIndex == toIndex {
            return
        }

        let movedItem = allItems[fromIndex]
        allItems.remove(at: fromIndex)
        allItems.insert(movedItem, at: toIndex)
    }
}

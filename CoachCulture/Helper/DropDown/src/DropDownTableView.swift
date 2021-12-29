//
//  DropDownTableView.swift
//  GoTOURNEYApp
//
//  Created by Krupa Detroja on 11/12/19.
//  Copyright © 2019 Krupa Detroja. All rights reserved.
//

import UIKit

// MARK: - UITableView
extension DropDown {

    /** Reloads all the cells.
    It should not be necessary in most cases because each change to
    `dataSource`,`textColor`,`textFont`,`selectionBackgroundColor`
    and `cellConfiguration` implicitly calls `reloadAllComponents()`. */
    public func reloadAllComponents() {
        tableView.reloadData()
        setNeedsUpdateConstraints()
    }

    /// (Pre)selects a row at a certain index.
    public func selectRow(at index: Index?) {
        if let index = index {
            tableView.selectRow(
                at: IndexPath(row: index, section: 0),
                animated: false,
                scrollPosition: .middle)
        } else {
            deselectRow(at: selectedRowIndex)
        }
        selectedRowIndex = index
    }

    public func deselectRow(at index: Index?) {
        selectedRowIndex = nil
        guard let index = index, index >= 0 else { return }
        tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
    }

    /// Returns the index of the selected row.
    public var indexForSelectedRow: Index? {
        return (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
    }

    /// Returns the selected item.
    public var selectedItem: String? {
        guard let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row else { return nil }
        return dataSource[row]
    }

    /// Returns the height needed to display all cells.
    var tableHeight: CGFloat {
        return tableView.rowHeight * CGFloat(dataSource.count)
    }

}

// MARK: - UITableViewDataSource - UITableViewDelegate
extension DropDown: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DPDConstant.ReusableIdentifier.DropDownCell, for: indexPath) as? DropDownCell else {
            return UITableViewCell()
        }
        let index = (indexPath as NSIndexPath).row
        configureCell(cell, at: index)
        return cell
    }

    func configureCell(_ cell: DropDownCell, at index: Int) {
        if index >= 0 && index < localizationKeysDataSource.count {
            cell.accessibilityIdentifier = localizationKeysDataSource[index]
        }
        cell.optionLabel.textColor = textColor
        cell.optionLabel.font = textFont
        cell.selectedBackgroundColor = selectionBackgroundColor
        if let cellConfiguration = cellConfiguration {
            cell.optionLabel.text = cellConfiguration(index, dataSource[index])
        } else {
            cell.optionLabel.text = dataSource[index]
        }
        customCellConfiguration?(index, dataSource[index], cell)
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.isSelected = (indexPath as NSIndexPath).row == selectedRowIndex
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = (indexPath as NSIndexPath).row
        selectionAction?(selectedRowIndex!, dataSource[selectedRowIndex!])
        if anchorView as? UIBarButtonItem != nil {
            // DropDown's from UIBarButtonItem are menus so we deselect the selected menu right after selection
            deselectRow(at: selectedRowIndex)
        }
        hide()
    }
}

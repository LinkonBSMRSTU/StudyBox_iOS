//
//  PickerTableViewCell.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let pickerFrequencyNumbers = [1, 2, 3, 4, 5, 10, 15, 20, 30, 45, 60]
    let pickerFrequencyTypes = ["minuty", "godziny", "dni"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        adjustPickerValues()
        
        //In case user enables notifications but doesn't change the picker
        defaults.setObject(pickerFrequencyNumbers[pickerView.selectedRowInComponent(0)], forKey: Utils.NSUserDefaultsKeys.PickerFrequencyNumberKey)
        defaults.setObject(pickerFrequencyTypes[pickerView.selectedRowInComponent(1)], forKey: Utils.NSUserDefaultsKeys.PickerFrequencyTypeKey)
    }
    
    ///Scroll pickerView to data found in NSUserDefaults before it's shown
    func adjustPickerValues() {
        if let number = defaults.stringForKey(Utils.NSUserDefaultsKeys.PickerFrequencyNumberKey),
            type = defaults.stringForKey(Utils.NSUserDefaultsKeys.PickerFrequencyTypeKey)
        {
            if let number = Int(number) {
                if let indexOfNumber = pickerFrequencyNumbers.indexOf(Int(number)), indexOfType = pickerFrequencyTypes.indexOf(type) {
                    self.pickerView.selectRow(indexOfNumber, inComponent: 0, animated: false)
                    self.pickerView.selectRow(indexOfType, inComponent: 1, animated: false)
                }
            }
        } else {
            print("Error getting user defaults")
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return pickerFrequencyNumbers.count
        case 1: return pickerFrequencyTypes.count
        default: return 0
        }
    }
    
    //Set labels and fonts of picker view
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        switch component {
        case 0: pickerLabel.text = String(pickerFrequencyNumbers[row])
        case 1: pickerLabel.text = pickerFrequencyTypes[row]
        default: break
        }
        pickerLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    
    //Handle selecting a new frequency interval
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch component {
        case 0: defaults.setObject(pickerFrequencyNumbers[row], forKey: Utils.NSUserDefaultsKeys.PickerFrequencyNumberKey)
        case 1: defaults.setObject(pickerFrequencyTypes[row], forKey: Utils.NSUserDefaultsKeys.PickerFrequencyTypeKey)
        default: break
        }
    }
    
}

//
//  NBDatePicker.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/19.
//

import UIKit

import Then
import SnapKit
import RxSwift

protocol DatePickerDelegate: AnyObject {
    func pickerViewSelected(_ dataArray: [String])
}

class NBDatePicker: UIView {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let dateViewModel = DateViewModel()
    private lazy var selectedYear: String = ""
    private lazy var selectedMonth: String = ""
    private lazy var selectedDay: String = ""
    private lazy var selectedHour: String = ""
    private lazy var selectedMinute: String = ""
    private lazy var dayType: Int = 0 // 0일때 31일, 1일때 30일, 2일때 29일, 3일때 28일
    
    weak var delegate: DatePickerDelegate?
    
    // MARK: - UI Components
    
    private lazy var yearPickerView = UIPickerView()
    private lazy var monthPickerView = UIPickerView()
    private lazy var dayPickerView = UIPickerView()
    private lazy var hourPickerView = UIPickerView()
    private lazy var minutePickerView = UIPickerView()
    private var pickerViewList: [UIPickerView] {
        return [yearPickerView, monthPickerView, dayPickerView, hourPickerView, minutePickerView]
    }
    private let colonLabel = UILabel().then {
        $0.font = .nbFont(type: .body2SemiBold)
        $0.text = ":"
    }
    
    // MARK: - initalizer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setContraint()
        setPickerViewDelegate()
        removePickerViewBackgroundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setPickerViewDelegate() {
        pickerViewList.forEach { pickerView in
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    
    private func setContraint() {
        addSubviews(yearPickerView, monthPickerView, dayPickerView, hourPickerView, minutePickerView, colonLabel)
        
        yearPickerView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(95)
        }
        
        var previousPickerView = yearPickerView
        for pickerView in pickerViewList[1..<pickerViewList.count] {
            pickerView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalTo(previousPickerView.snp.trailing).offset(-15)
                $0.width.equalTo(65)
                $0.height.equalTo(95)
            }
            previousPickerView = pickerView
        }
        
        colonLabel.snp.makeConstraints {
            $0.leading.equalTo(hourPickerView.snp.trailing).offset(-8)
            $0.top.equalTo(36)
        }
    }
    
    private func removePickerViewBackgroundColor() {
        DispatchQueue.main.async { [self] in
            [yearPickerView, monthPickerView, dayPickerView, hourPickerView, minutePickerView]
                .forEach { picker in
                    picker.subviews[1].backgroundColor = .clear
                }
        }
    }
    
    private func setDayDate(with month: Month) {
        guard let day = Int(selectedDay) else { return }
        switch month {
        case .jan, .mar, .may, .july, .aug, .oct, .dec:
            // 1, 3, 5, 7, 8, 10, 12월은 31일.
            dayType = 0
        case .feb:
            // 2월은 윤년 여부에 따라 29일 혹은 28일
            // 31일 혹은 30일인 채로 당월로 바뀌었을 경우 selectedMonth 값을 2월의 마지막 날짜(29일 혹은 28일)로 업데이트 해주어야 함
            guard let year = Int(selectedYear) else { return }
            dayType = isLeapYear(year) ? 2 : 3
            if day == 31 || day == 30 {
                selectedDay = String("\(dateViewModel.dayList[dayType].last!)")
            }
        case .apr, .june, .sep, .nov:
            // 4, 6, 9, 11월은 30일
            // 31일인 채로 당월로 바뀌었을 경우 selectedMonth 값을 4, 6, 9, 11월의 마지막 날짜(30일)로 업데이트해주어야 함.
            guard let day = Int(selectedDay) else { return }
            dayType = 1
            if day == 31 {
                selectedDay = String("\(dateViewModel.dayList[dayType].last!)")
            }
        }
        dayPickerView.reloadComponent(0)
    }
    
    private func isLeapYear(_ year: Int) -> Bool {
        if year % 400 == 0 {
            return true
        } else if year % 100 != 0 && year % 4 == 0 {
            return true
        } else {
            return false
        }
    }
    
    func setMetaDataTime(dataArray: [String]) {
        yearPickerView.selectRow(Int(dataArray[0])! - 2000, inComponent: 0, animated: true)
        monthPickerView.selectRow(Int(dataArray[1])! - 1, inComponent: 0, animated: true)
        dayPickerView.selectRow(Int(dataArray[2])! - 1, inComponent: 0, animated: true)
        hourPickerView.selectRow(Int(dataArray[3])! - 1, inComponent: 0, animated: true)
        minutePickerView.selectRow(Int(dataArray[4])!, inComponent: 0, animated: true)
        
        selectedYear = dataArray[0]
        selectedMonth = dataArray[1]
        selectedDay = dataArray[2]
        selectedHour = dataArray[3]
        selectedMinute = dataArray[4]
        delegate?.pickerViewSelected([selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute])
    }
    
    func setCurrnetTime() {
        let date = AppDate()
        
        yearPickerView.selectRow(date.getYear() - 2000, inComponent: 0, animated: true)
        monthPickerView.selectRow(date.getMonth() - 1, inComponent: 0, animated: true)
        dayPickerView.selectRow(date.getDay() - 1, inComponent: 0, animated: true)
        hourPickerView.selectRow(date.getHour() - 1, inComponent: 0, animated: true)
        minutePickerView.selectRow(date.getMinute(), inComponent: 0, animated: true)
        
        selectedYear = date.getYearToString()
        selectedMonth = date.getMonthToString()
        selectedDay = date.getDayToString()
        selectedHour = date.getHourToString()
        selectedMinute = date.getMinuteToString()
        delegate?.pickerViewSelected([selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute])
    }
}

extension NBDatePicker: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case yearPickerView:
            guard let month = Int(selectedMonth) else { return }
            selectedYear = dateViewModel.yearList[row]
            setDayDate(with: Month.init(rawValue: month) ?? .jan)
        case monthPickerView:
            setDayDate(with: dateViewModel.monthList[row])
            selectedMonth = dateViewModel.monthList[row].toNumberMonth()
        case dayPickerView:
            selectedDay = dateViewModel.dayList[dayType][row].convertTo2Digit()
        case hourPickerView:
            selectedHour = dateViewModel.hourList[row].convertTo2Digit()
        case minutePickerView:
            selectedMinute = dateViewModel.minuteList[row].convertTo2Digit()
        default:
            return
        }
        delegate?.pickerViewSelected([selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .nbFont(type: .body2SemiBold)
        
        switch pickerView {
        case yearPickerView:
            label.text = dateViewModel.yearList[row]
        case monthPickerView:
            label.text = dateViewModel.monthList[row].toString()
        case dayPickerView:
            label.text = dateViewModel.dayList[dayType][row]
        case hourPickerView:
            label.text = dateViewModel.hourList[row]
        case minutePickerView:
            label.text = dateViewModel.minuteList[row]
        default:
            return label
        }
        
        label.textAlignment = .center
        return label
    }
    
}

extension NBDatePicker: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case yearPickerView:
            return dateViewModel.yearList.count
        case monthPickerView:
            return dateViewModel.monthList.count
        case dayPickerView:
            return dateViewModel.dayList[dayType].count
        case hourPickerView:
            return dateViewModel.hourList.count
        case minutePickerView:
            return dateViewModel.minuteList.count
        default:
            return 0
        }
    }
    
}

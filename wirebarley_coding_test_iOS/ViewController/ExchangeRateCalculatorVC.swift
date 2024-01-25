//
//  ExchangeRateCalculatorVC.swift
//  wirebarley_coding_test_iOS
//
//  Created by 장예지 on 1/24/24.
//

import UIKit

class ExchangeRateCalculatorVC: UIViewController {
    
//MARK: Outlets
    @IBOutlet weak var txtFieldRemittanceAmount: UITextField!{
        didSet{
            txtFieldRemittanceAmount.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var lblAmountError: UILabel!
    @IBOutlet weak var pickerViewCountryCurrency: UIPickerView!{
        didSet{
            pickerViewCountryCurrency.delegate = self
            pickerViewCountryCurrency.dataSource = self
        }
    }
    @IBOutlet weak var lblReceivingCountry: UILabel!
    @IBOutlet weak var lblExchangeRate: UILabel!
    @IBOutlet weak var lblInquiryTime: UILabel!
    @IBOutlet weak var lblReceivedAmount: UILabel!
    
//MARK: Properties
    private var timeStamp: Int?
    private var previousText: String?
    private var baseUrl = "http://apilayer.net/api/live?access_key="
    private var key = "fdac052be36e7e0cb1e9c00c16b99139"
    
    private var selectedCurrency: CountryCurrency?
    private var exchangeRate: Double? {
        didSet{
            calculateReceivedAmount()
        }
    }
    private var correctRemittanceAmount: Bool = false {
        didSet{
            updateUIForRemittanceAmountValidation()
        }
    }

//MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFieldRemittanceAmount.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        selectedCurrency = CountryCurrency.allCases.first
        fetchData()
        clearUI()
    }
    
    private func clearUI(){
        lblReceivingCountry.text = " "
        lblExchangeRate.text = " "
        lblInquiryTime.text = " "
        lblReceivedAmount.text = " "
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        validateAmount(text: textField.text)
    }
    
    private func validateAmount(text: String?){
        if let text = text, let amount = Int(text) {
            correctRemittanceAmount = (amount > 0 && amount <= 10000)
        } else {
            correctRemittanceAmount = false
        }
    }
    
    private func updateUIForRemittanceAmountValidation() {
       lblAmountError.isHidden = correctRemittanceAmount
       lblReceivedAmount.isHidden = !correctRemittanceAmount
       if correctRemittanceAmount {
           calculateReceivedAmount()
       }
   }

    private func fetchData(){
        
        if let url = URL(string:baseUrl + key){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                let decoder = JSONDecoder()
                do{
                    let currencyData = try decoder.decode(CurrencyData.self, from: data)
                    var newExchangeRate: Double?
                    switch self.selectedCurrency {
                    case .KRW:
                        newExchangeRate = currencyData.quotes["USDKRW"]!
                    case .JPY:
                        newExchangeRate = currencyData.quotes["USDJPY"]!
                    case .PHP:
                        newExchangeRate = currencyData.quotes["USDPHP"]!
                    case .none:
                        newExchangeRate = nil
                    }
                    
                    DispatchQueue.main.async{
                        self.exchangeRate = newExchangeRate
                        self.timeStamp = currencyData.timestamp
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    private func calculateReceivedAmount(){
        if correctRemittanceAmount {
            if let exchangeRate = exchangeRate, let remittanceAmount = Double(txtFieldRemittanceAmount.text!) {
                let receivedAmount = exchangeRate * remittanceAmount
                
                DispatchQueue.main.async{
                    if let receivedAmount = self.setNumberFormat(receivedAmount), let currency = self.selectedCurrency?.currency, let exchangeRate = self.setNumberFormat(exchangeRate) {
                        self.lblReceivedAmount.text = "수취금액은 \(receivedAmount) \(currency) 입니다."
                        self.lblReceivingCountry.text = self.selectedCurrency?.rawValue
                        self.convertTimeStamp()
                        self.lblExchangeRate.text = "\(exchangeRate) \(currency)"
                    }
                }
            }
        }
    }
    
    private func setNumberFormat(_ num: Double)->String?{
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: num)
    }
    
    private func convertTimeStamp(){
        if let timeStamp = timeStamp {
            let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            self.lblInquiryTime.text = dateFormatter.string(from: date)
        }
    }
}

extension ExchangeRateCalculatorVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CountryCurrency.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CountryCurrency.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = CountryCurrency.allCases[row]
        fetchData()
    }
    
}

# wirebarley_coding_test_iOS

# 환율 계산 구현

## 개발환경

---

1. UIKit 사용

2. 외부라이브러리 사용 금지

3. iOS Deployment Target : iOS 13.0

## 구현 결과

---

![구현결과](https://github.com/Yeji-Jang1210/wirebarley_coding_test_iOS/assets/62092491/37182b3a-bfaa-4b5d-b31e-8e3f4631b80b)


- 송금액을 입력한 후, PickerView의 통화를 변경하면 수취국가에 따른 수취금액이 변경됩니다.
- 바르지 않은 송금액을 입력했을 경우에는 수취금액을 표시하지 않도록 구현하였습니다.
- 환율과 수취금액은 소숫점 두자리수, 1000단위 콤마를 사용하였습니다.
- JSON으로 timestamp를 받아와 “yyyy-MM-dd HH:mm”의 날짜 형식으로 표시합니다.

## 주요 기능 설명

---

### API Service

API Service는 Base URL과 key의 조합으로 URL이 구성되며 URLSession과 Task를 사용해 JSON데이터를 받아옵니다.

- fetchData()

→ fetchData함수는 pickerView에 선택된 수취국가 통화가 변경되었을 경우 조회시간과 환율을 불러옵니다.

→ 열거형인 CountryCurrency를 구현하여 PickerView에 선택된 통화의 환율 정보를 가져오도록 구현하였습니다.

```swift
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
```

- validateAmount()

→ 올바른 송금액인지 검사하는 함수입니다. 올바른 송금액이 입력되었을 경우 correctRemittanceAmount의 값을 변경하여 “송금액이 바르지 않습니다” Label을 띄우거나, 올바른 경우 수취금액을 계산하는 함수를 실행합니다.

```swift
private func validateAmount(text: String?){
    if let text = text, let amount = Int(text) {
        correctRemittanceAmount = (amount > 0 && amount <= 10000)
    } else {
        correctRemittanceAmount = false
    }
}
```

- calculateReceivedAmount()

→ 송금액이 바른 경우 불러온 환율과 계산하여 UI를 변경합니다.

```swift
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
```

public with sharing class MakeCallout {
    private static final String RATES_URL = 'https://api.exchangeratesapi.io/';
   
    private static HttpResponse makeHTTPRequest(String ratesUrl) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ratesUrl);
        request.setMethod('GET');
        return http.send(request);
    }
   
    private static Log__c insertLogRecord(HttpResponse response) {
        Log__c logRates = new Log__c();
        logRates.Status_Code__c = String.valueOf(response.getStatusCode());
        logRates.Response_Body__c = (String)response.getBody();
        insert logRates;
        return logRates;
    }
    
    private static void insertExchangeRateRecords(String base, String[] allCurrencies, HttpResponse response, Log__c logRates) {
        
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        String base2 = String.valueOf(results.get('base'));
        Map<String, Object> rates2 = (Map<String, Object>)(results.get('rates'));
        List<Exchange_Rate__c> ratesObjects = new List<Exchange_Rate__c>();
        
        for (String key : rates2.keySet()) {
    		System.debug('key: ' + key);
            Map<String, Object> ratesAll = (Map<String, Object>)(rates2.get(key));
            Exchange_Rate__c recordRate = new Exchange_Rate__c();
            recordRate.Date__c = Date.valueOf(key);
            recordRate.Base_Currency__c = base;
            
            for (Integer i = 0; i < allCurrencies.size(); i++) {
                 String keyName = allCurrencies[i] + '__c';
                 recordRate.put(keyName,ratesAll.get(keyName));
        	}
            recordRate.Log__c = logRates.id;
            ratesObjects.add(recordRate);
		}
        
        //sort by date ratesObjects
        List<ExchangeRateWrapper> wrapperList = new List<ExchangeRateWrapper>();

        for(Exchange_Rate__c item : ratesObjects){
            wrapperList.add(new ExchangeRateWrapper(item));
        }

        wrapperList.sort();
        ratesObjects.clear();

        for(ExchangeRateWrapper wrapOb : wrapperList){
            ratesObjects.add(wrapOb.rate);
        }

        insert ratesObjects;
    }
   
    private static void insertExchangeRateRecord(String base, String[] allCurrencies, HttpResponse response, Log__c logRates) {
       
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        String base2 = String.valueOf(results.get('base'));
        String date2 = String.valueOf(results.get('date'));
        Map<String, Object> rates2 = (Map<String, Object>)(results.get('rates'));
       
        Exchange_Rate__c recordRate = new Exchange_Rate__c();
        recordRate.Date__c = Date.valueOf(date2);
        recordRate.Base_Currency__c = base;
       
        for (Integer i = 0; i < allCurrencies.size(); i++) {
             String keyName = allCurrencies[i] + '__c';
             recordRate.put(keyName,rates2.get(keyName));
        }
        recordRate.Log__c = logRates.id;
        insert recordRate;
       
    }
   
    @future(callout=true)
    public static void runExchangeSchedule() {

        List<Exchange_Rate__c> rates = [select id, Base_Currency__c from Exchange_Rate__c limit 2];
        String base = DefaultRateController.getRatesDefaultValue();
        String[] allCurrencies = (DefaultRateController.getRatesValues() + ' ' + base).split(' ');
       
        String latestRatesUrl = RATES_URL + 'latest?base=' + base;

        if (rates.size() == 0) {
           
            //сделать запрос на последнюю дату
           
            HttpResponse response = makeHTTPRequest(latestRatesUrl);

            if (response.getStatusCode() == 200) {
               
                //записать данные в бд
               
                Log__c logRates = insertLogRecord(response);
                insertExchangeRateRecord(base, allCurrencies, response, logRates);
               
            } else {
                Log__c logRates = insertLogRecord(response);
            }

        } else {
            Exchange_Rate__c lastRecord = [SELECT id, Date__c, CreatedDate from Exchange_Rate__c ORDER by CreatedDate desc limit 1];
            Date minDate = lastRecord.Date__c;
            DateTime dt = dateTime.now();
            String maxDate = dt.formatGmt('yyyy-MM-dd');
            String periodRatesUrl = RATES_URL + 'history?start_at=' + minDate + '&end_at=' + maxDate + '&base=' + base;
            HttpResponse response = makeHTTPRequest(periodRatesUrl);
           
        }
    }
}
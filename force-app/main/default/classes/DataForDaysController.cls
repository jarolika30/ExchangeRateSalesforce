public with sharing class DataForDaysController {
    @AuraEnabled(Cacheable = true)
    public static List<Exchange_Rate__c> getDataForDays(String startDate, String endDate) {
        Date dateEnd;
        Datetime sd = Date.valueOf(startDate);
        Date dateStart = sd.dateGMT();

        if (endDate != '') {
            Datetime ed = Date.valueOf(endDate);
            dateEnd = ed.dateGMT();
        } else {
            dateEnd = dateStart;
        }
        String allValues = '';
        allValues += DefaultRateController.getRatesValues();
        String[] currencies = allValues.split(' ');

        String strQuery = 'SELECT ';

        for (Integer i = 0; i < currencies.size(); i++) {
            strQuery += currencies[i] + '__c, ';
        }

        if (endDate != '' && startDate != '') {
            Date minDate = dateStart <= dateEnd ? dateStart : dateEnd;
            Date maxDate = dateEnd >= dateStart ? dateEnd : dateStart;
            dateStart = minDate;
            dateEnd = maxDate;
            strQuery = strQuery.trim() + ' Date__c FROM Exchange_Rate__c WHERE Date__c >= :dateStart AND Date__c <= :dateEnd';
        } else if (startDate != '') {
            strQuery = strQuery.trim() + ' Date__c FROM Exchange_Rate__c WHERE Date__c = :dateStart';
        } else {
            return null;
        }
        List<Exchange_Rate__c> ratesList = Database.query(strQuery);
        System.debug(ratesList);
        return ratesList;
    }
}
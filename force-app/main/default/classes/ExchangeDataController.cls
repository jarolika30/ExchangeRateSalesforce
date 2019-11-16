public with sharing class ExchangeDataController {
    @AuraEnabled(cacheable=true)
    public static  Exchange_Rate__c getLastdata() {
        String allValues = '';
        allValues += DefaultRateController.getRatesValues();
        String[] currencies = allValues.split(' ');
        String strQuery = 'SELECT ';
        for (Integer i = 0; i < currencies.size(); i++) {
            strQuery += currencies[i] + '__c, ';
        }
        strQuery = strQuery.trim() + ' Date__c FROM Exchange_Rate__c ORDER BY Date__c DESC LIMIT 1';
        Exchange_Rate__c result = Database.query(strQuery);
        System.debug(result);
        return result;
    }
}
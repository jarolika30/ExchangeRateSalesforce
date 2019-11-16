public with sharing class ExchangeRateWrapper implements Comparable {
    public Exchange_Rate__c rate = new Exchange_Rate__c();
    public ExchangeRateWrapper(Exchange_Rate__c rateOb) {
        rate = rateOb;
    }
    public Integer compareTo(Object compareTo) {
        ExchangeRateWrapper compareItems = (ExchangeRateWrapper) compareTo;
        Integer returnValue = 0;
        if (rate.Date__c > compareItems.rate.Date__c) {
                // Set return value to a positive value.
                returnValue = 1;
        } else if (rate.Date__c > compareItems.rate.Date__c) {
                // Set return value to a negative value.
                returnValue = -1;
        }
            
        return returnValue;      
    }
}
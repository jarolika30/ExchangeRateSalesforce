public with sharing class DefaultRateController {
    @AuraEnabled(Cacheable = true)
    public static String getRatesDefaultValue() {
        String defaultVal = '';
        Schema.DescribeFieldResult dfr = Exchange_Rate__c.Base_Currency__c.getDescribe();
        List<Schema.PicklistEntry> plist = dfr.getPickListValues();
        for (Schema.PicklistEntry item : plist) {
            if (item.isDefaultValue()) {
                defaultVal = item.getValue();
            }
        }
        return defaultVal;
    }

    @AuraEnabled(Cacheable = true)
    public static String getRatesValues() {
        String allValues = '';
        Schema.DescribeFieldResult dfr = Exchange_Rate__c.Base_Currency__c.getDescribe();
        List<Schema.PicklistEntry> plist = dfr.getPickListValues();
        for (Schema.PicklistEntry item : plist) {
            if (!item.isDefaultValue()) {
                allValues += ' ' + item.getValue();
            }
        }
        return allValues.trim();
    }
}
public with sharing class MakeField {
    @AuraEnabled(Cacheable = true)
    public static void addFieldToExchangeRate(String labelName) {
        List<MetadataService.CustomField> fields = new List<MetadataService.CustomField>();
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
        metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
        metadataservice.SessionHeader.sessionId = UserInfo.getSessionID();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Exchange_Rate__c.' + labelName + '__c';
        customField.label = labelName;
        customField.type_x = 'Currency';
	    customField.precision = 18;
	    customField.scale = 4;
        fields.add(customField);
        metadataservice.createMetadata(fields);
        //String MySessionID = UserInfo.getSessionID();
        //System.debug('MySessionID: ' + userID); 
    }
}
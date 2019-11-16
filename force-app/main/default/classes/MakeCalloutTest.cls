@isTest
public class MakeCalloutTest {
	@isTest
    static void testrunExchangeSchedule() {
        try {
            Test.setMock(HttpCalloutMock.class, new MakeCalloutMock());
            Test.startTest();
            MakeCallout.runExchangeSchedule();
            Test.stopTest();
        } catch (Exception error) {
            System.assert(null, error.getMessage());
            System.assertEquals(1, [SELECT count() FROM Exchange_Rate__c]);
        }
    }
}
public with sharing class ScheduleCalloutRates implements Schedulable {
    public void execute(SchedulableContext context){
        //call apex callout class
        System.debug('test');
        MakeCallout.runExchangeSchedule();
    }
}
public with sharing class CTPersonTriggerHandler
{
    //before Insert operation for Person__c Object
    public static void beforeInsert(List<Person__c> newRecords)
    {
        //make person's Health_Status Green
        //generate token of person based on their mobile
        for (Person__c person : newRecords)
        {
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    //before update operation for Person__c Object
    public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap)
    {
        for (Person__c person : newRecords)
        {
            if (person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c)
            {
                person.Status_Update_Date__c = Date.today();
            }
            
        }
    }
}
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

    public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap)
    {
        List<Person__c> personToUpdate = new List<Person__c>();

        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();

        for (Person__c person : newRecords)
        {
            if (person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c)
            {
                statusChange.add(person.Id);
                
            }

            if (person.Health_Status__c == 'Red' && oldRecordsMap.get(person.Id).Health_Status__c != 'Red')
            {
                redStatus.add(person.Id);
                
            } 
        }

            Set<Id> alreadyProcessed = new Set<Id>();

            Set<Id> orangeStatus = new Set<Id>();
            Set<Id> yellowStatus = new Set<Id>();

            //dml update query list
            // List<Id> personToUpdate = new List<Id>();

            //KEEPING THE HIERARCHY FOR ORANGE > YELLOW IS IMPORTANT - dupolaris

            //populate cohabitants for orange status
            orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));

            //populate primary contacts for orange status
            Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
            orangeStatus.addAll(primaryContacts);

            //populate neighbours for yellow status
            yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));

            //populate secondary contacts for yellow status
            yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));
            

            for (Id pid : orangeStatus)
            {
                // personToUpdate.add(new Person__c(Id=pid, Health_Status__c='Orange'));
                personToUpdate.add(new Person__c(Id=pid, Health_Status__c='Orange'));
            }

            for (Id pid : yellowStatus)
            {
                personToUpdate.add(new Person__c(Id=pid, Health_Status__c='Yellow'));
            }

            //Step 5
            List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByPersonIds(statusChange);

            if (locationTraces != null && locationTraces.size() > 0)
            {
                Set<Id> locationIds = new Set<Id>();
                for (Location_Tracing__c trace : locationTraces)
                {
                    locationIds.add(trace.Location__c);
                }
    
                CTLocationController.updateRedScore(locationIds);
    
            }

         //update Health Status colors for all
         if (personToUpdate.size() > 0)
         {
             update personToUpdate;
         }
        
    }
   
}
public with sharing class CTPeopleTracingController {

    /**
     * querying people
     * @return List<People_Tracing__c>
     */
    public static List<People_Tracing__c> getTraces(String PersonId){

        return [SELECT Id, Contact_Date__c, Person_1__c, Person_1__r.Health_Status__c, 
                    Person_1__r.Token__c, Person_2__r.Health_Status__c, Person_2__r.Token__c, Person_2__c 
                    FROM People_Tracing__c 
                    WHERE Person_1__c = :PersonId 
                    OR Person_2__c = : PersonId 
                    ORDER By Contact_Date__c DESC]; 
    }

    /**
     * checking duplicates - returns List of duplicates
     * @return List<People_Tracing__c>
     */
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){

        Set<Id> personId = new Set<Id>();

        for (People_Tracing__c trace : newPeopleTraces) {
            personId.add(trace.Person_1__c);
            personId.add(trace.Person_2__c);
        }

        //List of duplicate records
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();

        //map for duplicates
        Map<Id, Set<Id> > mapOfExistingRecords = new Map<Id, Set<Id>>();

        List<People_Tracing__c> existingRecords = [SELECT Id, Person_1__c , Person_2__c
                                                    FROM People_Tracing__c
                                                    WHERE Person_1__c IN :personId
                                                    OR Person_2__c IN: personId];

        if (existingRecords != null && existingRecords.size() > 0) {
            for (People_Tracing__c trace : existingRecords) {

                if (! mapOfExistingRecords.containsKey(trace.Person_1__c)) {
                    mapOfExistingRecords.put(trace.Person_1__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_1__c).add(trace.Person_2__c);

                //populate map for person 2
                if(! mapOfExistingRecords.containsKey(trace.Person_2__c)){
                    mapOfExistingRecords.put(trace.Person_2__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_2__c).add(trace.Person_1__c);
            }
            
            //find duplicates
            for (People_Tracing__c trace : newPeopleTraces) {
                //check for duplicates in map
                if ((mapOfExistingRecords.containsKey(trace.Person_1__c)) 
                        && (mapOfExistingRecords.get(trace.Person_1__c).contains(trace.Person_2__c))
                    || 
                    (mapOfExistingRecords.containsKey(trace.Person_2__c) 
                    && mapOfExistingRecords.get(trace.Person_2__c).contains(trace.Person_1__c))     
                   ) {
                    
                    duplicates.add(trace);
                }
            }

        }
        return duplicates;
    }
}
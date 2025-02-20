/**
 * CTLocationTracingController
 * Main Controller class for Location_Tracing__c object
 * @author Dawood
 */

public with sharing class CTLocationTracingController {


    /**
     * get People who visited a certain location by locationId
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getVisitors(String locationId){

        return [
            SELECT Id, Name, Person__c, Location__c, Person__r.Token__c, Person__r.Health_Status__c, Visit_Date__c 
                FROM Location_Tracing__c
                WHERE Id = :locationId
                ORDER BY Visit_Date__c DESC
            ];
    }

    /**
     * get Location by Person Id
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationByPersonIds(Set<Id> personIds){
        return [
            SELECT Id, Person__c, Location__c 
                FROM Location_Tracing__c
                WHERE Person__c IN :personIds
                AND Visit_Date__c = LAST_N_DAYS:10
            ];
    }

    /**
     * get Location by Location Id where Person's Health Status is green
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationByLocationIds(Set<Id> locationIds){
        return [
            SELECT Id, Person__c , Location__c
                FROM Location_Tracing__c
                WHERE Location__c IN :locationIds
                AND Person__r.Health_Status__c = 'Green'
                AND Visit_Date__c = LAST_N_DAYS:10
        ];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){
        //store unique person id
        Set<Id> personIds = new Set<Id>();
        //store unique location id
        Set<Id> locationIds = new Set<Id>();

        for (Location_Tracing__c trace : newLocationTraces) {
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        //Map of Location and Person Ids of existing records
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

        //query existing records based on location and person sets
        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c , Location__c
                                                        FROM Location_Tracing__c
                                                        WHERE Location__c IN :locationIds
                                                        AND Person__c IN :personIds];

        //List of duplicates
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        if(existingRecords != null && existingRecords.size() > 0){
             for (Location_Tracing__c trace : existingRecords) {
                if (! mapOfExistingRecords.containsKey(trace.Location__c)) {
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                //add person Ids to map set
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
                
             }
        

        //compare newLocationTraces with mapOfExistingRecords and return duplicates List
        for (Location_Tracing__c trace : newLocationTraces) {
            if (mapOfExistingRecords.containsKey(trace.Location__c) 
                    && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)) {
                        //populate the duplicates list with duplicate record
                        duplicates.add(trace);
            }
            
        }
    }
        return  duplicates;
     }

}
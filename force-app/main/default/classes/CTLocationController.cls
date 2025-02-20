/**
 * CTLocationController
 * Main Controller class for Location__c object
 * @author Dawood
 */

public with sharing class CTLocationController {

    /**
     * querying 100 locations with recent status changes
     * @return List<Location__c>
     */
    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c 
                ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /**
     * query Location based on Name or PinCode or Address
     * @return List<Location__c>
     */
    public static List<Location__c> searchLocations(String searchTerm){

        searchTerm = searchTerm + '%';

        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c 
                WHERE Name LIKE :searchTerm
                    OR Pincode__c LIKE :searchTerm
                    OR Address__c LIKE : searchTerm
                ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    /**
     * query a Location based on Id
     * @return Location__c
     */
    public static Location__c getLocationById(String locationId){
        List<Location__c> locations = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
        FROM Location__c 
        WHERE Name LIKE :locationId];

        if(locations != null && locations.size() > 0){
            return locations[0];
        }
        return null;
    }

    
    /**
     * Get count of location in each status
     * @return Map<string, Integer>
     */
    public static Map<String, Integer> getLocationStatusCount() {
        Map<String, Integer> StatusCountMap = new Map<String, Integer>();

        for(AggregateResult ar: [SELECT Status__c , COUNT(Id)total 
                                                    FROM Location__c 
                                                    GROUP BY status__c]){

            StatusCountMap.put(String.valueOf(ar.get('status__c')), Integer.valueOf(ar.get('total')));

        }
        return StatusCountMap;
    }
}
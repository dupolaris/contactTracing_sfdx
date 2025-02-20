public with sharing class CTPersonController {
    
    public static String getToken(String mobileNo){

        Blob value = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);

        //convert the hash into String value
        return EncodingUtil.base64Encode(hash);
    }

    /**
     * querying 100 contacts with recent health changes
     * @return List<Person__c>
     */
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /**
     * query person based on Name or mobile or token
     * @return List<Person__C>
     */
    public static List<Person__c> searchPeople(String searchTerm){

        searchTerm = searchTerm + '%';

        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
        FROM Person__c 
        WHERE Name LIKE :searchTerm 
            OR Mobile__c LIKE :searchTerm 
            OR Token__c LIKE :searchTerm 
        ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }

    /**
     * query a single person based on Id
     * @return Person__c
     */
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
        FROM Person__c 
        WHERE Id = :personId];

        if(people != null && people.size() > 0){
            return people[0];
        }
        return null;
    }

    /**
     * COUNT(Id)total >> here total is an expression to get() value of COUNT() >> ar.get(total)
     * get health status total count
     * @return Map<String , Integer>
     */
    public static Map<String, Integer> getHealthStatusCount() {
        Map<String, Integer> healthCountMap = new Map<String, Integer>();

     for(AggregateResult ar: [SELECT Health_Status__c , COUNT(Id)total
                                                        FROM Person__c 
                                                        GROUP BY Health_Status__c]){
        
        String healthStatus = String.valueOf(ar.get('Health_Status__c'));
        Integer healthStatusTotal = Integer.valueOf(ar.get('total'));

        healthCountMap.put(healthStatus, healthStatusTotal);

        }
        return healthCountMap;
    }
}
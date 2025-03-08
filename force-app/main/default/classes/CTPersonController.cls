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


    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed)
    {
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds)
                                                AND Contact_Type__c = 'Cohabitant'
                                                AND (Person_1__r.Health_Status__c IN:healthStatuses OR Person_2__r.Health_Status__c IN: healthStatuses)
                                                ];
        //store cohabitant Ids here
        Set<Id> cohabitants = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces)
        {
            if (!alreadyProcessed.contains(pt.Person_1__c))
            {
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if (!alreadyProcessed.contains(pt.Person_2__c))
            {
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
            
        }
        return cohabitants;
    }

    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed)
    {
        //List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds)
                                                AND Contact_Type__c = 'Neighbour'
                                                AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')
                                                ];
        //store neighbours Ids here
        Set<Id> neighbours = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces)
        {
            if (!alreadyProcessed.contains(pt.Person_1__c))
            {
                neighbours.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if (!alreadyProcessed.contains(pt.Person_2__c))
            {
                neighbours.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
            
        }
        return neighbours;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed)
    {
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds)
                                                AND Contact_Type__c = 'Other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c IN:healthStatuses OR Person_2__r.Health_Status__c IN: healthStatuses)
                                                ];
        //store primaryContacts Ids here
        Set<Id> primaryContacts = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces)
        {
            if (!alreadyProcessed.contains(pt.Person_1__c))
            {
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if (!alreadyProcessed.contains(pt.Person_2__c))
            {
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
            
        }
        return primaryContacts;
    }

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactsIds, Set<Id> alreadyProcessed)
    {
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN:primaryContactsIds OR Person_2__c IN:primaryContactsIds)
                                                AND Contact_Type__c = 'Other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c IN:healthStatuses OR Person_2__r.Health_Status__c IN: healthStatuses)
                                                ];
        //store secondaryContacts Ids here
        Set<Id> secondaryContacts = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces)
        {
            if (!alreadyProcessed.contains(pt.Person_1__c))
            {
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if (!alreadyProcessed.contains(pt.Person_2__c))
            {
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
            
        }
        return secondaryContacts;
    }
}
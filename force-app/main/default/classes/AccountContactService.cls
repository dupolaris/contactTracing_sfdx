public with sharing class AccountContactService {
    //update Active Contacts On Account
    public static void updateActiveContacts(Set<Id> uniqueAccountIds)
    {
        //get aggregate results of all accounts that should be updated
        List<AggregateResult> results =
        [
            SELECT AccountId, COUNT(Id) totalResults 
            FROM Contact 
            WHERE Active__c = true AND AccountId IN : uniqueAccountIds
            GROUP BY AccountId
        ];
    
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for (AggregateResult res : results)
        {
            Id currentAcc = (Id) res.get('AccountId');
            Integer numOfActiveContacts = (Integer) res.get('totalResults');
            //Account acc = new Account(Id=currentAcc, Active_Contacts__c=numOfActiveContacts);
            Account acc = new Account(Id = currentAcc, Active_Contacts__c = numOfActiveContacts);
            accountsToUpdate.put(currentAcc, acc);
        }
        //update accounts with 0 active contacts
        for (Id accId : uniqueAccountIds) {
            if (!accountsToUpdate.containsKey(accId)) {
                accountsToUpdate.put(accId, new Account(Id = accId, Active_Contacts__c = 0));
            }
            
        }


        if (!accountsToUpdate.isEmpty())
        {
            update accountsToUpdate.values();
        }
    }
}
public with sharing class ContactTriggerHandler {
   public static void afterInsertHandler(List<Contact> newContacts)
   {
        Set<Id> uniqueAccountIds = new Set<Id>();
                for (Contact con : newContacts)
                {
                    if(String.isNotBlank(con.AccountId))
                    {
                        uniqueAccountIds.add(con.AccountId);
                    }
                }
                AccountContactService.updateActiveContacts(uniqueAccountIds);

   }
   public static void afterUpdateHandler(List<Contact> newContacts , Map<Id, Contact> oldContactsMap)
   {
        Set<Id> uniqueAccountIds = new Set<Id>();
        for (Contact con : newContacts)
        {
            //capture the accountId only if, active check box value is flipped
            if(oldContactsMap.get(con.Id).Active__c != con.Active__c)
            {
                if(con.AccountId != null)
                {
                    uniqueAccountIds.add(con.AccountId);
                }
            }
            //capture the accountId only if, accountId value is flipped
            if (oldContactsMap.get(con.Id).AccountId != con.AccountId)
            {
                if(con.AccountId != null)
                {
                    uniqueAccountIds.add(con.AccountId);
                }
                if(oldContactsMap.get(con.Id).AccountId != null)
                {
                    uniqueAccountIds.add(oldContactsMap.get(con.Id).AccountId);
                }
            }   
        }
        AccountContactService.updateActiveContacts(uniqueAccountIds);
   }

   public static void afterDeleteHandler(List<Contact> oldContacts)
   {
        Set<Id> uniqueAccountIds = new Set<Id>();
        for(Contact con: oldContacts)
        {
            if (con.AccountId != null)
            {
                uniqueAccountIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(uniqueAccountIds);
   }

   public static void afterUndeleteHandler(List<Contact> newContacts)
   {
        Set<Id> uniqueAccountIds = new Set<Id>();
        for(Contact con: newContacts)
        {
            if(con.AccountId != null)
            {
                uniqueAccountIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(uniqueAccountIds);
   }
}
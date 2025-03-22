@isTest
public with sharing class contactTriggerHandlerTest {
    
    @isTest
    public static void afterInsertHandlerTest1()
    {
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name='testAcc1'));
        testAccounts.add(new Account(Name='testAcc2'));
        testAccounts.add(new Account(Name='testAcc3'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(LastName='testCon1', AccountId=testAccounts[0].Id));
        testContacts.add(new Contact(LastName='testCon2', AccountId=testAccounts[1].Id));
        testContacts.add(new Contact(LastName='testCon3', AccountId=testAccounts[2].Id));

        insert testContacts;

        //test number of acc and number of active contacts on each acc
        List<Account> accs = [SELECT Id, Active_Contacts__c FROM Account];
        System.assertEquals(3, accs.size());
        System.assertEquals(0, accs[0].Active_Contacts__c);
        System.assertEquals(0, accs[1].Active_Contacts__c);

        //test total contacts
        List<Contact> con = [SELECT Id FROM Contact];
        System.assertEquals(3, con.size());
    }

    @isTest
    public static void afterInsertHandlerTest2()
    {
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name='testAcc1'));
        testAccounts.add(new Account(Name='testAcc2'));
        testAccounts.add(new Account(Name='testAcc3'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(LastName='testCon1', AccountId=testAccounts[0].Id, Active__c = true));
        testContacts.add(new Contact(LastName='testCon2', AccountId=testAccounts[1].Id, Active__c = true));
        testContacts.add(new Contact(LastName='testCon21', AccountId=testAccounts[1].Id, Active__c = true));
        testContacts.add(new Contact(LastName='testCon3', AccountId=testAccounts[2].Id));

        insert testContacts;

        //test number of acc and number of active contacts on each acc
        List<Account> allTestAccounts = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(3, allTestAccounts.size());

        for (Account acc : allTestAccounts)
        {
            if (acc.Name == 'testAcc1')
            {
                System.assertEquals(1, acc.Active_Contacts__c);
            }
            if (acc.Name == 'testAcc2')
            {
                System.assertEquals(2, acc.Active_Contacts__c);
            }
            if (acc.Name == 'testAcc3')
            {
                System.assertEquals(0, acc.Active_Contacts__c);
            }
        }
        
        //test total contacts
        List<Contact> con = [SELECT Id FROM Contact];
        System.assertEquals(4, con.size());
    }
}
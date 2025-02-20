trigger CTPersonTrigger on Person__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{

    
    switch on Trigger.operationType 
    {
        when BEFORE_INSERT
        {
            //keep health_status Green for all new users
            //generate token for all new users based on their mobile numbers
            CTPersonTriggerHandler.beforeInsert(Trigger.new);
        }

        when BEFORE_UPDATE
        {
            CTPersonTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
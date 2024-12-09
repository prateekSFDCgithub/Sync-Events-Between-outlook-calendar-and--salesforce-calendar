trigger PostEventsToOutlookTrigger on Event (after insert,after update, after delete) {
 
   if (Trigger.isInsert || Trigger.isUpdate) {
    for (Event eventRecord : Trigger.new) {
        List<String> attendeesEmails = new List<String>();
 
        // Query EventRelation to fetch attendees' relation IDs
      //  List<EventRelation> eventAttendees = [SELECT RelationId FROM EventRelation WHERE EventId = :eventRecord.Id];
 
        
      // Skip unnecessary updates
       if (Trigger.isUpdate && !hasRelevantChanges(eventRecord)) {
            continue;
        }
       /* for (EventRelation attendee : eventAttendees) {
            if (attendee.RelationId != null) {
                relationIds.add(attendee.RelationId);
            }
        }*/
 
        // Fetch Contacts
        List<Account> AccList = [SELECT PersonEmail FROM Account WHERE Id =:eventRecord.whatId];
        for (Account Acc : AccList) {
            if (Acc.PersonEmail != null) {
                attendeesEmails.add(Acc.PersonEmail);
            }
        }
 
        // Fetch Leads
       /* List<Lead> leads = [SELECT Email FROM Lead WHERE Id IN :relationIds];
        for (Lead lead : leads) {
            if (lead.Email != null) {
                attendeesEmails.add(lead.Email);
            }
        }*/
 
        // Fetch Users
      /*  List<User> users = [SELECT Email FROM User WHERE Id IN :relationIds];
        for (User user : users) {
            if (user.Email != null) {
                attendeesEmails.add(user.Email);
            }
        }*/
 
        // Call the future method if there are attendees
      if (!attendeesEmails.isEmpty()) {
          if (Trigger.isInsert) {
              System.debug('Inserted eventRecord' +eventRecord);
              System.debug('Updated eventRecord OutLookEventId__c ' +eventRecord.OutLookEventId__c);
              PostEventsToOutlook.postEventMethod(
                  eventRecord.Id,
                  eventRecord.Subject,
                  eventRecord.StartDateTime,
                  eventRecord.EndDateTime,
                  attendeesEmails,
                  // eventRecord.In_Person_Virtual_Meeting__c,  // Meeting mode
                  eventRecord.Description,  // Description
                  eventRecord.Type,  // Event type
                  eventRecord.Location  // Location
              );
          }else if (Trigger.isUpdate) {
              System.debug('Updated eventRecord' +eventRecord);
              System.debug('Updated eventRecord OutLookEventId__c' +eventRecord.OutLookEventId__c);
              PostEventsToOutlook.updateEventInOutlook(
                  eventRecord.OutLookEventId__c,
                  eventRecord.Subject,
                  eventRecord.StartDateTime,
                  eventRecord.EndDateTime,
                  attendeesEmails,
                  eventRecord.Description,
                  eventRecord.Type,
                  eventRecord.Location
              );
          }
      }
    }
   }
    
    // Helper method to check for relevant field changes
    private Boolean hasRelevantChanges(Event eventRecord) {
        Event oldRecord = Trigger.oldMap.get(eventRecord.Id);
        
        return oldRecord.Subject != eventRecord.Subject ||
            oldRecord.StartDateTime != eventRecord.StartDateTime ||
            oldRecord.EndDateTime != eventRecord.EndDateTime ||
            oldRecord.Description != eventRecord.Description ||
            oldRecord.Type != eventRecord.Type ||
            oldRecord.Location != eventRecord.Location;
    }
    
    //Handle delete event -----
    if(Trigger.isDelete){
        for(Event deletedEvent: Trigger.old){
            if(deletedEvent.OutLookEventId__c != null){
                System.debug('Deleting Event in Outlook with ID: ' + deletedEvent.OutLookEventId__c);
                PostEventsToOutlook.deleteEventInOutlook(deletedEvent.OutLookEventId__c);
            }else {
                System.debug('OutLookEventId__c is null for Event ID: ' + deletedEvent);
            }
        }
    }
    
    
}
public class PostEventsToOutlook {
    @future(callout=true)
    public static void postEventMethod(
        Id salesforceEventId,
        String subject, 
        DateTime startDate, 
        DateTime endDate, 
        List<String> attendeesEmails,
        //String meetingMode,   // Meeting mode, possibly with a link
        String description,   // Event description
        String eventType,     // Event type (Picklist field)
        String location       // Event location
    ) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:OutlookINtegrationthe401kadvisorlineNamed2/v1.0/me/calendar/events');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            // Debugging request details for traceability
            System.debug('Subject: ' + subject);
            System.debug('Start Date: ' + startDate);
            System.debug('End Date: ' + endDate);
            System.debug('Attendees: ' + attendeesEmails);
            // System.debug('Meeting Mode: ' + meetingMode); 
            System.debug('Description: ' + description);  
            System.debug('Event Type: ' + eventType);     
            System.debug('Location: ' + location);        
            // Create the attendees list dynamically
            List<Object> attendeesList = new List<Object>();
            for (String email : attendeesEmails) {
                Map<String, Object> attendee = new Map<String, Object>();
                Map<String, Object> emailAddress = new Map<String, Object>();
                emailAddress.put('address', email);
                attendee.put('emailAddress', emailAddress);
                attendee.put('type', 'required');
                attendeesList.add(attendee);
            }
            // Build the request body as a Map for JSON serialization
            Map<String, Object> requestBodyMap = new Map<String, Object>();
            requestBodyMap.put('subject', subject);
            // RSVP settings
            requestBodyMap.put('responseRequested', true);
            requestBodyMap.put('allowNewTimeProposals', true);
            // Handle null values and replace them with empty strings if needed
            //  String safeMeetingMode = meetingMode != null ? meetingMode : '';
            String safeDescription = description != null ? description : '';
            String safeEventType = eventType != null ? eventType : '';
            // Format meeting mode as an HTML hyperlink if it's a valid link
            /*  String meetingModeFormatted = safeMeetingMode;
if (safeMeetingMode.startsWith('http')) {
meetingModeFormatted = '<a href="' + safeMeetingMode + '">Join Meeting</a>';
}*/
            // Add the body content, including meeting mode, description, and type
            Map<String, Object> bodyContent = new Map<String, Object>();
            bodyContent.put('contentType', 'HTML');
            bodyContent.put('content', 'Meeting details: ' + safeDescription + '<br>Event Type: ' + safeEventType /*'<br>Meeting Mode: ' + meetingModeFormatted +*/ );
            requestBodyMap.put('body', bodyContent);
            // Add start date and time
            Map<String, Object> start = new Map<String, Object>();
            start.put('dateTime', startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            start.put('timeZone', 'UTC');
            requestBodyMap.put('start', start);
            // Add end date and time
            Map<String, Object> endDateTime = new Map<String, Object>();
            endDateTime.put('dateTime', endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            endDateTime.put('timeZone', 'UTC');
            requestBodyMap.put('end', endDateTime);
            // Add location
            Map<String, Object> locationMap = new Map<String, Object>();
            locationMap.put('displayName', location != null ? location : '');  // Handle null location
            requestBodyMap.put('location', locationMap);
            // Add attendees
            requestBodyMap.put('attendees', attendeesList);
            // Serialize the request body to JSON
            String requestBody = JSON.serialize(requestBodyMap);
            req.setBody(requestBody);
            // Debugging the final request body
            System.debug('Request Body: ' + requestBody);
            // HTTP callout
            Http http = new Http();
            HttpResponse res = http.send(req);
            system.debug('body:' +res.getBody());
            // Handle the response
            if (res.getStatusCode() == 201) {
                System.debug('Event created successfully');
                Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String outlookEventId = (String)responseBody.get('id');
                system.debug('outlookEventId: '+outlookEventId);
                // Update Salesforce record with the Outlook Event ID
                if(salesforceEventId != null && outlookEventId != null){
                    Event eventToUpdate = new Event(Id = salesforceEventId, OutLookEventId__c = outlookEventId);
                    update eventToUpdate;
                    System.debug('eventToUpdate --> '+eventToUpdate);
                }                
            } else {
                System.debug('Failed to create event. Status code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
    
    //Method for update Event ---->>>> 
    @future(callout=true)
    public static void updateEventInOutlook(
        String outlookEvnId,
        String subject,
        DateTime startDate,
        DateTime endDate,
        List<String> attendeesEmails,
        String description,
        String eventType,
        String location
    ) {
        if (String.isEmpty(outlookEvnId)) {
            System.debug('Outlook Event ID is null or empty. Cannot update the event.');
            return;
        }
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:OutlookINtegrationthe401kadvisorlineNamed2/v1.0/me/calendar/events/' + outlookEvnId);
            req.setMethod('PATCH');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            // Debugging request details for traceability
            System.debug('outlookEvnId: ' + outlookEvnId);
            System.debug('Subject: ' + subject);
            System.debug('Start Date: ' + startDate);
            System.debug('End Date: ' + endDate);
            System.debug('Attendees: ' + attendeesEmails);
            System.debug('Description: ' + description);  
            System.debug('Event Type: ' + eventType);     
            System.debug('Location: ' + location);        
            // Create the attendees list dynamically
            List<Object> attendeesList = new List<Object>();
            for (String email : attendeesEmails) {
                Map<String, Object> attendee = new Map<String, Object>();
                Map<String, Object> emailAddress = new Map<String, Object>();
                emailAddress.put('address', email);
                attendee.put('emailAddress', emailAddress);
                attendee.put('type', 'required');
                attendeesList.add(attendee);
            }
            // Build the request body as a Map for JSON serialization
            Map<String, Object> requestBodyMap = new Map<String, Object>();
            requestBodyMap.put('subject', subject);
            // RSVP settings
            requestBodyMap.put('responseRequested', true);
            requestBodyMap.put('allowNewTimeProposals', true);
            // Handle null values and replace them with empty strings if needed
            //  String safeMeetingMode = meetingMode != null ? meetingMode : '';
            String safeDescription = description != null ? description : '';
            String safeEventType = eventType != null ? eventType : '';
            // Format meeting mode as an HTML hyperlink if it's a valid link
            /*  String meetingModeFormatted = safeMeetingMode;
if (safeMeetingMode.startsWith('http')) {
meetingModeFormatted = '<a href="' + safeMeetingMode + '">Join Meeting</a>';
}*/
            // Add the body content, including meeting mode, description, and type
            Map<String, Object> bodyContent = new Map<String, Object>();
            bodyContent.put('contentType', 'HTML');
            bodyContent.put('content', 'Meeting details: ' + safeDescription + '<br>Event Type: ' + safeEventType /*'<br>Meeting Mode: ' + meetingModeFormatted +*/ );
            requestBodyMap.put('body', bodyContent);
            // Add start date and time
            Map<String, Object> start = new Map<String, Object>();
            start.put('dateTime', startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            start.put('timeZone', 'UTC');
            requestBodyMap.put('start', start);
            // Add end date and time
            Map<String, Object> endDateTime = new Map<String, Object>();
            endDateTime.put('dateTime', endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            endDateTime.put('timeZone', 'UTC');
            requestBodyMap.put('end', endDateTime);
            // Add location
            Map<String, Object> locationMap = new Map<String, Object>();
            locationMap.put('displayName', location != null ? location : '');  // Handle null location
            requestBodyMap.put('location', locationMap);
            // Add attendees
            requestBodyMap.put('attendees', attendeesList);
            // Serialize the request body to JSON
            String requestBody = JSON.serialize(requestBodyMap);
            req.setBody(requestBody);
            // Debugging the final request body
            System.debug('Request Body: ' + requestBody);
            // HTTP callout
            Http http = new Http();
            HttpResponse res = http.send(req);
            system.debug('body after update :' +res.getBody());
            // Handle the response
            if (res.getStatusCode() == 200) {
                System.debug('Event updated successfully in Outlook.');
            } else {
                System.debug('Failed to update event. Status code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
    
    //Method for delete Event ---->>>> 
    @future(callout=true)
    public static void deleteEventInOutlook(String outlookEvnId) {
        if (String.isBlank(outlookEvnId)) {
            System.debug('Outlook Event ID is null or empty. Cannot delete the event.');
            return;
        }
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:OutlookINtegrationthe401kadvisorlineNamed2/v1.0/me/calendar/events/' + outlookEvnId);
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            
            // Log the request details
        	System.debug('Attempting to delete Outlook event with ID: ' + outlookEvnId);
            
            // HTTP callout
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res != null) {
                // Log the response details
                System.debug('Response Status Code: ' + res.getStatusCode());
                System.debug('Response Body: ' + res.getBody());
                
                // Handle the response
                if (res.getStatusCode() == 204) {
                    System.debug('Event deleted successfully in Outlook.');
                } else {
                    System.debug('Failed to delete event. Status code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
                }
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
    
}
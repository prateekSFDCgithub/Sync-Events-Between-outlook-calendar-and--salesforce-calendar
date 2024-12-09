@isTest
public class PostEventsToOutlookTrigger_TestClass {
    
    // Inner class for mocking HTTP callouts
    private class PostEventsToOutlookMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "ABCDEERTYHU123456"}'); 
            res.setStatusCode(201); 
            return res;
        }
    }

    @TestSetup
    public static void prepareData() {
        // Create test Account data
        Account acc = new Account();
        acc.LastName = 'Test Account';
        acc.PersonEmail = 'test123@gmail.com';
        insert acc;
    }

    @isTest
    public static void createEvent() {
        // Set the mock before any DML operations
        Test.setMock(HttpCalloutMock.class, new PostEventsToOutlookMock());
        
        Test.startTest();
        Event newEvent = new Event(
            Subject = 'Mock Event',
            StartDateTime = DateTime.now().addDays(5),
            EndDateTime = DateTime.now().addDays(6),
            WhatId = [SELECT Id FROM Account LIMIT 1].Id
        );
        insert newEvent;
        System.debug('Created Event --> ' + newEvent);
        Test.stopTest();
    }

    @isTest
    public static void updateEvent() {
        // Set the mock before the DML operations
        Test.setMock(HttpCalloutMock.class, new PostEventsToOutlookMock());
        
        // Create an Event record
        Event newEvent1 = new Event(
            Subject = 'Mock Event',
            StartDateTime = DateTime.now().addDays(5),
            EndDateTime = DateTime.now().addDays(6),
            WhatId = [SELECT Id FROM Account LIMIT 1].Id
        );
        insert newEvent1;
        System.debug('newEvent1 --> '+newEvent1);

        Test.startTest();
        // Update the created Event
        Event evt = [SELECT Id, Subject, OutLookEventId__c FROM Event WHERE Id = :newEvent1.Id LIMIT 1];
        evt.Subject = 'Updated Subject';
        evt.OutLookEventId__c = 'ABCDEERTYHU123456';
        update evt; 
        System.debug('updated Event --> '+evt);
        Test.stopTest();

    }
    
    @isTest
    public static void deleteEvent() {
        // Set the mock before the DML operations
        Test.setMock(HttpCalloutMock.class, new PostEventsToOutlookMock());
        
        // Create an Event record
        Event newEvent1 = new Event(
            Subject = 'Mock Event',
            StartDateTime = DateTime.now().addDays(5),
            EndDateTime = DateTime.now().addDays(6),
            WhatId = [SELECT Id FROM Account LIMIT 1].Id
        );
        insert newEvent1;
        System.debug('newEvent1 --> '+newEvent1);

        Test.startTest();
        // Update the created Event
        Event evt = [SELECT Id, Subject, OutLookEventId__c FROM Event WHERE Id = :newEvent1.Id LIMIT 1];
        evt.OutLookEventId__c = 'ABCDEERTYHU12345634567';
        update evt; 
        delete evt;
        System.debug('updated Event --> '+evt);
        Test.stopTest();

    }
}
@isTest
private class ProjectCalloutServiceTest {
    //Implement mock callout tests here
    @TestSetup
    static void testSetup() {
        List<SObject> toInsert = new List<SObject>();
        Opportunity opp1 = new Opportunity(Name = 'Test1',
                Type = 'New Project',
                Amount = 10000,
                CloseDate = Date.today(),
                StageName = 'Submitted Project');
        toInsert.add(opp1);
        Opportunity opp2 = new Opportunity(Name = 'Test2',
                Type = 'New Project',
                Amount = 20000,
                CloseDate = Date.today(),
                StageName = 'Resubmit Project');
        toInsert.add(opp2);
        ServiceTokens__c token = new ServiceTokens__c(Name = 'ProjectServiceToken', Token__c = 'wwwwwwwwwwwwwwww');
        toInsert.add(token);
        insert toInsert;
    }

    @IsTest
    static void testSuccessMessage() {
        Opportunity opp = [
                SELECT Id, Name
                FROM Opportunity
                WHERE Name = 'Test1'
                LIMIT 1
        ];
        List<Id> oppIds = new List<Id>();
        oppIds.add(opp.Id);
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        Test.startTest();
        ProjectCalloutService.postOpportunityToPMS(oppIds);
        Test.stopTest();
        opp = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opp.Id
        ];
        System.assertEquals('Submitted Project', opp.StageName);
    }

    @IsTest
    static void testFailureMessage() {
        Opportunity opp = [
                SELECT Id, Name
                FROM Opportunity
                WHERE Name = 'Test2'
                LIMIT 1
        ];
        List<Id> oppIds = new List<Id>();
        oppIds.add(opp.Id);
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        Test.startTest();
        ProjectCalloutService.postOpportunityToPMS(oppIds);
        Test.stopTest();
        opp = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opp.Id
        ];
        System.assertEquals('Resubmit Project', opp.StageName);
    }
}
@IsTest
private class BillingCalloutServiceTest {
    @TestSetup
    static void loadData() {
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp1';
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        insert opp;

        Project__c project = new Project__c();
        project.Name = 'TestProj1';
        project.Billable_Amount__c = 1000;
        project.ProjectRef__c = 'TestRef1';
        project.Status__c = 'Running';
        project.Opportunity__c = opp.Id;
        insert project;

        ServiceCredentials__c serviceCredentials = new ServiceCredentials__c();
        serviceCredentials.Name = 'BillingServiceCredential';
        serviceCredentials.Username__c = 'usr1';
        serviceCredentials.Password__c = 'pwd1';
        insert serviceCredentials;
    }

    @IsTest
    static void testCalloutSuccess() {
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        List<Project__c> projects = [
                SELECT Status__c
                FROM Project__c
                WHERE ProjectRef__c = 'TestRef1'
        ];
        System.assertEquals(1, projects.size());
        Test.startTest();
        projects[0].Status__c = 'Billable';
        update projects;
        Test.stopTest();
    }

    @IsTest
    static void testCalloutFailure() {
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
        List<Project__c> projects = [
                SELECT Status__c
                FROM Project__c
                WHERE ProjectRef__c = 'TestRef1'
        ];
        System.assertEquals(1, projects.size());
        Test.startTest();
        projects[0].Status__c = 'Running';
        update projects;
        Test.stopTest();
    }
}
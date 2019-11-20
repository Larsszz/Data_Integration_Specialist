@IsTest
private class ProjectRESTServiceTest {
    //Implement Apex REST service tests here
    @TestSetup
    static void loadServiceData() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.DeliveryInstallationStatus__c = 'In progress';
        opp.CloseDate = (Date.today()).addDays(20);
        opp.StageName = 'Submitted Project';
        insert opp;

        Project__c project = new Project__c();
        project.ProjectRef__c = 'ProjectRef';
        project.Name = 'ProjectName';
        project.Opportunity__c = opp.Id;
        project.Start_Date__c = Date.today();
        project.End_Date__c = (Date.today()).addDays(10);
        project.Billable_Amount__c = 1000;
        project.Status__c = 'Running';
        insert project;
    }

    @IsTest
    static void testProjectRESTService() {
        Project__c project = [
                SELECT Id, ProjectRef__c, Name, Opportunity__c, Start_Date__c, End_Date__c, Billable_Amount__c, Status__c
                FROM Project__c
                LIMIT 1
        ];
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String returnMessage = ProjectRESTService.postProjectData('ProjectRef',
                'ProjectName', String.valueOf(opp.Id), Date.today(), Date.today(),
                1000, 'Running');
        Test.stopTest();
    }
}
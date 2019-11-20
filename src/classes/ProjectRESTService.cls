@RestResource(UrlMapping = '/project/*')
global with sharing class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId,
            Date StartDate, Date EndDate, Double Amount, String Status) {
        String retMsg = 'Error';
        Savepoint sp1 = Database.setSavepoint();
        try {
            if (OpportunityId != null) {
                Opportunity opp = [
                        SELECT Id,
                                DeliveryInstallationStatus__c
                        FROM Opportunity
                        WHERE Id = :OpportunityId
                        LIMIT 1
                ];
                opp.DeliveryInstallationStatus__c = 'In progress';
                update opp;
            }
            Project__c project = new Project__c();
            project.ProjectRef__c = ProjectRef;
            project.Name = ProjectName;
            project.Opportunity__c = OpportunityId;
            project.Start_Date__c = StartDate;
            project.End_Date__c = EndDate;
            project.Billable_Amount__c = Amount;
            project.Status__c = Status;
            upsert project;

            retMsg = 'OK';
        } catch (Exception ex) {
            Database.rollback(sp1);
            retMsg = ex.getMessage();
        }
        return retMsg;
    }
}
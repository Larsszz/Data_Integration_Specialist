public class ProjectCalloutService {
    //Complete the implementation for business and callout logic
    @InvocableMethod
    public static void postOpportunityToPMS(List<Id> oppIds) {
        Opportunity opp = [
                SELECT Id,Name,Account.Name,CloseDate,Amount
                FROM Opportunity
                WHERE Id = :oppIds[0]
                LIMIT 1
        ];

        String serviceToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
        String jsonInput = '{' +
                ' "opportunityId" : "' + opp.Id +
                ' "opportunityName" : "' + opp.Name +
                ' "accountName" : "' + opp.Account.Name +
                ' "closeDate" : "' + String.valueOf(opp.CloseDate).mid(0, 10) +
                ' "amount" : "' + opp.Amount + '}';

        System.enqueueJob(new QueueablePMSCall(serviceToken, jsonInput, opp.Id));
    }

    @Future(Callout=true)
    public static void postToPMS(String serviceToken, String jsonInput, Id oppId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ProjectService');
        req.setMethod('POST');
        req.setHeader('token', serviceToken);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(jsonInput);

        Http http = new Http();
        HttpResponse res = http.send(req);

        Opportunity opp = new Opportunity(Id = oppId);
        if (res.getStatusCode() == 201) {
            opp.StageName = 'Submitted Project';
            System.debug('Success: ' + res.getStatus());
        } else {
            opp.StageName = 'Resubmit Project';
            System.debug('Failure: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
        update opp;
    }

    class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts{
        private String serviceToken;
        private String jsonInput;
        private Id oppId;

        public QueueablePMSCall(String serviceToken, String jsonInput, Id oppId){
            this.serviceToken = serviceToken;
            this.jsonInput = jsonInput;
            this.oppId = oppId;
        }

        public void execute(QueueableContext qc){
            postToPMS(serviceToken, jsonInput, oppId);
        }
    }
}
/**
 * Created by IlarionTokarskyi on 11/20/2019.
 */

public with sharing class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts {
    private String serviceToken;
    private String jsonInput;
    private Id oppId;

    public QueueablePMSCall(String serviceToken, String jsonInput, Id oppId){
        this.serviceToken = serviceToken;
        this.jsonInput = jsonInput;
        this.oppId = oppId;
    }

    public void execute(QueueableContext qc){
        ProjectCalloutService.postToPMS(serviceToken, jsonInput, oppId);
    }
}
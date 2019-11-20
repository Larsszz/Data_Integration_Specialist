public class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
   //Implement http mock callout failure here
   public HttpResponse respond(HttpRequest request){
      // Create a fake response
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatus('Bad Response');
      response.setStatusCode(500);

      return response;
   }
}
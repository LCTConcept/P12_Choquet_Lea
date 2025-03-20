@isTest
public class ContactDeleteAPITest {
    
    
    @testSetup
    public static void setupTestData() {
        // Création d'un contact existant dans la base pour tester la duplication
        TestDataFactory.createTestContact(true);
    }
    
    //CONTACT03_TEST01 : Suppression d'un contact existant 
    
    @isTest
    public static void testUpdateContactValid(){
        
        //ETANT DONNE une requête de modification d'un contact existant dans la base de données
        Contact existingContact = [SELECT Id, LastName, Is_Active__c FROM Contact WHERE Email = 'sarahparker@test.com' LIMIT 1];
        System.debug('Statut du contact avant update : '+ existingContact.Is_Active__c);
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/' + existingContact.Id;
        req.httpMethod = 'DELETE';
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        //QUAND l'API est appelée
        Test.startTest();
        ContactAPI.deactivateContactRest();
        Test.stopTest();
        
        //ALORS le contact est désactivé 
        Contact deactivatedContact = [SELECT Id, Is_Active__c FROM Contact WHERE Id = :existingContact.Id];
        System.debug('Statut du contact avant update : '+ deactivatedContact.Is_Active__c );
            
        //VERIFICATIONS 
        System.assertEquals(false, deactivatedContact.Is_Active__c, 'Le contact doit être désactivé');
        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Contact désactivé avec succès.'));       
        
    }
    
    // CONTACT03_TEST02 : Désactivation avec un ID invalide 
    @isTest
    public static void testDeactivateInvalidIdContact() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/NonExistentId';
        req.httpMethod = 'DELETE';
        
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.deactivateContactRest();
        Test.stopTest();

        // ALORS une erreur 400 est retournée
        System.debug('Code d\'erreur : '+ RestContext.response.statusCode);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('ID du contact invalide ou manquant.'));
    }
    
    // CONTACT03_TEST03 : Désactivation d’un contact inexistant
    @isTest
    public static void testDeactivateNonExistantContact() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/0015w00000Pm3EwAA';
        req.httpMethod = 'DELETE';

        RestContext.request = req;
        RestContext.response = new RestResponse();

        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.deactivateContactRest();
        Test.stopTest();

        // ALORS une erreur 404 est retournée
        System.debug('Code d\'erreur : '+ RestContext.response.statusCode);
        System.assertEquals(404, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Contact non trouvé, suppression impossible.'));
    }
    
    
    
    

}
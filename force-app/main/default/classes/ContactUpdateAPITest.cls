@isTest
public class ContactUpdateAPITest {
    
    // Test Setup : Création d'un contact de base utilisé dans les tests
     @testSetup
    public static void setupTestData() {
        // Création d'un contact de test
        TestDataFactory.createTestContact(true);
    }
    
    //CONTACT02_TEST01 : Update d'un contact existant 
    @isTest
    public static void testUpdateContactValid(){
        
        //ETANT DONNE une requête de modification d'un contact existant dans la base de données
        Contact existingContact = [SELECT Id, LastName FROM Contact WHERE Email = 'sarahparker@test.com' LIMIT 1];
        System.debug('LastName avant update : '+ existingContact.LastName);
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/' + existingContact.Id;
        req.httpMethod = 'PATCH';
        
        //Modifications à updater
        Map<String, Object> body = new Map<String, Object>{
            'LastName' => 'Sarah-Lane'
                };
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée: ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.updateContactRest();
        Test.stopTest();
        
        //ALORS les données du contact ont été modifié 
        Contact updatedContact = [SELECT LastName FROM Contact WHERE Id = :existingContact.Id];
        System.debug('LastName après update : '+ updatedContact.LastName);
        
        //VERIFICATIONS : 
        System.assertEquals('Sarah-Lane', updatedContact.LastName);
        System.assertEquals(200, res.statusCode);
        System.assert(res.responseBody.toString().contains('Contact mis à jour avec succès.'));
        System.assert(res.responseBody.toString().contains('ContactId'));
        
    }
    
    // CONTACT02_TEST02 : Test avec un ID de contact invalide
    @isTest
    public static void testUpdateContactInvalidId() {
        
        // ETANT DONNE une requête avec un ID de contact invalide
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/invalidId';
        req.httpMethod = 'PATCH';
        
        Map<String, Object> body = new Map<String, Object>{
            'Phone' => '987-654-3210'
                };
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.updateContactRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('ID du contact invalide ou manquant.'));
    }
    
    // CONTACT02_TEST03 : Test avec un contact non trouvé
    @isTest
    public static void testUpdateContactNotFound() {
        
        // ETANT DONNE une requête avec un ID de contact valide mais inexistant dans la base de données
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/0015w00000Pm3EwAA'; // ID inexistant
        req.httpMethod = 'PATCH';
        
        Map<String, Object> body = new Map<String, Object>{
            'Phone' => '987-654-3210'
                };
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.updateContactRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(404, res.statusCode);
        System.assert(res.responseBody.toString().contains('Contact non trouvé, mise à jour impossible.'));
    }
    
    // CONTACT02_TEST04 : Test avec un body vide
    @isTest
    public static void testUpdateContactEmptyBody() {
        
        // ETANT DONNE une requête avec un body vide
        Contact existingContact = [SELECT Id FROM Contact WHERE Email = 'sarahparker@test.com' LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/' + existingContact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.updateContactRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Aucune donnée fournie pour la mise à jour.'));
    }
    
    // CONTACT02_TEST05 : Test avec un email invalide
    @isTest
    public static void testUpdateContactInvalidEmail() {
        
        // ETANT DONNE une requête avec un email invalide dans le body
        Contact existingContact = [SELECT Id FROM Contact WHERE Email = 'sarahparker@test.com' LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/' + existingContact.Id;
        req.httpMethod = 'PATCH';
        
        Map<String, Object> body = new Map<String, Object>{
            'Email' => 'invalid-email'
                };
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.updateContactRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 500 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(500, res.statusCode);
        System.assert(res.responseBody.toString().contains('Erreur lors de la mise à jour du contact.'));
    }

}
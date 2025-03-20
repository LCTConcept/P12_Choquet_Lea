@isTest
public class ContactCreationAPITest {
    
    @testSetup
    public static void setupTestData() {
        // Création d'un contact existant dans la base pour tester la duplication
        TestDataFactory.createTestContact(true);
    }
    
    //CONTACT01_TEST01 : Vérification de l'existence du contact
    @isTest
    static void testContactExistence() {
        
        // ETANT DONNE une requête de création de contact d'un contact déjà existant
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/';
        req.httpMethod = 'POST';
        Map<String, Object> body = new Map<String, Object>{
            'Email' => 'sarahparker@test.com',
                'LastName' => 'Sarah',
                'FirstName' => 'Parker',
                'Phone' => '123-456-7890'
                };
                    
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée: ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.createContactRest();
        Test.stopTest();
        
        
        // ALORS l'API doit renvoyer l'ID du contact existant
        res = RestContext.response;  
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète : ' + responseBody);
        
        
        // VERIFICATIONS :
        System.assertNotEquals(null, RestContext.response, 'La réponse est nulle');
        System.assertEquals(200, res.statusCode);
        System.assert(responseBody.contains('Contact déjà existant'));
        System.assert(responseBody.contains('ContactId'));
        
    }
    
    //CONTACT01_TEST02 : Création d'un contact car l'email n'existe pas 
    @isTest
    static void testContactCreation(){
        
        // ETANT DONNE une requête de création de contact non existant dans la base de données
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/';
        req.httpMethod = 'POST';
        Map<String, Object> body = new Map<String, Object>{
            'Email' => 'emilyfrost@test.com',
                'LastName' => 'Emily',
                'FirstName' => 'Frost',
                'Phone' => '234-567-8910'
                };
                    
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée: ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.createContactRest();
        Test.stopTest();
        
        
        // ALORS l'API doit créer un contact et retourner son ID
        res = RestContext.response;  
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertNotEquals(null, RestContext.response, 'La réponse est nulle');
        System.assertEquals(201, res.statusCode);
        System.assert(responseBody.contains('Contact créé avec succès.'));
        System.assert(responseBody.contains('ContactId'));
        
    }
    
    //CONTACT01_TEST03 : Gestion de l'erreur si le body est vide
    @isTest
    static void testEmptyRequestBody() {
        
        // ETANT DONNE une requête avec un body vide
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(''); // Body vide
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée (vide) : ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.createContactRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (vide) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode, 'Le statut de la réponse n\'est pas 400');
        System.assert(responseBody.contains('Aucune donnée fournie pour la création du contact.'));
    }
    
    //CONTACT01_TEST04 : Gestion de l'erreur pour une adresse email invalide
    
    @isTest
    static void testInvalidEmail() {
        
        // ETANT DONNE une requête avec une adresse email invalide
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contacts/';
        req.httpMethod = 'POST';
        
        // Email invalide (pas de domaine)
        Map<String, Object> body = new Map<String, Object>{
            'Email' => 'invalid-email',
                'LastName' => 'Peter',
                'FirstName' => 'Jacksman',
                'Phone' => '555-123-4567'
                };
                    
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée avec email invalide : ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        ContactAPI.createContactRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (email invalide) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode, 'Le statut de la réponse n\'est pas 400');
        System.assert(responseBody.contains('Email valide obligatoire.'));
    }
    
}
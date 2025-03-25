@isTest
public class AccountCreateAPITest {
    
    
    // ACCOUNT01_TEST01 : Vérification de la création d’un compte
    @isTest
    static void testContractCreation() {
        
        
        // ETANT DONNE une requête de création de contrat avec un AccountId valide
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/account/';
        req.httpMethod = 'POST';
        
        Map<String, Object> body = new Map<String, Object>{
            'Name' => 'Test Account',  
                'Phone' => '0459863214'};
                    
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée: ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        AccountAPI.createAccountRest();
        Test.stopTest();
        
        // ALORS l'API doit renvoyer un statut 201 et un message de succès
        res = RestContext.response;  
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète : ' + responseBody);
        Account insertedAccount = [SELECT Id, Name, Phone FROM Account WHERE Name = 'Test Account' LIMIT 1];
        System.debug('Nouveau compte : ' + insertedAccount.Id);
        
        // VERIFICATIONS :
        System.assertNotEquals(null, RestContext.response, 'La réponse est nulle');
        System.assertEquals(201, res.statusCode);
        System.assert(responseBody.contains('Compte créé avec succès'));
        System.assert(responseBody.contains('AccountId'));
        
    }
    
    //ACCOUNT01_TEST02 : Gestion de l'erreur si le body est vide
    @isTest
    static void testEmptyRequestBody() {
        
        // ETANT DONNE une requête avec un body vide
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/account/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(''); // Body vide
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée (vide) : ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        AccountAPI.createAccountRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (vide) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode, 'Le statut de la réponse n\'est pas 400');
        System.assert(responseBody.contains('Aucune donnée fournie pour la création du compte.'));
    }    
    
    // ACCOUNT01_TEST03 : Gestion d'une requête avec un champ obligatoire manquant
    @isTest
    static void testMissingRequiredFields() {
        
        // ETANT DONNE une requête où il manque "StartDate"
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contract/';
        req.httpMethod = 'POST';
        
        Map<String, Object> body = new Map<String, Object>{  
            'Phone' => '0459863214'
                // "Name" est manquant
                };
                    
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée: ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        AccountAPI.createAccountRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode, 'Le statut de la réponse n\'est pas 400');
        System.assert(responseBody.contains('Le champs Name est obligatoire.'));
    }
    
    
}
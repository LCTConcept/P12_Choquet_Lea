/**
 * Cette classe contient des tests unitaires pour vérifier les différentes fonctionnalités de l'API de mise à jour des comptes.
 * 
 * Les tests incluent les vérifications suivantes :
 * - Mise à jour d'un compte existant avec des données valides.
 * - Gestion de l'erreur si l'ID du compte est invalide.
 * - Gestion de l'erreur si le corps de la requête est vide.
 * - Gestion de l'erreur si le compte n'est pas trouvé.
 * 
 */

@isTest
public class AccountUpdateAPITest {
    
    // Test Setup : Création des données de test
    @testSetup
    public static void createTestData() {
        // Création d'un contrat
        TestDataFactory.createTestAccount(true);
    }
    
    //ACCOUNT02_TEST01 : Update d'un contrat existant 
    @isTest
    /**
     * @description testUpdateAccountValid Mise à jour d'un compte existant avec des données valides.
     */
    public static void testUpdateAccountValid(){
        
        //ETANT DONNE une requête de modification d'un contact existant dans la base de données
        Account existingAccount = [SELECT Id, Name, Phone, AccountNumber  FROM Account WHERE Name = 'Test Account' LIMIT 1];
        System.debug('AccountId avant update : '+ existingAccount.Id);
        System.debug('AccountNumber avant update : '+ existingAccount.AccountNumber);
        System.debug('Phone avant update : '+ existingAccount.Phone);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/account/' + existingAccount.Id;
        req.httpMethod = 'PATCH';
        
        //Modifications à updater
        Map<String, Object> body = new Map<String, Object>{
            'Phone' => '0123456789',
                'AccountNumber' => 'TESTACCOUNT001'
                };
                    
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée: ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        AccountAPI.updateAccountRest();
        Test.stopTest();
        
        //ALORS les données du contact ont été modifié 
        Account updatedAccount = [SELECT Id, Name, Phone, AccountNumber  FROM Account WHERE Id = :existingAccount.Id];
        System.debug('AccountNumber après update : '+ updatedAccount.AccountNumber);
        System.debug('Phone après update : '+ updatedAccount.Phone);
        
        //VERIFICATIONS : 
        System.assertEquals('0123456789', updatedAccount.Phone);
        System.assertEquals('TESTACCOUNT001', updatedAccount.AccountNumber);
        System.assertEquals(200, res.statusCode);
        System.assert(res.responseBody.toString().contains('Compte mis à jour avec succès.'));
        System.assert(res.responseBody.toString().contains('AccountId'));
        
    }
    
    //ACCOUNT02_TEST02 : Update d'un compte avec un ID invalide
    @isTest
    /**
     * @description testUpdateContractInvalidId Gestion de l'erreur si l'ID du compte est invalide.
     */
    public static void testUpdateContractInvalidId() {
        
        // ETANT DONNE une requête avec un ID de contrat invalide
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/account/invalidId';
        req.httpMethod = 'PATCH';
        
        Map<String, Object> body = new Map<String, Object>{
            'Phone' => '0125698745'
                };
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        AccountAPI.updateAccountRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode);
        System.assert(responseBody.contains('ID du compte invalide ou manquant.'));
    }
    
    //ACCOUNT02_TEST03 : Update d'un compte avec un body vide
    @isTest
    /**
     * @description testUpdateContractEmptyBody Gestion de l'erreur si le corps de la requête est vide.
     */
    public static void testUpdateContractEmptyBody() {
        
        // ETANT DONNE une requête avec un body vide
         Account existingAccount = [SELECT Id  FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/account/' + existingAccount.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        AccountAPI.updateAccountRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Aucune donnée fournie pour la mise à jour.'));
    }
    
    // ACCOUNT02_TEST04 : Test avec un compte non trouvé
    @isTest
    /**
     * @description testUpdateContractNotFound Gestion de l'erreur si le compte n'est pas trouvé.
     */
    public static void testUpdateContractNotFound() {
        
        // ETANT DONNE une requête avec un ID de compte valide mais inexistant dans la base de données
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/account/8005w00000Xy3EzAA'; // ID inexistant
        req.httpMethod = 'PATCH';
        
        Map<String, Object> body = new Map<String, Object>{
            'Phone' => '0147852369'
                };
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        AccountAPI.updateAccountRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 404 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(404, res.statusCode);
        System.assert(res.responseBody.toString().contains('Compte non trouvé, mise à jour impossible.'));
    }
    
}
/**
 * Cette classe contient des tests unitaires pour vérifier les différentes fonctionnalités de l'API de modification de contrats.
 * 
 * Les tests vérifient les scénarios suivants :
 * 1. Mise à jour d'un contrat existant avec des données valides.
 * 2. Tentative de mise à jour d'un contrat avec un ID invalide.
 * 3. Tentative de mise à jour avec un body vide.
 * 4. Tentative de mise à jour d'un contrat qui n'existe pas.
 * 
 */

@isTest
public class ContractUpdateTest {
    
       // Test Setup : Création des données de test
    @testSetup
    public static void createTestData() {
        // Création d'un contrat
        TestDataFactory.createTestContract(true);
    }
    
    
    //CONTRACT02_TEST01 : Update d'un contrat existant 
    @isTest
    /**
     * @description testUpdateContactValid Mise à jour d'un contrat existant avec des données valides.
     */
    public static void testUpdateContactValid(){
        
        //ETANT DONNE une requête de modification d'un contact existant dans la base de données
        Contract existingContract = [SELECT Id, Name, Status, AccountId, ContractTerm, StartDate  FROM Contract WHERE Name = 'Test Contract' LIMIT 1];
        System.debug('Statut avant update : '+ existingContract.Status);
        System.debug('ContractTerm avant update : '+ existingContract.ContractTerm);
        System.debug('StartDate avant update : '+ existingContract.StartDate);

        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contract/' + existingContract.Id;
        req.httpMethod = 'PATCH';
        
        //Modifications à updater
       Map<String, Object> body = new Map<String, Object>{
            'AccountId' => existingContract.AccountId,  
                'ContractTerm' => 24,
                'Status' => 'Activated',
                'StartDate' =>'2024-03-06'
                };
                    
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.debug('Requête envoyée: ' + req.requestBody.toString());
        
        // QUAND l'API est appelée
        Test.startTest();
        ContractAPI.updateContractRest();
        Test.stopTest();
        
        //ALORS les données du contact ont été modifié 
        Contract updatedContract = [SELECT Id, Status, ContractTerm, StartDate FROM Contract WHERE Id = :existingContract.Id];
        System.debug('Statut après update : '+ updatedContract.Status);
        System.debug('ContractTerm après update : '+ updatedContract.ContractTerm);
        System.debug('StartDate après update : '+ updatedContract.StartDate);
        
        //VERIFICATIONS : 
        System.assertEquals('Activated', updatedContract.Status);
        System.assertEquals(200, res.statusCode);
        System.assert(res.responseBody.toString().contains('Contrat mis à jour avec succès.'));
        System.assert(res.responseBody.toString().contains('ContractId'));
        
    }
    
    //CONTRACT02_TEST02 : Update d'un contrat avec un ID invalide
    @isTest
    /**
     * @description testUpdateContractInvalidId Tentative de mise à jour d'un contrat avec un ID invalide.
     */
    public static void testUpdateContractInvalidId() {
        
        // ETANT DONNE une requête avec un ID de contrat invalide
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contract/invalidId';
        req.httpMethod = 'PATCH';
        
        Map<String, Object> body = new Map<String, Object>{
            'Status' => 'Activated'
                };
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        ContractAPI.updateContractRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode);
        System.assert(responseBody.contains('ID du contrat invalide ou manquant.'));
    }
    
    //CONTRACT02_TEST03 : Update d'un contrat avec un body vide
    @isTest
    /**
     * @description testUpdateContractEmptyBody Tentative de mise à jour avec un body vide.
     */
    public static void testUpdateContractEmptyBody() {
        
        // ETANT DONNE une requête avec un body vide
        Contract existingContract = [SELECT Id FROM Contract WHERE Name = 'Test Contract' LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contract/' + existingContract.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        ContractAPI.updateContractRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 400 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Aucune donnée fournie pour la mise à jour.'));
    }
    
    // CONTACT02_TEST04 : Test avec un contrat non trouvé
    @isTest
    /**
     * @description testUpdateContractNotFound Tentative de mise à jour d'un contrat qui n'existe pas.
     */
    public static void testUpdateContractNotFound() {
        
        // ETANT DONNE une requête avec un ID de contrat valide mais inexistant dans la base de données
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/contract/8005w00000Xy3EzAA'; // ID inexistant
        req.httpMethod = 'PATCH';
        
        Map<String, Object> body = new Map<String, Object>{
            'Status' => 'Activated'
                };
                    req.requestBody = Blob.valueOf(JSON.serialize(body));
        RestContext.request = req;
        
        // On assure qu'une réponse est initialisée
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // QUAND l'API est appelée
        Test.startTest();
        ContractAPI.updateContractRest();
        Test.stopTest();
        
        // ALORS l'API doit retourner une erreur 404 avec un message
        res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.debug('Réponse complète (erreur) : ' + responseBody);
        
        // VERIFICATIONS :
        System.assertEquals(404, res.statusCode);
        System.assert(res.responseBody.toString().contains('Contrat non trouvé, mise à jour impossible.'));
    }
    
    
}
/**
 * Cette classe permet de créer et de mettre à jour un contrat existant via des requêtes HTTP POST, PATCH.
 * 
 * La gestion des erreurs suit les codes de statut de la documentation officielle Salesforce :
 * https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
 * 
 * Méthodes exposées :
 * - createContractRest() : Création d'un contrat. 
 * - updateContractRest() : Mise à jour d'un contrat existant.
 * 
 */

@RestResource(urlMapping='/contract/*')

global with sharing class ContractAPI {
    
    //CONTACT01 : Création d’un contrat 
    
    @HttpPost
    global static void createContractRest(){
        
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        //Etape 1 : Récupérer les données de la requête API et renvoyer une erreur si aucune n'est fournie
        String requestBody = req.requestBody.toString();
        if (String.isBlank(requestBody)) {
            res.statusCode = 400;
            Map<String, String> unvalidRequestErrorResponse = new Map<String, String>{
                'Message' => 'Aucune donnée fournie pour la création du contrat.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(unvalidRequestErrorResponse));
            return;
        }
        
        Map<String, Object> reqbodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        //Etape 2 : Vérifier si les champs obligatoires sont fournies et renvoyer une erreur si ce n'est pas le cas 
        if (!reqbodyMap.containsKey('AccountId') 
            || !reqbodyMap.containsKey('ContractTerm')
            || !reqbodyMap.containsKey('Status')
            || !reqbodyMap.containsKey('StartDate')) {
                res.statusCode = 400;
                Map<String, String> missingFieldErrorResponse = new Map<String, String>{
                    'Message' => 'Les champs AccountId, ContractTerm, Status et StartDate sont obligatoires.'
                        };
                            res.responseBody = Blob.valueOf(JSON.serialize(missingFieldErrorResponse));
                return;
            }
        
        
        //Etape 3 : Créer le contrat dans Salesforce et convertir les données
        Contract newContract = new Contract();
        
        newContract.AccountId = (String) reqbodyMap.get('accountId');
        newContract.ContractTerm = Integer.valueOf(reqbodyMap.get('ContractTerm'));
        newContract.Status = (String) reqbodyMap.get('Status');
        newContract.StartDate = Date.valueOf((String) reqbodyMap.get('StartDate'));
        
        for (String fieldName : reqbodyMap.keySet()) {
            if (fieldName != 'AccountName' 
                && fieldName != 'ContractTerm' 
                && fieldName != 'Status' 
                && fieldName != 'StartDate') {
                    newContract.put(fieldName, reqbodyMap.get(fieldName));}
        }
        
        
        //Etape 4 : Insérer le nouveau contrat dans la base de données 
        try {
            insert newContract;
            res.statusCode = 201;  // Created Success Code
            Map<String, String> insertSuccessMessageMap = new Map<String, String>{
                'Message' => 'Contrat créé avec succès.',
                    'ContractId' => newContract.Id
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(insertSuccessMessageMap));       
        }     catch (DmlException e) {
            res.statusCode = 500;  // Internal Server Error
            Map<String, String> insertErrorMessageMap = new Map<String, String>{
                'Message' => 'Echec de création du contrat.',
                    'Error' => e.getMessage()
                    }; 
                        res.responseBody = Blob.valueOf(JSON.serialize(insertErrorMessageMap));
            return;
        }
    }
    
    //CONTACT02 : Modification d’un contrat
    @HttpPatch
    global static void updateContractRest(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Etape 1 : Récupérer l'ID du contrat et renvoyer une erreur s'il n'est pas valide
        String contractId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        if (String.isBlank(contractId) || !Pattern.matches('^\\w{15,18}$', contractId)) {
            res.statusCode = 400;  // Bad Request
            Map<String, String> badRequestMessageResponse = new Map<String, String>{
                'Message' => 'ID du contrat invalide ou manquant.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(badRequestMessageResponse));
            return;
        }
        
        //Etape 2 : Récupérer le contrat à modifier et renvoyer une erreur si le contrat n'a pas été trouvé  
        List<Contract> contracts = [SELECT Id FROM Contract WHERE Id = :contractId LIMIT 1];   
        if (contracts.isEmpty()) {
            res.statusCode = 404;  // Not Found
            Map<String, String> notFoundErrorResponse = new Map<String, String>{
                'Message' => 'Contrat non trouvé, mise à jour impossible.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(notFoundErrorResponse));
            return;
        }
        Contract contractToUpdate = contracts[0];
        
        //Etape 3 : Récupérer les données de la requête API et renvoyer une erreur si aucune n'est fournie
        String requestBody = req.requestBody.toString();
        if (String.isBlank(requestBody)) {
            res.statusCode = 400;
            Map<String, String> unvalidRequestErrorResponse = new Map<String, String>{
                'Message' => 'Aucune donnée fournie pour la mise à jour.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(unvalidRequestErrorResponse));
            return;
        }
        
        Map<String, Object> reqbodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        
        //Etape 4 : Préparation de la mise à jour des données du contrat 
        
        contractToUpdate.AccountId = (String) reqbodyMap.get('accountId');
        contractToUpdate.ContractTerm = Integer.valueOf(reqbodyMap.get('ContractTerm'));
        contractToUpdate.Status = (String) reqbodyMap.get('Status');
        contractToUpdate.StartDate = Date.valueOf((String) reqbodyMap.get('StartDate'));
        
        for (String fieldName : reqbodyMap.keySet()) {
            if (fieldName != 'AccountName' 
                && fieldName != 'ContractTerm' 
                && fieldName != 'Status' 
                && fieldName != 'StartDate') {
                    contractToUpdate.put(fieldName, reqbodyMap.get(fieldName));}
        }
        
        
        //Etape 5 : Mise à jour du contrat
        try {
            update contractToUpdate;
            res.statusCode = 200;  // OK success code
            Map<String, String> successResponse = new Map<String, String>{
                'Message' => 'Contrat mis à jour avec succès.',
                    'ContractId' => contractToUpdate.Id
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(successResponse));
        } catch (DmlException e) {
            res.statusCode = 500;  // Internal Server Error
            Map<String, String> updateErrorMessageMap = new Map<String, String>{
                'Message' => 'Erreur lors de la mise à jour du contrat.',
                    'Error' => e.getMessage()
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(updateErrorMessageMap));
        }    
    }
    
    
}
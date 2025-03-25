@RestResource(urlMapping='/account/*')

/*Pour l'intégralité de ce code, les status.code font référence à la documentation officielle Salesforce : 
* https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm */

global with sharing class AccountAPI {
    
    
    //ACCOUNT01 : Création d’un compte 
    
    @HttpPost
    global static void createAccountRest(){
        
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        //Etape 1 : Récupérer les données de la requête API et renvoyer une erreur si aucune n'est fournie
        String requestBody = req.requestBody.toString();
        if (String.isBlank(requestBody)) {
            res.statusCode = 400;
            Map<String, String> unvalidRequestErrorResponse = new Map<String, String>{
                'Message' => 'Aucune donnée fournie pour la création du compte.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(unvalidRequestErrorResponse));
            return;
        }
        
        Map<String, Object> reqbodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        //Etape 2 : Vérifier si les champs obligatoires sont fournis et renvoyer une erreur si ce n'est pas le cas 
        if (!reqbodyMap.containsKey('Name')) {
            res.statusCode = 400;
            Map<String, String> missingFieldErrorResponse = new Map<String, String>{
                'Message' => 'Le champs Name est obligatoire.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(missingFieldErrorResponse));
            return;
        }
        
        
        //Etape 3 : Créer le compte dans Salesforce et associer les données
        Account newAccount = new Account();
        
        for (String fieldName : reqbodyMap.keySet()) {
            newAccount.put(fieldName, reqbodyMap.get(fieldName));}
        
        
        
        //Etape 4 : Insérer le nouveau compte dans la base de données 
        try {
            insert newAccount;
            res.statusCode = 201;  // Created Success Code
            Map<String, String> insertSuccessMessageMap = new Map<String, String>{
                'Message' => 'Compte créé avec succès.',
                    'AccountId' => newAccount.Id
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(insertSuccessMessageMap));       
        }     catch (DmlException e) {
            res.statusCode = 500;  // Internal Server Error
            Map<String, String> insertErrorMessageMap = new Map<String, String>{
                'Message' => 'Echec de création du compte.',
                    'Error' => e.getMessage()
                    }; 
                        res.responseBody = Blob.valueOf(JSON.serialize(insertErrorMessageMap));
            return;
        }
    }
    
    //ACCOUNT02 : Modification d’un compte
    @HttpPatch
    global static void updateAccountRest(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Etape 1 : Récupérer l'ID du compte et renvoyer une erreur s'il n'est pas valide
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        if (String.isBlank(accountId) || !Pattern.matches('^\\w{15,18}$', accountId)) {
            res.statusCode = 400;  // Bad Request
            Map<String, String> badRequestMessageResponse = new Map<String, String>{
                'Message' => 'ID du compte invalide ou manquant.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(badRequestMessageResponse));
            return;
        }
        
        //Etape 2 : Récupérer le compte à modifier et renvoyer une erreur si le compte n'a pas été trouvé  
        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];   
        if (accounts.isEmpty()) {
            res.statusCode = 404;  // Not Found
            Map<String, String> notFoundErrorResponse = new Map<String, String>{
                'Message' => 'Compte non trouvé, mise à jour impossible.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(notFoundErrorResponse));
            return;
        }
        Account accountToUpdate = accounts[0];
        
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
        
        
        //Etape 4 : Préparation de la mise à jour des données du contact 
        for (String field : reqbodyMap.keySet()) {
            Object newValue = reqbodyMap.get(field);
            if (newValue != null) {
                accountToUpdate.put(field, newValue);
            }
        }
        
        
        //Etape 5 : Mise à jour du contact
        try {
            update accountToUpdate;
            res.statusCode = 200;  // OK success code
            Map<String, String> successResponse = new Map<String, String>{
                'Message' => 'Compte mis à jour avec succès.',
                    'AccountId' => accountToUpdate.Id
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(successResponse));
        } catch (DmlException e) {
            res.statusCode = 500;  // Internal Server Error
            Map<String, String> updateErrorMessageMap = new Map<String, String>{
                'Message' => 'Erreur lors de la mise à jour du compte.',
                    'Error' => e.getMessage()
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(updateErrorMessageMap));
        }    
    }
    
    
    
}
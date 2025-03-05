@RestResource(urlMapping='/contacts/*')

/*Pour l'intégralité de ce code, les status.code font référence à la documentation officielle Salesforce : 
* https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm */


global with sharing class ContactAPI {
    
    //CONTACT01 : Création d’un contact avec vérification de l’email
    
    @HttpPost
    global static void createContactRest(){
        
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        //Etape 1 : Récupérer les données de la requête API et renvoyer une erreur si aucune n'est fournie
        String requestBody = req.requestBody.toString();
        if (String.isBlank(requestBody)) {
            res.statusCode = 400;
            Map<String, String> unvalidRequestErrorResponse = new Map<String, String>{
                'Message' => 'Aucune donnée fournie pour la création du contact.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(unvalidRequestErrorResponse));
            return;
        }
        
        Map<String, Object> reqbodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        
        //Etape 2 : Renvoyer une erreur si l'adresse mail du contact à créer n'est pas fournie ou est incorrecte
        String reqEmail = (String) reqbodyMap.get('Email');
        String emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'; 
        if (String.isBlank(reqEmail) || !Pattern.matches(emailRegex, reqEmail)) {
            res.statusCode = 400;  // Bad Request
            Map<String, String> badRequestMessageMap = new Map<String, String>{
                'Message' => 'Email valide obligatoire.'};
                    res.responseBody = Blob.valueOf(JSON.serialize(badRequestMessageMap));
            return;            
        }
        
        
        //Etape 2.1 : Vérifier si le contact existe déjà dans Salesforce
        List<Contact> existingContact = [SELECT Id FROM Contact WHERE Email = :reqEmail LIMIT 1];
        
        //Etape 2.2 : Renvoyer l'ID du contact déjà existant 
        if(existingContact.size() >0){
            res.statusCode = 200;  // OK success code
            Map<String, String> successMessageMap = new Map<String, String>{
                'Message' => 'Contact déjà existant.',
                    'ContactId' => existingContact[0].Id
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(successMessageMap));
            return;
        } 
        
        //Etape 3 : Créer le contact non existant dans Salesforce
        Contact newContact = new Contact();
for (String fieldName : reqbodyMap.keySet()) {
        newContact.put(fieldName, reqbodyMap.get(fieldName));
    }
             
        
        //Etape 4 : Insérer le nouveau contact dans la base de données 
        try {
            insert newContact;
            res.statusCode = 201;  // Created Success Code
        Map<String, String> insertSuccessMessageMap = new Map<String, String>{
            'Message' => 'Contact créé avec succès.',
                'ContactId' => newContact.Id
                };
                    res.responseBody = Blob.valueOf(JSON.serialize(insertSuccessMessageMap));       
    }     catch (DmlException e) {
            res.statusCode = 500;  // Internal Server Error
            Map<String, String> insertErrorMessageMap = new Map<String, String>{
                'Message' => 'Echec de création du contact.',
                    'Error' => e.getMessage()
                    }; 
                        res.responseBody = Blob.valueOf(JSON.serialize(insertErrorMessageMap));
            return;
        }
    }

    
    //CONTACT02 : Modification d’un contact
    @HttpPatch
    global static void updateContactRest(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Etape 1 : Récupérer l'ID du contact et renvoyer une erreur s'il n'est pas valide
        String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        if (String.isBlank(contactId) || !Pattern.matches('^\\w{15,18}$', contactId)) {
            res.statusCode = 400;  // Bad Request
            Map<String, String> badRequestMessageResponse = new Map<String, String>{
                'Message' => 'ID du contact invalide ou manquant.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(badRequestMessageResponse));
            return;
        }
        
        //Etape 2 : Récupérer le contact à modifier et renvoyer une erreur si le contact n'a pas été trouvé  
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];   
        if (contacts.isEmpty()) {
            res.statusCode = 404;  // Not Found
            Map<String, String> notFoundErrorResponse = new Map<String, String>{
                'Message' => 'Contact non trouvé, mise à jour impossible.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(notFoundErrorResponse));
            return;
        }
        Contact contactToUpdate = contacts[0];
        
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
        Boolean isUpdated = false;
        for (String field : reqbodyMap.keySet()) {
            Object newValue = reqbodyMap.get(field);
            if (newValue != null) {
                contactToUpdate.put(field, newValue);
                isUpdated = true;
            }
        }
        
        //Etape 5.1 : Pas de mise à jour nécessaire 
        if (!isUpdated) {
            res.statusCode = 200;  // OK success code
            Map<String, String> noUpdateMessageMap = new Map<String, String>{
                'Message' => 'Aucune mise à jour effectuée, les données sont déjà à jour.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(noUpdateMessageMap));
            return;
        }
        
        
        //Etape 5.2 : Mise à jour du contact
        try {
            update contactToUpdate;
            res.statusCode = 200;  // OK success code
            Map<String, String> successResponse = new Map<String, String>{
                'Message' => 'Contact mis à jour avec succès.',
                    'ContactId' => contactToUpdate.Id
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(successResponse));
        } catch (DmlException e) {
            res.statusCode = 500;  // Internal Server Error
            Map<String, String> updateErrorMessageMap = new Map<String, String>{
                'Message' => 'Erreur lors de la mise à jour du contact.',
                    'Error' => e.getMessage()
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(updateErrorMessageMap));
        }    
    }
    
    //CONTACT03 : Désactivation d’un contact
    @HttpDelete
    global static void deactivateContactRest(){
        
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Etape 1 : Récupérer l'ID du contact et renvoyer une erreur s'il n'est pas valide
        String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        if (String.isBlank(contactId) || !Pattern.matches('^\\w{15,18}$', contactId)) {
            res.statusCode = 400;  // Bad Request
            Map<String, String> badRequestMessageResponse = new Map<String, String>{
                'Message' => 'ID du contact invalide ou manquant.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(badRequestMessageResponse));
            return;
        }
        
        
        // Etape 2 : Récupérer le contact à supprimer et renvoyer une erreur si le contact n'a pas été trouvé  
        List<Contact> contacts = [SELECT Id, Is_Active__c FROM Contact WHERE Id = :contactId LIMIT 1];   
        if (contacts.isEmpty()) {
            res.statusCode = 404;  // Not Found
            Map<String, String> notFoundErrorResponse = new Map<String, String>{
                'Message' => 'Contact non trouvé, mise à jour impossible.'
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(notFoundErrorResponse));
            return;
        }
        Contact contactToDeactivate = contacts[0];
                
        
        // Etape 3 : Mettre à jour le champ Is_Active__c du contact à false pour le marquer comme inactif
        try {
            contactToDeactivate.Is_Active__c = false;  
            update contactToDeactivate;  
            res.statusCode = 200;  // OK success code
            Map<String, String> deactivationSuccessResponse = new Map<String, String>{
                'Message' => 'Contact désactivé avec succès.',
                    'ContactId' => contactToDeactivate.Id
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(deactivationSuccessResponse));
        } catch (DmlException e) {
            res.statusCode = 500;  // Internal Server Error
            Map<String, String> deactivationErrorMessageMap = new Map<String, String>{
                'Message' => 'Erreur lors de la désactivation du contact.',
                    'Error' => e.getMessage()
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(deactivationErrorMessageMap));
        }
        
    }  
    
}
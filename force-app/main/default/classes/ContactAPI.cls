@RestResource(urlMapping='/contacts/*')

/*Pour l'intégralité de ce code, les status.code font référence à la documentation officielle Salesforce : 
* https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm */


global with sharing class ContactAPI {
    
    //CONTACT01 : Création d’un contact avec vérification de l’email
    
    @HttpPost
    global static void createContactRest(String contactLastName, String contactFirstName, String contactEmail, String contactPhone){
        
        RestResponse res = Restcontext.response;
        
        //Etape 1 : Renvoyer une erreur si l'adresse mail du contact à créer n'est pas fournie ou est incorrecte
        String emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'; 
        if (String.isBlank(contactEmail) || !Pattern.matches(emailRegex, contactEmail)) {
            res.statusCode = 400;  // Bad Request
            Map<String, String> badRequestMessageMap = new Map<String, String>{
                'Message' => 'Email valide obligatoire.'};
                    res.responseBody = Blob.valueOf(JSON.serialize(badRequestMessageMap));
            return;            
        }
        
        
        //Etape 2.1 : Vérifier si le contact existe déjà dans Salesforce
        List<Contact> existingContact = [SELECT Id FROM Contact WHERE Email = :contactEmail LIMIT 1];
        
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
        
        //Etape 3.1 : Créer le contact non existant dans Salesforce
        Contact newContact = new Contact(
            LastName = contactLastName,
            FirstName = contactFirstName,
            Email = contactEmail,
            Phone = contactPhone);
        
        //Etape 3.2 : Insérer le nouveau contact dans la base de données 
        try {
            insert newContact;
        } catch (DmlException e) {
            res.statusCode = 500;  // Internal Server Error
            Map<String, String> insertErrorMessageMap = new Map<String, String>{
                'Message' => 'Echec de création du contact.',
                    'Error' => e.getMessage()
                    }; 
                        res.responseBody = Blob.valueOf(JSON.serialize(insertErrorMessageMap));
            return;
        }
        
        //Etape 3.3 : Renvoyer l'ID du contact créé 
        res.statusCode = 201;  // Created Success Code
        Map<String, String> insertSuccessMessageMap = new Map<String, String>{
            'Message' => 'Contact créé avec succès.',
                'ContactId' => newContact.Id
                };
                    res.responseBody = Blob.valueOf(JSON.serialize(insertSuccessMessageMap));
        
    }   
}
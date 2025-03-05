@isTest
public class ContactUpdateAPITest {
    
      // Test Setup : Création d'un contact de base utilisé dans les tests
    @testSetup
    public static void createTestContact() {
        // Créer un contact de test avec des valeurs spécifiques
        Contact testContact = new Contact(
            LastName = 'Sarah',
            FirstName = 'Parker',
            Email = 'sarahparker@test.com',
            Phone = '123-456-7890',
            Is_Active__c = true
        );
        
        insert testContact;
    }

}
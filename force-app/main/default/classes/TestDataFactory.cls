/**
 * Cette classe fournit des méthodes pour créer des enregistrements de test pour les objets Contact, Account, et Contract.
 * Elle permet également d'insérer ces enregistrements dans la base de données Salesforce si nécessaire.
 * 
 */

@isTest
public class TestDataFactory {
    
    // Création d'un contact de test
    /**
     * @description createTestContact Création d'un contact de test.
     * @param  doInsert doInsert Si vrai, l'enregistrement est inséré dans la base de données.
     * @return          return Le contact créé.
     */
    public static Contact createTestContact(Boolean doInsert) {
        Contact testContact = new Contact(
            LastName = 'Sarah',
            FirstName = 'Parker',
            Email = 'sarahparker@test.com',
            Phone = '123-456-7890',
            Is_Active__c = true
        );
        
        if (doInsert) {
            insert testContact;
        }
        
        return testContact;
    }

    // Création d'un compte de test
    /**
     * @description createTestAccount Création d'un compte de test.
     * @param  doInsert doInsert Si vrai, l'enregistrement est inséré dans la base de données.
     * @return          return Le compte créé.
     */
    public static Account createTestAccount(Boolean doInsert) {
        Account testAccount = new Account(
            Name = 'Test Account', 
            Phone = '0000000000',
            AccountNumber = 'BE4Update'
        );

        if (doInsert) {
            insert testAccount;
        }

        return testAccount;
    }

    // Création d'un contrat de test
    /**
     * @description createTestContract Création d'un contrat de test
     * @param  doInsert doInsert Si vrai, l'enregistrement est inséré dans la base de données.
     * @return          return Le contrat créé.
     */
    public static Contract createTestContract(Boolean doInsert) {
        Account testAccount = createTestAccount(true); // Insère un compte avant d'associer le contrat
        
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            ContractTerm = 12,
            Status = 'Draft',
            StartDate = Date.today(),
            Name = 'Test Contract'
        );

        if (doInsert) {
            insert testContract;
        }

        return testContract;
    }
}
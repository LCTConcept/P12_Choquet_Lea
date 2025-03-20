@isTest
public class TestDataFactory {
    
    // Création d'un contact de test
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
    public static Account createTestAccount(Boolean doInsert) {
        Account testAccount = new Account(
            Name = 'Test Account'
        );

        if (doInsert) {
            insert testAccount;
        }

        return testAccount;
    }

    // Création d'un contrat de test
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
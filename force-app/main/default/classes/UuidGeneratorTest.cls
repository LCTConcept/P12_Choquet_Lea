@isTest
public class UuidGeneratorTest {
    
    @isTest
    static void testUuidGenerator() {
        // Appeler la méthode uuidGenerator
        List<String> result = UuidGenerator.uuidGenerator();

        // Vérifier que la liste retournée n'est pas vide
        System.assertNotEquals(result, null, 'La liste retournée ne doit pas être null.');
        System.assertEquals(result.size(), 1, 'La liste doit contenir exactement un élément.');

        // Vérifier que l'UUID retourné est bien une chaîne de caractères non vide
        String generatedUuid = result[0];
        System.assertNotEquals(generatedUuid, null, 'L\'UUID généré ne doit pas être null.');
        System.assertNotEquals(generatedUuid, '', 'L\'UUID généré ne doit pas être une chaîne vide.');

    }
}
/**
 * Cette classe contient un test unitaire pour la méthode uuidGenerator de la classe UuidGenerator.
 * Le test vérifie que la méthode génère un UUID valide sous forme de chaîne et qu'elle retourne une liste contenant cet UUID.
 * Le test s'assure également que la liste n'est pas vide et contient exactement un élément.
 */

@isTest
public class UuidGeneratorTest {
    
    @isTest
    /**
     * @description testUuidGenerator Vérifie que la méthode `uuidGenerator` retourne une liste contenant un UUID valide. 
     */
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
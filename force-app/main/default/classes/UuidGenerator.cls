/**
 * Cette classe contient une méthode invocable permettant de générer un UUID unique.
 * La méthode génère un UUID et le retourne sous forme de liste de chaînes.
 * Elle est appelée comme action dans des flows. 
 * 
 */

global class UuidGenerator {
    
    /**
     * @description uuidGenerator Méthode invocable permettant de générer un UUID unique.
     * @return   return Une liste contenant un UUID sous forme de chaîne.
     */
    @InvocableMethod(label='UUID Generator' description='Generate unique UUID for the contacts')
    public static List<String> uuidGenerator(){
        List<String> uuidList = new List<String>();
        UUID randomUUID = UUID.randomUUID();
        system.debug(randomUUID);
        uuidList.add(UUID.randomUUID().toString());
        return uuidList;
    }
}
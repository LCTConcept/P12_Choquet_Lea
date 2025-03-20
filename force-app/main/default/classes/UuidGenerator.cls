global class UuidGenerator {
    
    @InvocableMethod(label='UUID Generator' description='Generate unique UUID for the contacts')
    public static List<String> uuidGenerator(){
        List<String> uuidList = new List<String>();
        UUID randomUUID = UUID.randomUUID();
        system.debug(randomUUID);
        uuidList.add(UUID.randomUUID().toString());
        return uuidList;
    }
}
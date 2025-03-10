/**
 * @class CleverTapDataMapper
 * @description Helper class for mapping Salesforce records to CleverTap format.
 */
public with sharing class CleverTapDataMapper {
    
    /**
     * @description Maps a Salesforce record to CleverTap format
     * @param record The Salesforce record to map
     * @param recordType The type of record
     * @return The mapped record in CleverTap format
     */
    public static Map<String, Object> mapToCleverTap(SObject record, String recordType) {
        if (record == null) {
            return null;
        }
        
        try {
            List<CleverTap_Mapping__c> fieldMappings = getFieldMappings(recordType);
            if (fieldMappings.isEmpty()) {
                return null;
            }
            
            CleverTap_Mapping__c identityMapping = findIdentityMapping(fieldMappings);
            if (identityMapping == null) {
                return null;
            }
            
            String identityValue = getIdentityValue(record, identityMapping);
            if (String.isBlank(identityValue)) {
                return null;
            }
            
            Map<String, Object> profileData = createProfileData(record, fieldMappings);
            return createFinalPayload(identityValue, profileData);
        } catch (Exception e) {
            //System.debug(LoggingLevel.ERROR, 'Error mapping ' + recordType + ' to CleverTap: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * @description Gets the field mappings for a record type
     * @param recordType The record type
     * @return List of field mappings
     */
    private static List<CleverTap_Mapping__c> getFieldMappings(String recordType) {
        // Check CRUD permissions
        if (!CleverTap_Mapping__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() || 
            !CleverTap_Sync_Configuration__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()) {
            return new List<CleverTap_Mapping__c>();
        }
        
        return [
            SELECT Id, CleverTap_Field__c, Salesforce_Field__c, 
                   Data_Type__c, Is_Mandatory__c
            FROM CleverTap_Mapping__c
            WHERE Sync_Configuration__c IN (
                SELECT Id FROM CleverTap_Sync_Configuration__c 
                WHERE Salesforce_Entity__c = :recordType 
                AND Status__c = 'Active'
            )
        ];
    }
    
    /**
     * @description Finds the identity mapping (customer_id)
     * @param fieldMappings The list of field mappings
     * @return The identity mapping
     */
    private static CleverTap_Mapping__c findIdentityMapping(List<CleverTap_Mapping__c> fieldMappings) {
        for (CleverTap_Mapping__c mapping : fieldMappings) {
            if (mapping.Is_Mandatory__c && mapping.CleverTap_Field__c == 'customer_id') {
                return mapping;
            }
        }
        return null;
    }
    
    /**
     * @description Gets the identity value from the record
     * @param record The Salesforce record
     * @param identityMapping The identity mapping
     * @return The identity value
     */
    private static String getIdentityValue(SObject record, CleverTap_Mapping__c identityMapping) {
        return String.valueOf(record.get(identityMapping.Salesforce_Field__c));
    }
    
    /**
     * @description Creates the profile data map
     * @param record The Salesforce record
     * @param fieldMappings The field mappings
     * @return The profile data map
     */
    private static Map<String, Object> createProfileData(SObject record, List<CleverTap_Mapping__c> fieldMappings) {
        Map<String, Object> profileData = new Map<String, Object>();
        
        for (CleverTap_Mapping__c mapping : fieldMappings) {
            Object fieldValue = record.get(mapping.Salesforce_Field__c);
            
            if (fieldValue != null) {
                Object convertedValue = CleverTapDataConverter.convertFieldValue(
                    fieldValue, mapping.Data_Type__c
                );
                profileData.put(mapping.CleverTap_Field__c, convertedValue);
            }
        }
        
        // Add timestamp
        profileData.put('Timestamp', DateTime.now().format());
        
        return profileData;
    }
    
    /**
     * @description Creates the final payload
     * @param identityValue The identity value
     * @param profileData The profile data
     * @return The final payload
     */
    private static Map<String, Object> createFinalPayload(String identityValue, Map<String, Object> profileData) {
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('identity', identityValue);
        payload.put('type', 'profile');
        payload.put('$source', 'SFDC');
        payload.put('profileData', profileData);
        return payload;
    }
}
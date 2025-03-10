/**
 * @class FieldMappingManager
 * @description Manager class for handling field mapping operations.
 * Handles CRUD operations for CleverTap_Mapping__c records.
 */
public with sharing class FieldMappingManager {
    
    /**
     * @description Gets existing field mappings for a sync configuration
     * @param syncId The ID of the sync configuration
     * @return List of field mappings
     * @throws AuraHandledException If there is an error accessing the mappings
     */
    @AuraEnabled
    public static List<CleverTap_Mapping__c> getExistingMappings(Id syncId) {
        if (!CleverTap_Mapping__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()) {
            throw new AuraHandledException('You do not have access to field mappings');
        }
        
        return [
            SELECT Id, CleverTap_Field__c, Salesforce_Field__c, 
                   Data_Type__c, Is_Mandatory__c
            FROM CleverTap_Mapping__c
            WHERE Sync_Configuration__c = :syncId
        ];
    }
    
    /**
     * @description Saves field mappings for a sync configuration
     * @param mappingData JSON string containing mapping data
     * @throws AuraHandledException If there is an error creating or validating the mappings
     */
    @AuraEnabled
    public static void saveFieldMappings(String mappingData) {
        Savepoint sp = Database.setSavepoint();
        try {
            checkMappingPermissions();
            validateMappingData(mappingData);
            
            // Parse the mapping data
            Map<String, Object> mappingsMap = parseMappingJson(mappingData);
            Id syncId = validateSyncId(mappingsMap);
            List<Object> mappingsObj = validateMappingsList(mappingsMap);

            // Process the mappings
            processFieldMappings(syncId, mappingsObj);
            
        } catch (Exception e) {
            // Rollback on error
            Database.rollback(sp);
            throw new AuraHandledException('Error saving mappings: ' + e.getMessage());
        }
    }
    
    /**
     * @description Checks if the current user has permissions to create and delete field mappings
     * @throws AuraHandledException If the user does not have sufficient permissions
     */
    private static void checkMappingPermissions() {
        if (!CleverTap_Mapping__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable() ||
            !CleverTap_Mapping__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isDeletable()) {
            throw new AuraHandledException('Insufficient permissions to manage field mappings');
        }
    }
    
    /**
     * @description Validates that the mapping data string is not empty
     * @param mappingData The mapping data string to validate
     * @throws AuraHandledException If the mapping data is blank
     */
    private static void validateMappingData(String mappingData) {
        if (String.isBlank(mappingData)) {
            throw new AuraHandledException('Mapping data cannot be empty');
        }
    }
    
    /**
     * @description Parses the mapping data JSON string into a map
     * @param mappingData The mapping data JSON string
     * @return Map<String, Object> The parsed mapping data
     * @throws AuraHandledException If the JSON is invalid
     */
    private static Map<String, Object> parseMappingJson(String mappingData) {
        try {
            return (Map<String, Object>)JSON.deserializeUntyped(mappingData);
        } catch (Exception e) {
            throw new AuraHandledException('Invalid JSON format: ' + e.getMessage());
        }
    }
    
    /**
     * @description Validates and extracts the syncId from the mappings map
     * @param mappingsMap The mappings map containing the syncId
     * @return Id The validated syncId
     * @throws AuraHandledException If the syncId is missing or invalid
     */
    private static Id validateSyncId(Map<String, Object> mappingsMap) {
        try {
            Id syncId = (Id)mappingsMap.get('syncId');
            if (syncId == null) {
                throw new AuraHandledException('SyncId is required');
            }
            return syncId;
        } catch (Exception e) {
            throw new AuraHandledException('Invalid syncId: ' + e.getMessage());
        }
    }
    
    /**
     * @description Validates and extracts the mappings list from the mappings map
     * @param mappingsMap The mappings map containing the mappings list
     * @return List<Object> The validated mappings list
     * @throws AuraHandledException If the mappings list is missing or empty
     */
    private static List<Object> validateMappingsList(Map<String, Object> mappingsMap) {
        List<Object> mappingsObj = (List<Object>)mappingsMap.get('mappings');
        if (mappingsObj == null || mappingsObj.isEmpty()) {
            throw new AuraHandledException('No mappings provided');
        }
        return mappingsObj;
    }
    
    /**
     * @description Processes the field mappings
     * @param syncId The ID of the sync configuration
     * @param mappingsObj The list of mapping objects
     * @throws AuraHandledException If there is an error processing the mappings
     */
    private static void processFieldMappings(Id syncId, List<Object> mappingsObj) {
        // Delete existing mappings
        deleteExistingMappings(syncId);
        
        // Create new mappings
        List<CleverTap_Mapping__c> newMappings = createNewMappings(syncId, mappingsObj);
        
        // Insert new mappings
        insertMappings(newMappings);
    }
    
    /**
     * @description Deletes existing field mappings for a sync configuration
     * @param syncId The ID of the sync configuration
     * @throws AuraHandledException If there is an error deleting the mappings
     */
    private static void deleteExistingMappings(Id syncId) {
        try {
            delete [SELECT Id FROM CleverTap_Mapping__c WHERE Sync_Configuration__c = :syncId];
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting existing mappings: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates new field mappings for a sync configuration
     * @param syncId The ID of the sync configuration
     * @param mappingsObj The list of mapping objects
     * @return List<CleverTap_Mapping__c> The list of new mapping records
     * @throws AuraHandledException If there is an error creating the mappings
     */
    private static List<CleverTap_Mapping__c> createNewMappings(Id syncId, List<Object> mappingsObj) {
        List<CleverTap_Mapping__c> newMappings = new List<CleverTap_Mapping__c>();
        
        for(Object mappingObj : mappingsObj) {
            Map<String, Object> mapping = (Map<String, Object>)mappingObj;
            CleverTap_Mapping__c newMapping = createMappingRecord(syncId, mapping);
            newMappings.add(newMapping);
        }
        
        return newMappings;
    }
    
    /**
     * @description Creates a single field mapping record
     * @param syncId The ID of the sync configuration
     * @param mapping The mapping data
     * @return CleverTap_Mapping__c The new mapping record
     * @throws AuraHandledException If the mapping is invalid
     */
    private static CleverTap_Mapping__c createMappingRecord(Id syncId, Map<String, Object> mapping) {
        // Validate required fields
        String targetField = (String)mapping.get('CleverTap_Field__c');
        String sourceField = (String)mapping.get('Salesforce_Field__c');
        
        if (String.isBlank(targetField)) {
            throw new AuraHandledException('Target field name is required');
        }
        if (String.isBlank(sourceField)) {
            throw new AuraHandledException('Source field name is required');
        }

        return new CleverTap_Mapping__c(
            Sync_Configuration__c = syncId,
            CleverTap_Field__c = targetField,
            Salesforce_Field__c = sourceField,
            Data_Type__c = (String)mapping.get('Data_Type__c'),
            Is_Mandatory__c = (Boolean)mapping.get('Is_Mandatory__c')
        );
    }
    
    /**
     * @description Inserts a list of field mapping records
     * @param newMappings The list of mapping records to insert
     * @throws AuraHandledException If there is an error inserting the mappings
     */
    private static void insertMappings(List<CleverTap_Mapping__c> newMappings) {
        try {
            insert newMappings;
        } catch (Exception e) {
            throw new AuraHandledException('Error inserting new mappings: ' + e.getMessage());
        }
    }
}
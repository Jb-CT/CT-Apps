/**
 * @class IntegrationSyncController
 * @description Controller class for handling CleverTap integration sync configurations and field mappings.
 * Acts as a facade for more specialized manager and utility classes.
 */
public with sharing class IntegrationSyncController {
    
    /**
     * @description Gets all sync configurations for a specific connection
     * @param connectionId The ID of the connection
     * @return List of sync configuration wrappers
     */
    @AuraEnabled(cacheable=true)
    public static List<SyncConfigurationManager.SyncConfigWrapper> getSyncConfigurations(String connectionId) {
        return SyncConfigurationManager.getSyncConfigurations(connectionId);
    }

    /**
     * @description Gets picklist values for a specific field on an object
     * @param objectName The API name of the object
     * @param fieldName The API name of the field
     * @return List of picklist options as maps with 'label' and 'value' keys
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues(String objectName, String fieldName) {
        return SchemaUtility.getPicklistValues(objectName, fieldName);
    }

    /**
     * @description Saves field mappings for a sync configuration
     * @param mappingData JSON string containing mapping data
     */
    @AuraEnabled
    public static void saveFieldMappings(String mappingData) {
        FieldMappingManager.saveFieldMappings(mappingData);
    }
    
    /**
     * @description Deletes a sync configuration
     * @param syncId The ID of the sync configuration to delete
     */
    @AuraEnabled
    public static void deleteSyncConfiguration(String syncId) {
        SyncConfigurationManager.deleteSyncConfiguration(syncId);
    }

    /**
     * @description Gets existing field mappings for a sync configuration
     * @param syncId The ID of the sync configuration
     * @return List of field mappings
     */
    @AuraEnabled
    public static List<CleverTap_Mapping__c> getExistingMappings(Id syncId) {
        return FieldMappingManager.getExistingMappings(syncId);
    }

    /**
     * @description Updates the status of a sync configuration
     * @param syncId The ID of the sync configuration
     * @param status The new status (Active/Inactive)
     */
    @AuraEnabled
    public static void updateSyncStatus(String syncId, String status) {
        SyncConfigurationManager.updateSyncStatus(syncId, status);
    }

    /**
     * @description Creates a new sync configuration
     * @param syncData JSON string containing sync configuration data
     * @return The ID of the newly created configuration
     */
    @AuraEnabled
    public static String createSyncConfiguration(String syncData) {
        return SyncConfigurationManager.createSyncConfiguration(syncData);
    }
    
    /**
     * @description Gets the accessible fields for a Salesforce object
     * @param objectName The API name of the object
     * @return List of fields as maps with 'label' and 'value' keys
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getSalesforceFields(String objectName) {
        return SchemaUtility.getAccessibleFields(objectName);
    }

    /**
     * @description Gets a sync configuration by ID
     * @param syncId The ID of the sync configuration
     * @return The sync configuration wrapper
     */
    @AuraEnabled(cacheable=true)
    public static SyncConfigurationManager.SyncConfigWrapper getSyncConfigurationById(String syncId) {
        return SyncConfigurationManager.getSyncConfigurationById(syncId);
    }

    /**
     * @description Updates a sync configuration
     * @param syncId The ID of the sync configuration to update
     * @param syncData JSON string containing updated sync configuration data
     * @return The updated sync configuration wrapper
     */
    @AuraEnabled
    public static SyncConfigurationManager.SyncConfigWrapper updateSyncConfiguration(String syncId, String syncData) {
        return SyncConfigurationManager.updateSyncConfiguration(syncId, syncData);
    }
}
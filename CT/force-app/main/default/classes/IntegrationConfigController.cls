/**
 * @class IntegrationConfigController
 * @description Controller class for managing CleverTap integration configurations.
 * Handles creation, retrieval, and deletion of custom metadata configuration records
 * for the CleverTap integration.
 */
public with sharing class IntegrationConfigController {
    
    /**
     * @description Mapping of region codes to CleverTap API endpoints
     */
    private static Map<String, String> regionToUrl = new Map<String, String>{
        'US' => 'https://us1.api.clevertap.com/1/upload',
        'IN' => 'https://in1.api.clevertap.com/1/upload',
        'EU' => 'https://eu1.api.clevertap.com/1/upload'
    };
    
    /**
     * @description Retrieves all non-deleted CleverTap configurations
     * @return List<CleverTap_Config__mdt> List of CleverTap configuration metadata records
     * @throws AuraHandledException If user lacks access or an error occurs
     */
    @AuraEnabled(cacheable=true)
    public static List<CleverTap_Config__mdt> getConfigurations() {
        try {
            // //if (!CleverTap_Config__mdt.SObjectType.getDescribe().isAccessible()){}
            if (!Schema.SObjectType.CleverTap_Config__mdt.isAccessible()) {
                throw new AuraHandledException('You do not have access to integration configurations');
            }

            @SuppressWarnings('PMD.ApexCRUDViolation')
            List<CleverTap_Config__mdt> configs = [
                SELECT DeveloperName, MasterLabel, CleverTap_Account_ID__c, 
                       CleverTap_Passcode__c, Region__c, CleverTap_API_URL__c
                FROM CleverTap_Config__mdt
                WHERE MasterLabel != '[Deleted]%'
                ORDER BY MasterLabel
            ];
            
            return configs;
        } catch (Exception e) {
            //System.debug('Error fetching configurations: ' + e.getMessage());
            throw new AuraHandledException('Error fetching configurations: ' + e.getMessage());
        }
    }

    /**
     * @description Saves a CleverTap configuration as custom metadata
     * @param config Map containing configuration details (name, region, accountId, passcode, developerName)
     * @return String Success message if the operation completes successfully
     * @throws AuraHandledException If validation fails or an error occurs
     */
    @AuraEnabled
    public static String saveConfiguration(Map<String, Object> config) {
        try {
            // Validation
            validateConfigData(config);

            // Create metadata container
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            Metadata.CustomMetadata customMetadata = prepareMetadata(config);
            mdContainer.addMetadata(customMetadata);

            // Deploy metadata
            if (!Test.isRunningTest()) {
                //Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
                Metadata.Operations.enqueueDeployment(mdContainer, null);
                //System.debug('Deployment Job ID: ' + jobId);
            }
            
            return 'Success';
        } catch (Exception e) {
            //System.debug('Error saving configuration: ' + e.getMessage());
            throw new AuraHandledException('Error saving configuration: ' + e.getMessage());
        }
    }

    /**
     * @description Soft deletes a CleverTap configuration by clearing sensitive data
     * @param developerName The developerName of the configuration to delete
     * @return String Success message if the operation completes successfully
     * @throws AuraHandledException If validation fails or an error occurs
     */
    @AuraEnabled
    public static String deleteConfiguration(String developerName) {
        try {
            if (String.isBlank(developerName)) {
                throw new AuraHandledException('Developer name is required for deletion');
            }
            
            @SuppressWarnings('PMD.ApexCRUDViolation')
            // First, verify the record exists
            List<CleverTap_Config__mdt> existingConfigs = [
                SELECT Id, DeveloperName, MasterLabel 
                FROM CleverTap_Config__mdt 
                WHERE DeveloperName = :developerName
                LIMIT 1
            ];

            if (existingConfigs.isEmpty()) {
                throw new AuraHandledException('Configuration not found');
            }

            // Prepare the metadata deployment
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            
            // Create metadata for updating the record
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = 'CleverTap_Config__mdt.' + developerName;
            customMetadata.label = '[DELETED] ' + existingConfigs[0].MasterLabel;

            // Create a list to hold the field updates
            List<Metadata.CustomMetadataValue> fields = new List<Metadata.CustomMetadataValue>();
            
            // Clear all sensitive fields
            Map<String, String> fieldsToUpdate = new Map<String, String>{
                'CleverTap_Account_ID__c' => '',
                'CleverTap_Passcode__c' => '',
                'Region__c' => '',
                'CleverTap_API_URL__c' => ''
            };
            
            // Add each field to the metadata
            for (String fieldName : fieldsToUpdate.keySet()) {
                fields.add(createMetadataValue(fieldName, fieldsToUpdate.get(fieldName)));
            }
            
            customMetadata.values = fields;
            mdContainer.addMetadata(customMetadata);

            if (!Test.isRunningTest()) {
                //Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
                Metadata.Operations.enqueueDeployment(mdContainer, null);
                //System.debug('Deletion deployment job ID: ' + jobId);
            }
            
            return 'Success';
        } catch (Exception e) {
            //System.debug('Error in deleteConfiguration: ' + e.getMessage());
            //System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description Validates configuration data for required fields
     * @param config Map containing configuration details to validate
     * @throws AuraHandledException If required fields are missing
     */
    private static void validateConfigData(Map<String, Object> config) {
        if (!config.containsKey('name') || String.isBlank((String)config.get('name'))) {
            throw new AuraHandledException('Connection name is required');
        }

        String region = (String)config.get('region');
        if (String.isBlank(region)) {
            throw new AuraHandledException('Region is required');
        }
    }
    
    /**
     * @description Prepares custom metadata structure for deployment
     * @param config Map containing configuration details
     * @return Metadata.CustomMetadata The prepared metadata for deployment
     */
    private static Metadata.CustomMetadata prepareMetadata(Map<String, Object> config) {
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        String connectionName = (String)config.get('name');
        String region = (String)config.get('region');
        
        // Determine fullName
        if (config.containsKey('developerName') && String.isNotBlank((String)config.get('developerName'))) {
            customMetadata.fullName = 'CleverTap_Config__mdt.' + (String)config.get('developerName');
        } else {
            String safeName = generateSafeName(connectionName);
            customMetadata.fullName = 'CleverTap_Config__mdt.' + safeName;
        }
        
        customMetadata.label = connectionName;

        // Add fields
        List<Metadata.CustomMetadataValue> fields = new List<Metadata.CustomMetadataValue>();
        
        fields.add(createMetadataValue('Region__c', region));
        fields.add(createMetadataValue('CleverTap_Account_ID__c', config.get('accountId')));
        fields.add(createMetadataValue('CleverTap_Passcode__c', config.get('passcode')));
        fields.add(createMetadataValue('CleverTap_API_URL__c', regionToUrl.get(region.toUpperCase())));
        
        customMetadata.values = fields;
        return customMetadata;
    }
    
    /**
     * @description Generates a safe API name from a user-friendly name
     * @param connectionName The user-friendly connection name
     * @return String A safe API name for metadata
     */
    private static String generateSafeName(String connectionName) {
        String safeName = connectionName.replaceAll('[^a-zA-Z0-9]', '_').replaceAll('_{2,}', '_');
        // Ensure it starts with a letter
        if (!safeName.substring(0,1).isAlpha()) {
            safeName = 'INT_' + safeName;
        }
        // Truncate if necessary (max length is 40)
        if (safeName.length() > 40) {
            safeName = safeName.substring(0, 40);
        }
        return safeName;
    }
    
    /**
     * @description Creates a custom metadata field value
     * @param field The API name of the field
     * @param value The value to set for the field
     * @return Metadata.CustomMetadataValue The created metadata field value
     */
    private static Metadata.CustomMetadataValue createMetadataValue(String field, Object value) {
        Metadata.CustomMetadataValue metadataValue = new Metadata.CustomMetadataValue();
        metadataValue.field = field;
        metadataValue.value = value;
        return metadataValue;
    }
}
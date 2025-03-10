/**
 * @class IntegrationSyncControllerTest
 * @description Test class for IntegrationSyncController to ensure proper configuration and mapping handling.
 */
@isTest
private class IntegrationSyncControllerTest {
    
    /**
     * @description Setup test data for all test methods
     */
    @testSetup
    static void setupTestData() {
        // Create test connection ID
        String testConnectionId = 'TEST_CONN_123';
        
        // Create test sync configuration
        CleverTap_Sync_Configuration__c config = new CleverTap_Sync_Configuration__c(
            Name = 'Test Sync Config',
            Sync_Type__c = 'salesforce_to_clevertap',
            Salesforce_Entity__c = 'Lead',
            CleverTap_Entity__c = 'profile',
            ConnectionId__c = testConnectionId,
            Status__c = 'Active'
        );
        insert config;
        
        // Create test field mappings
        List<CleverTap_Mapping__c> mappings = new List<CleverTap_Mapping__c>();
        
        // Mandatory mapping
        mappings.add(new CleverTap_Mapping__c(
            Sync_Configuration__c = config.Id,
            CleverTap_Field__c = 'customer_id',
            Salesforce_Field__c = 'Email',
            Data_Type__c = 'Text',
            Is_Mandatory__c = true
        ));
        
        // Regular mapping
        mappings.add(new CleverTap_Mapping__c(
            Sync_Configuration__c = config.Id,
            CleverTap_Field__c = 'first_name',
            Salesforce_Field__c = 'FirstName',
            Data_Type__c = 'Text',
            Is_Mandatory__c = false
        ));
        
        insert mappings;
    }
    
    /**
     * @description Test getSyncConfigurations method
     */
    @isTest
    static void testGetSyncConfigurations() {
        // Get connection ID
        String connectionId = 'TEST_CONN_123';
        
        // Execute the method
        Test.startTest();
        List<SyncConfigurationManager.SyncConfigWrapper> configs = 
            IntegrationSyncController.getSyncConfigurations(connectionId);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, configs.size(), 'Should return one configuration');
        
        SyncConfigurationManager.SyncConfigWrapper config = configs[0];
        System.assertEquals('Test Sync Config', config.name, 'Configuration name should match');
        System.assertEquals('salesforce_to_clevertap', config.syncType, 'Sync type should match');
        System.assertEquals('Lead', config.sourceEntity, 'Source entity should match');
        System.assertEquals('profile', config.targetEntity, 'Target entity should match');
        System.assertEquals('Active', config.status, 'Status should match');
    }
    
    /**
     * @description Test getPicklistValues method
     */
    @isTest
    static void testGetPicklistValues() {
        Test.startTest();
        List<Map<String, String>> picklistValues = 
            IntegrationSyncController.getPicklistValues('CleverTap_Mapping__c', 'Data_Type__c');
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(0, picklistValues.size(), 'Should return picklist values');
        
        // Verify common values are present
        Boolean hasTextType = false;
        for (Map<String, String> option : picklistValues) {
            if (option.get('value') == 'Text') {
                hasTextType = true;
                break;
            }
        }
        System.assertEquals(true, hasTextType, 'Should include Text data type');
    }
    
    /**
     * @description Test saveFieldMappings method
     */
    @isTest
    static void testSaveFieldMappings() {
        // Get existing configuration
        CleverTap_Sync_Configuration__c config = [
            SELECT Id, Name FROM CleverTap_Sync_Configuration__c LIMIT 1
        ];
        
        // Prepare test mapping data
        Map<String, Object> mappingDataMap = new Map<String, Object>();
        mappingDataMap.put('syncId', config.Id);
        
        List<Map<String, Object>> mappings = new List<Map<String, Object>>();
        
        // Add mandatory customer_id mapping
        Map<String, Object> mandatoryMapping = new Map<String, Object>{
            'CleverTap_Field__c' => 'customer_id',
            'Salesforce_Field__c' => 'Email',
            'Data_Type__c' => 'Text',
            'Is_Mandatory__c' => true
        };
        
        // Add a new additional mapping
        Map<String, Object> additionalMapping = new Map<String, Object>{
            'CleverTap_Field__c' => 'last_name',
            'Salesforce_Field__c' => 'LastName',
            'Data_Type__c' => 'Text',
            'Is_Mandatory__c' => false
        };
        
        mappings.add(mandatoryMapping);
        mappings.add(additionalMapping);
        mappingDataMap.put('mappings', mappings);
        
        String mappingDataJson = JSON.serialize(mappingDataMap);
        
        // Execute the method
        Test.startTest();
        IntegrationSyncController.saveFieldMappings(mappingDataJson);
        Test.stopTest();
        
        // Verify results
        List<CleverTap_Mapping__c> updatedMappings = [
            SELECT CleverTap_Field__c, Salesforce_Field__c, Is_Mandatory__c
            FROM CleverTap_Mapping__c
            WHERE Sync_Configuration__c = :config.Id
            ORDER BY Is_Mandatory__c DESC
        ];
        
        // Should have 2 mappings (1 mandatory, 1 regular)
        System.assertEquals(2, updatedMappings.size(), 'Should have 2 mappings after update');
        
        // First should be the mandatory mapping
        System.assertEquals('customer_id', updatedMappings[0].CleverTap_Field__c, 
            'First mapping should be customer_id');
        System.assertEquals(true, updatedMappings[0].Is_Mandatory__c, 
            'customer_id mapping should be mandatory');
        
        // Second should be the new last_name mapping
        System.assertEquals('last_name', updatedMappings[1].CleverTap_Field__c, 
            'Second mapping should be last_name');
        System.assertEquals('LastName', updatedMappings[1].Salesforce_Field__c, 
            'Second mapping should map to LastName field');
    }
    
    /**
     * @description Test saveFieldMappings with invalid data
     */
    @isTest
    static void testSaveFieldMappingsInvalidData() {
        // Test with empty data
        Test.startTest();
        try {
            IntegrationSyncController.saveFieldMappings('');
            System.assert(false, 'Should have thrown exception for empty data');
        } catch (AuraHandledException e) {
            // Expected exception
            System.assert(e != null, 'AuraHandledException should be thrown for empty data');
        }
        
        // Test with invalid JSON
        try {
            IntegrationSyncController.saveFieldMappings('not valid json');
            System.assert(false, 'Should have thrown exception for invalid JSON');
        } catch (AuraHandledException e) {
            // Expected exception
            System.assert(e != null, 'AuraHandledException should be thrown for invalid JSON');
        }
        
        // Test with missing syncId
        try {
            Map<String, Object> invalidMap = new Map<String, Object>{
                'mappings' => new List<Object>()
            };
            IntegrationSyncController.saveFieldMappings(JSON.serialize(invalidMap));
            System.assert(false, 'Should have thrown exception for missing syncId');
        } catch (AuraHandledException e) {
            // Expected exception
            System.assert(e != null, 'AuraHandledException should be thrown for missing syncId');
        }
        
        // Test with empty mappings list
        try {
            // Create a valid-looking ID without hardcoding
            Id mockId = UserInfo.getOrganizationId(); // Using Org ID as a valid ID pattern
            
            Map<String, Object> invalidMap = new Map<String, Object>{
                'syncId' => mockId,
                'mappings' => new List<Object>()
            };
            IntegrationSyncController.saveFieldMappings(JSON.serialize(invalidMap));
            System.assert(false, 'Should have thrown exception for empty mappings');
        } catch (AuraHandledException e) {
            // Expected exception
            System.assert(e != null, 'AuraHandledException should be thrown for empty mappings');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getExistingMappings method
     */
    @isTest
    static void testGetExistingMappings() {
        // Get existing configuration
        CleverTap_Sync_Configuration__c config = [
            SELECT Id FROM CleverTap_Sync_Configuration__c LIMIT 1
        ];
        
        // Execute the method
        Test.startTest();
        List<CleverTap_Mapping__c> mappings = 
            IntegrationSyncController.getExistingMappings(config.Id);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(2, mappings.size(), 'Should return 2 mappings');
        
        // Verify mappings content
        Boolean hasCustomerId = false;
        Boolean hasFirstName = false;
        
        for (CleverTap_Mapping__c mapping : mappings) {
            if (mapping.CleverTap_Field__c == 'customer_id') {
                hasCustomerId = true;
                System.assertEquals(true, mapping.Is_Mandatory__c, 'customer_id should be mandatory');
            }
            if (mapping.CleverTap_Field__c == 'first_name') {
                hasFirstName = true;
                System.assertEquals(false, mapping.Is_Mandatory__c, 'first_name should not be mandatory');
            }
        }
        
        System.assertEquals(true, hasCustomerId, 'Should include customer_id mapping');
        System.assertEquals(true, hasFirstName, 'Should include first_name mapping');
    }
    
    /**
     * @description Test updateSyncStatus method
     */
    @isTest
    static void testUpdateSyncStatus() {
        // Get existing configuration
        CleverTap_Sync_Configuration__c config = [
            SELECT Id, Status__c FROM CleverTap_Sync_Configuration__c LIMIT 1
        ];
        
        // Verify initial status
        System.assertEquals('Active', config.Status__c, 'Initial status should be Active');
        
        // Execute the method to deactivate
        Test.startTest();
        IntegrationSyncController.updateSyncStatus(config.Id, 'Inactive');
        Test.stopTest();
        
        // Verify status change
        config = [SELECT Status__c FROM CleverTap_Sync_Configuration__c WHERE Id = :config.Id];
        System.assertEquals('Inactive', config.Status__c, 'Status should be updated to Inactive');
    }
    
    /**
     * @description Test createSyncConfiguration method
     */
    @isTest
    static void testCreateSyncConfiguration() {
        // Prepare data for new configuration
        String connectionId = 'TEST_CONN_456';
        Map<String, Object> syncData = new Map<String, Object>{
            'name' => 'New Test Config',
            'syncType' => 'salesforce_to_clevertap',
            'sourceEntity' => 'Contact',
            'targetEntity' => 'profile',
            'connectionId' => connectionId
        };
        
        // Execute the method
        Test.startTest();
        String newConfigId = IntegrationSyncController.createSyncConfiguration(JSON.serialize(syncData));
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, newConfigId, 'Should return new configuration Id');
        
        // Query the new configuration
        CleverTap_Sync_Configuration__c newConfig = [
            SELECT Name, Salesforce_Entity__c, CleverTap_Entity__c, Status__c, ConnectionId__c
            FROM CleverTap_Sync_Configuration__c
            WHERE Id = :newConfigId
        ];
        
        System.assertEquals('New Test Config', newConfig.Name, 'Name should match');
        System.assertEquals('Contact', newConfig.Salesforce_Entity__c, 'Source entity should match');
        System.assertEquals('profile', newConfig.CleverTap_Entity__c, 'Target entity should match');
        System.assertEquals('Active', newConfig.Status__c, 'Status should be Active');
        System.assertEquals(connectionId, newConfig.ConnectionId__c, 'Connection ID should match');
    }
    
    /**
     * @description Test getSyncConfigurationById method
     */
    @isTest
    static void testGetSyncConfigurationById() {
        // Get existing configuration
        CleverTap_Sync_Configuration__c config = [
            SELECT Id FROM CleverTap_Sync_Configuration__c LIMIT 1
        ];
        
        // Execute the method
        Test.startTest();
        SyncConfigurationManager.SyncConfigWrapper wrapper = 
            IntegrationSyncController.getSyncConfigurationById(config.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, wrapper, 'Should return a config wrapper');
        System.assertEquals('Test Sync Config', wrapper.name, 'Name should match');
        System.assertEquals('salesforce_to_clevertap', wrapper.syncType, 'Sync type should match');
        System.assertEquals('Lead', wrapper.sourceEntity, 'Source entity should match');
        System.assertEquals('profile', wrapper.targetEntity, 'Target entity should match');
        System.assertEquals('Active', wrapper.status, 'Status should match');
    }
    
    /**
     * @description Test updateSyncConfiguration method
     */
    @isTest
    static void testUpdateSyncConfiguration() {
        // Get existing configuration
        CleverTap_Sync_Configuration__c config = [
            SELECT Id FROM CleverTap_Sync_Configuration__c LIMIT 1
        ];
        
        // Prepare update data
        Map<String, Object> updateData = new Map<String, Object>{
            'name' => 'Updated Test Config',
            'syncType' => 'salesforce_to_clevertap',
            'sourceEntity' => 'Account',
            'targetEntity' => 'profile'
        };
        
        // Execute the method
        Test.startTest();
        SyncConfigurationManager.SyncConfigWrapper updatedWrapper = 
            IntegrationSyncController.updateSyncConfiguration(config.Id, JSON.serialize(updateData));
        Test.stopTest();
        
        // Verify results from wrapper
        System.assertEquals('Updated Test Config', updatedWrapper.name, 'Name should be updated');
        System.assertEquals('Account', updatedWrapper.sourceEntity, 'Source entity should be updated');
        
        // Verify database update
        CleverTap_Sync_Configuration__c updatedConfig = [
            SELECT Name, Salesforce_Entity__c
            FROM CleverTap_Sync_Configuration__c
            WHERE Id = :config.Id
        ];
        
        System.assertEquals('Updated Test Config', updatedConfig.Name, 'Name should be updated in database');
        System.assertEquals('Account', updatedConfig.Salesforce_Entity__c, 
            'Source entity should be updated in database');
    }
    
    /**
     * @description Test deleteSyncConfiguration method
     */
    @isTest
    static void testDeleteSyncConfiguration() {
        // Get existing configuration
        CleverTap_Sync_Configuration__c config = [
            SELECT Id FROM CleverTap_Sync_Configuration__c LIMIT 1
        ];
        
        // Count mappings before delete
        Integer initialMappingCount = [
            SELECT COUNT() FROM CleverTap_Mapping__c WHERE Sync_Configuration__c = :config.Id
        ];
        System.assertEquals(2, initialMappingCount, 'Should have 2 mappings initially');
        
        // Execute the method
        Test.startTest();
        IntegrationSyncController.deleteSyncConfiguration(config.Id);
        Test.stopTest();
        
        // Verify configuration deleted
        List<CleverTap_Sync_Configuration__c> remainingConfigs = [
            SELECT Id FROM CleverTap_Sync_Configuration__c WHERE Id = :config.Id
        ];
        System.assertEquals(0, remainingConfigs.size(), 'Configuration should be deleted');
        
        // Verify cascade delete of mappings
        List<CleverTap_Mapping__c> remainingMappings = [
            SELECT Id FROM CleverTap_Mapping__c WHERE Sync_Configuration__c = :config.Id
        ];
        System.assertEquals(0, remainingMappings.size(), 'Related mappings should be deleted');
    }
    
    /**
     * @description Test getSalesforceFields method
     */
    @isTest
    static void testGetSalesforceFields() {
        // Execute the method for Lead object
        Test.startTest();
        List<Map<String, String>> leadFields = IntegrationSyncController.getSalesforceFields('Lead');
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(0, leadFields.size(), 'Should return Lead fields');
        
        // Check for common fields
        Boolean hasEmailField = false;
        Boolean hasLastNameField = false;
        
        for (Map<String, String> field : leadFields) {
            if (field.get('value') == 'Email') {
                hasEmailField = true;
            }
            if (field.get('value') == 'LastName') {
                hasLastNameField = true;
            }
        }
        
        System.assertEquals(true, hasEmailField, 'Should include Email field');
        System.assertEquals(true, hasLastNameField, 'Should include LastName field');
    }
    
    /**
     * @description Test getSalesforceFields with invalid object
     */
    @isTest
    static void testGetSalesforceFieldsInvalidObject() {
        Test.startTest();
        try {
            IntegrationSyncController.getSalesforceFields('InvalidObject');
            System.assert(false, 'Should throw exception for invalid object');
        } catch (AuraHandledException e) {
            // Expected exception
            System.assert(e != null, 'AuraHandledException should be thrown for invalid object');
        }
        
        try {
            IntegrationSyncController.getSalesforceFields('');
            System.assert(false, 'Should throw exception for blank object name');
        } catch (AuraHandledException e) {
            // Expected exception
            System.assert(e != null, 'AuraHandledException should be thrown for blank object name');
        }
        Test.stopTest();
    }
}
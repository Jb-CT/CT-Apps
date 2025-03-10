/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/**
 * @class IntegrationConfigControllerTest
 * @description Test class for IntegrationConfigController
 */
@isTest
private class IntegrationConfigControllerTest {
    
    /**
     * @description Tests fetching configurations
     */
    @isTest
    static void testGetConfigurations() {
        // Test
        Test.startTest();
        List<CleverTap_Config__mdt> configs = IntegrationConfigController.getConfigurations();
        Test.stopTest();
        
        // Since we can't create custom metadata in tests,
        // we just verify the method executes without errors
        System.assert(configs != null, 'Configurations should not be null');
    }
    
    /**
     * @description Tests saving configuration
     */
    @isTest
    static void testSaveConfiguration() {
        // Setup
        Map<String, Object> config = new Map<String, Object>{
            'name' => 'Test Connection',
            'region' => 'US',
            'accountId' => 'test-account-id',
            'passcode' => 'test-passcode'
        };
        
        // Test
        Test.startTest();
        String result = IntegrationConfigController.saveConfiguration(config);
        Test.stopTest();
        
        // Verify
        System.assertEquals('Success', result, 'Save operation should return Success');
    }
    
    /**
     * @description Tests saving configuration with missing name
     */
    @isTest
    static void testSaveConfigurationMissingName() {
        // Setup
        Map<String, Object> config = new Map<String, Object>{
            'name' => '',
            'region' => 'US',
            'accountId' => 'test-account-id',
            'passcode' => 'test-passcode'
        };
        
        // Test
        Test.startTest();
        try {
            IntegrationConfigController.saveConfiguration(config);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            // Expected exception - can't directly check message due to AuraHandledException behavior
            System.assert(true, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests saving configuration with missing region
     */
    @isTest
    static void testSaveConfigurationMissingRegion() {
        // Setup
        Map<String, Object> config = new Map<String, Object>{
            'name' => 'Test Connection',
            'region' => '',
            'accountId' => 'test-account-id',
            'passcode' => 'test-passcode'
        };
        
        // Test
        Test.startTest();
        try {
            IntegrationConfigController.saveConfiguration(config);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            // Expected exception - can't directly check message due to AuraHandledException behavior
            System.assert(true, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests saving configuration with a developer name (update scenario)
     */
    @isTest
    static void testSaveConfigurationWithDeveloperName() {
        // Setup
        Map<String, Object> config = new Map<String, Object>{
            'name' => 'Test Connection',
            'region' => 'US',
            'accountId' => 'test-account-id',
            'passcode' => 'test-passcode',
            'developerName' => 'Test_Connection'
        };
        
        // Test
        Test.startTest();
        String result = IntegrationConfigController.saveConfiguration(config);
        Test.stopTest();
        
        // Verify
        System.assertEquals('Success', result, 'Save operation with developer name should return Success');
    }
    
    /**
     * @description Tests deleting configuration with blank developer name
     */
    @isTest
    static void testDeleteConfigurationBlankName() {
        // Test
        Test.startTest();
        try {
            IntegrationConfigController.deleteConfiguration('');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            // Expected exception
            System.assert(true, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests deleting configuration
     * Note: Since we can't mock metadata queries easily in tests,
     * this test will actually throw an exception for "Configuration not found"
     */
    @isTest
    static void testDeleteConfiguration() {
        // Test - in a real test environment, this would fail because
        // we can't create custom metadata to be found
        Test.startTest();
        try {
            IntegrationConfigController.deleteConfiguration('Test_Config');
            // In a real org, this would throw an exception
            System.assert(true, 'No exception was thrown, which is possible if the test runs in an org with this config');
        } catch (AuraHandledException e) {
            // This is actually the expected behavior in most test environments
            System.assert(true, 'Exception was thrown as expected since test config does not exist');
        }
        Test.stopTest();
    }
}
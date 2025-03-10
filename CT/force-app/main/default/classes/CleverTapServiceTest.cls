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
 * @class CleverTapServiceTest
 * @description Test class for CleverTapService to verify record processing and API integration
 */
/**
 * @class CleverTapServiceTest
 * @description Test class for CleverTapService to verify record processing and API integration
 */
/**
 * @class CleverTapServiceTest
 * @description Test class for CleverTapService to verify record processing and API integration
 */
/**
 * @class CleverTapServiceTest
 * @description Test class for CleverTapService to verify record processing and API integration
 */
@isTest
private class CleverTapServiceTest {
    
    /**
     * @description Sets up test data and metadata for all test methods
     */
    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '1234567890'
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id,
            Phone = '1234567890'
        );
        insert testContact;
        
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test.lead@example.com',
            Company = 'Test Company',
            Phone = '1234567890'
        );
        insert testLead;
        
        // Create test opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = testAccount.Id,
            Amount = 10000
        );
        insert testOpportunity;
        
        // Create sync configurations for each record type
        createSyncConfigurations();
    }
    
    /**
     * @description Helper method to create sync configurations and field mappings
     */
    private static void createSyncConfigurations() {
        // Create sync configurations
        List<CleverTap_Sync_Configuration__c> configs = new List<CleverTap_Sync_Configuration__c>();
        
        // Lead Sync Configuration
        CleverTap_Sync_Configuration__c leadConfig = new CleverTap_Sync_Configuration__c(
            Name = 'Lead Sync',
            Salesforce_Entity__c = 'Lead',
            CleverTap_Entity__c = 'profile',
            Status__c = 'Active',
            Sync_Type__c = 'salesforce_to_clevertap'
        );
        configs.add(leadConfig);
        
        // Contact Sync Configuration
        CleverTap_Sync_Configuration__c contactConfig = new CleverTap_Sync_Configuration__c(
            Name = 'Contact Sync',
            Salesforce_Entity__c = 'Contact',
            CleverTap_Entity__c = 'profile',
            Status__c = 'Active',
            Sync_Type__c = 'salesforce_to_clevertap'
        );
        configs.add(contactConfig);
        
        // Account Sync Configuration
        CleverTap_Sync_Configuration__c accountConfig = new CleverTap_Sync_Configuration__c(
            Name = 'Account Sync',
            Salesforce_Entity__c = 'Account',
            CleverTap_Entity__c = 'profile',
            Status__c = 'Active',
            Sync_Type__c = 'salesforce_to_clevertap'
        );
        configs.add(accountConfig);
        
        // Opportunity Sync Configuration
        CleverTap_Sync_Configuration__c opportunityConfig = new CleverTap_Sync_Configuration__c(
            Name = 'Opportunity Sync',
            Salesforce_Entity__c = 'Opportunity',
            CleverTap_Entity__c = 'profile',
            Status__c = 'Active',
            Sync_Type__c = 'salesforce_to_clevertap'
        );
        configs.add(opportunityConfig);
        
        // Insert the configurations
        insert configs;
        
        // Reload configs to get IDs
        configs = [SELECT Id, Salesforce_Entity__c FROM CleverTap_Sync_Configuration__c];
        
        // Create field mappings for each configuration
        List<CleverTap_Mapping__c> mappings = new List<CleverTap_Mapping__c>();
        
        // Create mappings for each config
        for (CleverTap_Sync_Configuration__c config : configs) {
            String idField;
            List<Object> additionalFields = new List<Object>();
            
            // Set up field mappings based on entity type
            if (config.Salesforce_Entity__c == 'Lead') {
                idField = 'Email';
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'FirstName', 'ctField' => 'first_name', 'dataType' => 'Text'
                });
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'LastName', 'ctField' => 'last_name', 'dataType' => 'Text'
                });
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'Phone', 'ctField' => 'phone', 'dataType' => 'Text'
                });
            } else if (config.Salesforce_Entity__c == 'Contact') {
                idField = 'Email';
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'FirstName', 'ctField' => 'first_name', 'dataType' => 'Text'
                });
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'LastName', 'ctField' => 'last_name', 'dataType' => 'Text'
                });
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'Phone', 'ctField' => 'phone', 'dataType' => 'Text'
                });
            } else if (config.Salesforce_Entity__c == 'Account') {
                idField = 'Name';
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'Phone', 'ctField' => 'phone', 'dataType' => 'Text'
                });
            } else if (config.Salesforce_Entity__c == 'Opportunity') {
                idField = 'Name';
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'Amount', 'ctField' => 'amount', 'dataType' => 'Number'
                });
                additionalFields.add(new Map<String, Object>{
                    'sfField' => 'CloseDate', 'ctField' => 'close_date', 'dataType' => 'Date'
                });
            }
            
            // Add mandatory customer_id mapping
            mappings.add(new CleverTap_Mapping__c(
                Sync_Configuration__c = config.Id,
                Salesforce_Field__c = idField,
                CleverTap_Field__c = 'customer_id',
                Data_Type__c = 'Text',
                Is_Mandatory__c = true
            ));
            
            // Add other field mappings
            for (Object fieldObj : additionalFields) {
                Map<String, Object> field = (Map<String, Object>)fieldObj;
                mappings.add(new CleverTap_Mapping__c(
                    Sync_Configuration__c = config.Id,
                    Salesforce_Field__c = (String)field.get('sfField'),
                    CleverTap_Field__c = (String)field.get('ctField'),
                    Data_Type__c = (String)field.get('dataType'),
                    Is_Mandatory__c = false
                ));
            }
        }
        
        // Insert all mappings
        insert mappings;
    }
    
    /**
     * @description Mock implementation of HttpCalloutMock
     */
    private class MockHttpResponse implements HttpCalloutMock {
        /**
         * @description Implements the respond method of the HttpCalloutMock interface
         * @param req The HttpRequest being mocked
         * @return HttpResponse A mock HTTP response with a success status
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","processed":1}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
     * @description Mock implementation of HttpCalloutMock for error responses
     */
    private class MockHttpErrorResponse implements HttpCalloutMock {
        /**
         * @description Implements the respond method of the HttpCalloutMock interface to return error responses
         * @param req The HttpRequest being mocked
         * @return HttpResponse A mock HTTP response with an error status
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"error","error":"Invalid request"}');
            res.setStatusCode(400);
            return res;
        }
    }
    
    /**
     * @description Helper method to delete all event logs
     */
    private static void deleteAllEventLogs() {
        delete [SELECT Id FROM CleverTap_Event__c];
    }
    
    /**
     * @description Tests sending Lead to CleverTap
     */
    @isTest
    static void testSendLeadToCleverTap() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Register the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Get a test Lead
        Lead testLead = [SELECT Id, FirstName, LastName, Email, Phone, Company FROM Lead LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendLeadToCleverTap(testLead);
        Test.stopTest();
        
        // Count events created during the test
        List<CleverTap_Event__c> events = [SELECT Id, Status__c FROM CleverTap_Event__c];
        System.assertEquals(1, events.size(), 'Should create exactly one event log');
        System.assertEquals('Success', events[0].Status__c, 'Status should be Success');
    }
    
    /**
     * @description Tests sending Contact to CleverTap
     */
    @isTest
    static void testSendContactToCleverTap() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Register the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Get a test Contact
        Contact testContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendContactToCleverTap(testContact);
        Test.stopTest();
        
        // Count events created during the test
        List<CleverTap_Event__c> events = [SELECT Id, Status__c FROM CleverTap_Event__c];
        System.assertEquals(1, events.size(), 'Should create exactly one event log');
        System.assertEquals('Success', events[0].Status__c, 'Status should be Success');
    }
    
    /**
     * @description Tests sending Account to CleverTap
     */
    @isTest
    static void testSendAccountToCleverTap() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Register the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Get a test Account
        Account testAccount = [SELECT Id, Name, Phone FROM Account LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendAccountToCleverTap(testAccount);
        Test.stopTest();
        
        // Count events created during the test
        List<CleverTap_Event__c> events = [SELECT Id, Status__c FROM CleverTap_Event__c];
        System.assertEquals(1, events.size(), 'Should create exactly one event log');
        System.assertEquals('Success', events[0].Status__c, 'Status should be Success');
    }
    
    /**
     * @description Tests sending Opportunity to CleverTap
     */
    @isTest
    static void testSendOpportunityToCleverTap() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Register the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Get a test Opportunity
        Opportunity testOpportunity = [SELECT Id, Name, Amount, CloseDate FROM Opportunity LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendOpportunityToCleverTap(testOpportunity);
        Test.stopTest();
        
        // Count events created during the test
        List<CleverTap_Event__c> events = [SELECT Id, Status__c FROM CleverTap_Event__c];
        System.assertEquals(1, events.size(), 'Should create exactly one event log');
        System.assertEquals('Success', events[0].Status__c, 'Status should be Success');
    }
    
    /**
     * @description Tests sending generic SObject to CleverTap
     */
    @isTest
    static void testSendToCleverTap() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Register the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Get a test Account
        Account testAccount = [SELECT Id, Name, Phone FROM Account LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendToCleverTap(testAccount, 'Account');
        Test.stopTest();
        
        // Count events created during the test
        List<CleverTap_Event__c> events = [SELECT Id, Status__c FROM CleverTap_Event__c];
        System.assertEquals(1, events.size(), 'Should create exactly one event log');
        System.assertEquals('Success', events[0].Status__c, 'Status should be Success');
    }
    
    /**
     * @description Tests sending a null record to CleverTap
     */
    @isTest
    static void testSendNullRecord() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        Test.startTest();
        // Call the method with null record
        CleverTapService.sendToCleverTap(null, 'Account');
        Test.stopTest();
        
        // Verify no event logs were created
        List<CleverTap_Event__c> events = [SELECT Id FROM CleverTap_Event__c];
        System.assertEquals(0, events.size(), 'Should not create any event logs for null record');
    }
    
    /**
     * @description Tests sending to CleverTap with no active configuration
     */
    @isTest
    static void testSendWithNoActiveConfig() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Deactivate all sync configurations
        List<CleverTap_Sync_Configuration__c> configs = [SELECT Id FROM CleverTap_Sync_Configuration__c];
        for (CleverTap_Sync_Configuration__c config : configs) {
            config.Status__c = 'Inactive';
        }
        update configs;
        
        Test.startTest();
        // Get a test Account
        Account testAccount = [SELECT Id, Name, Phone FROM Account LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendAccountToCleverTap(testAccount);
        Test.stopTest();
        
        // Verify no event logs were created
        List<CleverTap_Event__c> events = [SELECT Id FROM CleverTap_Event__c];
        System.assertEquals(0, events.size(), 'Should not create any event logs when no active config exists');
    }
    
    /**
     * @description Tests sending to CleverTap with no customer_id mapping
     */
    @isTest
    static void testSendWithNoCustomerIdMapping() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Remove mandatory customer_id mappings
        List<CleverTap_Mapping__c> mandatoryMappings = [
            SELECT Id FROM CleverTap_Mapping__c 
            WHERE CleverTap_Field__c = 'customer_id' AND Is_Mandatory__c = true
        ];
        delete mandatoryMappings;
        
        Test.startTest();
        // Get a test Account
        Account testAccount = [SELECT Id, Name, Phone FROM Account LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendAccountToCleverTap(testAccount);
        Test.stopTest();
        
        // Verify no event logs were created
        List<CleverTap_Event__c> events = [SELECT Id FROM CleverTap_Event__c];
        System.assertEquals(0, events.size(), 'Should not create any event logs when no customer_id mapping exists');
    }
    
    /**
     * @description Tests handling of different data types
     */
    @isTest
    static void testDataTypeConversions() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Register the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Get a test Opportunity (has date and number fields)
        Opportunity testOpportunity = [SELECT Id, Name, Amount, CloseDate FROM Opportunity LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendOpportunityToCleverTap(testOpportunity);
        Test.stopTest();
        
        // Get the created event log
        List<CleverTap_Event__c> events = [SELECT Id, Status__c, Response__c FROM CleverTap_Event__c];
        System.assertEquals(1, events.size(), 'Should create exactly one event log');
        
        // Check the response contains the converted data
        String response = events[0].Response__c;
        System.assert(response.contains('"amount":'), 'Response should contain amount field');
        System.assert(response.contains('"close_date":'), 'Response should contain close_date field');
    }
    
    /**
     * @description Tests sending to CleverTap with API error
     */
    @isTest
    static void testApiError() {
        // Delete any existing event logs
        deleteAllEventLogs();
        
        // Create a mock that returns an error
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        
        Test.startTest();
        // Get a test Lead
        Lead testLead = [SELECT Id, FirstName, LastName, Email, Phone, Company FROM Lead LIMIT 1];
        
        // Call the method being tested
        CleverTapService.sendLeadToCleverTap(testLead);
        Test.stopTest();
        
        // Verify the error event was logged
        List<CleverTap_Event__c> events = [SELECT Id, Status__c FROM CleverTap_Event__c];
        System.assertEquals(1, events.size(), 'Should create exactly one event log');
        System.assertEquals('Failed', events[0].Status__c, 'Status should be Failed');
    }
}
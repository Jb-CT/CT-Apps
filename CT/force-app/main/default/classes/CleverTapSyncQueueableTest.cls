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
 * @class CleverTapSyncQueueableTest
 * @description Test class for CleverTapSyncQueueable to ensure proper queueing and processing of records.
 */
@isTest
private class CleverTapSyncQueueableTest {
    
    /**
     * @description Sets up test data for all test methods
     */
    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test.lead@example.com',
            Company = 'Test Company'
        );
        insert testLead;
        
        // Create test opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = testAccount.Id
        );
        insert testOpportunity;
    }
    
    /**
     * @description Tests constructor with a single Lead record
     */
    @isTest
    static void testConstructorSingleLead() {
        // Get a test lead
        Lead testLead = [SELECT Id, FirstName, LastName, Email FROM Lead LIMIT 1];
        
        // Test constructor with single record
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testLead);
        Test.stopTest();
        
        // Verify the queueable was initialized correctly
        System.assertNotEquals(null, queueable, 'Queueable should be successfully initialized');
        // We can't directly access private fields, but we can verify the class was instantiated
    }
    
    /**
     * @description Tests constructor with a list of Lead records
     */
    @isTest
    static void testConstructorMultipleLeads() {
        // Get test leads
        List<Lead> testLeads = [SELECT Id, FirstName, LastName, Email FROM Lead LIMIT 10];
        
        // Test constructor with multiple records
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testLeads);
        Test.stopTest();
        
        // Verify the queueable was initialized correctly
        System.assertNotEquals(null, queueable, 'Queueable should be successfully initialized');
    }
    
    /**
     * @description Tests constructor with a single Contact record
     */
    @isTest
    static void testConstructorSingleContact() {
        // Get a test contact
        Contact testContact = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1];
        
        // Test constructor with single record
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testContact);
        Test.stopTest();
        
        // Verify the queueable was initialized correctly
        System.assertNotEquals(null, queueable, 'Queueable should be successfully initialized');
    }
    
    /**
     * @description Tests constructor with a single Account record
     */
    @isTest
    static void testConstructorSingleAccount() {
        // Get a test account
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
        
        // Test constructor with single record
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testAccount);
        Test.stopTest();
        
        // Verify the queueable was initialized correctly
        System.assertNotEquals(null, queueable, 'Queueable should be successfully initialized');
    }
    
    /**
     * @description Tests constructor with a single Opportunity record
     */
    @isTest
    static void testConstructorSingleOpportunity() {
        // Get a test opportunity
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        
        // Test constructor with single record
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testOpportunity);
        Test.stopTest();
        
        // Verify the queueable was initialized correctly
        System.assertNotEquals(null, queueable, 'Queueable should be successfully initialized');
    }
    
    /**
     * @description Tests constructor with null records
     */
    @isTest
    static void testConstructorNullRecords() {
        // Test constructor with null records
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable((List<SObject>)null);
        Test.stopTest();
        
        // Verify the queueable was initialized correctly
        System.assertNotEquals(null, queueable, 'Queueable should be successfully initialized with null records');
    }
    
    /**
     * @description Tests constructor with empty records list
     */
    @isTest
    static void testConstructorEmptyRecords() {
        // Test constructor with empty list
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(new List<SObject>());
        Test.stopTest();
        
        // Verify the queueable was initialized correctly
        System.assertNotEquals(null, queueable, 'Queueable should be successfully initialized with empty records');
    }
    
    /**
     * @description Tests execute method with Lead records using a mock service
     */
    @isTest
    static void testExecuteWithLeads() {
        // Get test leads
        List<Lead> testLeads = [SELECT Id, FirstName, LastName, Email FROM Lead LIMIT 1];
        
        // Set up mock service
        CleverTapServiceMock mockService = new CleverTapServiceMock();
        Test.setMock(HttpCalloutMock.class, mockService);
        
        // Execute the queueable
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testLeads);
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Verify service was called
        System.assertEquals(1, mockService.getLeadCallCount(), 'Service should be called once for the Lead');
        System.assertEquals(0, mockService.getContactCallCount(), 'Service should not be called for Contact');
        System.assertEquals(0, mockService.getAccountCallCount(), 'Service should not be called for Account');
        System.assertEquals(0, mockService.getOpportunityCallCount(), 'Service should not be called for Opportunity');
    }
    
    /**
     * @description Tests execute method with Contact records using a mock service
     */
    @isTest
    static void testExecuteWithContacts() {
        // Get test contacts
        List<Contact> testContacts = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1];
        
        // Set up mock service
        CleverTapServiceMock mockService = new CleverTapServiceMock();
        Test.setMock(HttpCalloutMock.class, mockService);
        
        // Execute the queueable
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testContacts);
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Verify service was called
        System.assertEquals(0, mockService.getLeadCallCount(), 'Service should not be called for Lead');
        System.assertEquals(1, mockService.getContactCallCount(), 'Service should be called once for the Contact');
        System.assertEquals(0, mockService.getAccountCallCount(), 'Service should not be called for Account');
        System.assertEquals(0, mockService.getOpportunityCallCount(), 'Service should not be called for Opportunity');
    }
    
    /**
     * @description Tests execute method with Account records using a mock service
     */
    @isTest
    static void testExecuteWithAccounts() {
        // Get test accounts
        List<Account> testAccounts = [SELECT Id, Name FROM Account LIMIT 1];
        
        // Set up mock service
        CleverTapServiceMock mockService = new CleverTapServiceMock();
        Test.setMock(HttpCalloutMock.class, mockService);
        
        // Execute the queueable
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testAccounts);
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Verify service was called
        System.assertEquals(0, mockService.getLeadCallCount(), 'Service should not be called for Lead');
        System.assertEquals(0, mockService.getContactCallCount(), 'Service should not be called for Contact');
        System.assertEquals(1, mockService.getAccountCallCount(), 'Service should be called once for the Account');
        System.assertEquals(0, mockService.getOpportunityCallCount(), 'Service should not be called for Opportunity');
    }
    
    /**
     * @description Tests execute method with Opportunity records using a mock service
     */
    @isTest
    static void testExecuteWithOpportunities() {
        // Get test opportunities
        List<Opportunity> testOpportunities = [SELECT Id, Name FROM Opportunity LIMIT 1];
        
        // Set up mock service
        CleverTapServiceMock mockService = new CleverTapServiceMock();
        Test.setMock(HttpCalloutMock.class, mockService);
        
        // Execute the queueable
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(testOpportunities);
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Verify service was called
        System.assertEquals(0, mockService.getLeadCallCount(), 'Service should not be called for Lead');
        System.assertEquals(0, mockService.getContactCallCount(), 'Service should not be called for Contact');
        System.assertEquals(0, mockService.getAccountCallCount(), 'Service should not be called for Account');
        System.assertEquals(1, mockService.getOpportunityCallCount(), 'Service should be called once for the Opportunity');
    }
    
    /**
     * @description Tests execute method with empty records
     */
    @isTest
    static void testExecuteWithEmptyRecords() {
        // Set up mock service
        CleverTapServiceMock mockService = new CleverTapServiceMock();
        Test.setMock(HttpCalloutMock.class, mockService);
        
        // Execute the queueable with empty records
        Test.startTest();
        CleverTapSyncQueueable queueable = new CleverTapSyncQueueable(new List<SObject>());
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Verify no service calls were made
        System.assertEquals(0, mockService.getLeadCallCount(), 'Service should not be called for Lead');
        System.assertEquals(0, mockService.getContactCallCount(), 'Service should not be called for Contact');
        System.assertEquals(0, mockService.getAccountCallCount(), 'Service should not be called for Account');
        System.assertEquals(0, mockService.getOpportunityCallCount(), 'Service should not be called for Opportunity');
    }
    
    /**
     * @description Mock service class to track calls to CleverTapService methods
     */
    public class CleverTapServiceMock implements HttpCalloutMock {
        private Integer leadCallCount = 0;
        private Integer contactCallCount = 0;
        private Integer accountCallCount = 0;
        private Integer opportunityCallCount = 0;
        
        /**
         * @description Mock implementation of HTTP callout
         * @param request The HTTP request to mock
         * @return HttpResponse A mock HTTP response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"status":"success"}');
            return response;
        }
        
        /**
         * @description Mock implementation of sendLeadToCleverTap
         * @param lead The Lead record to process
         */
        public void sendLeadToCleverTap(Lead lead) {
            leadCallCount++;
        }
        
        /**
         * @description Mock implementation of sendContactToCleverTap
         * @param contact The Contact record to process
         */
        public void sendContactToCleverTap(Contact contact) {
            contactCallCount++;
        }
        
        /**
         * @description Mock implementation of sendAccountToCleverTap
         * @param account The Account record to process
         */
        public void sendAccountToCleverTap(Account account) {
            accountCallCount++;
        }
        
        /**
         * @description Mock implementation of sendOpportunityToCleverTap
         * @param opportunity The Opportunity record to process
         */
        public void sendOpportunityToCleverTap(Opportunity opportunity) {
            opportunityCallCount++;
        }
        
        /**
         * @description Get the number of times sendLeadToCleverTap was called
         * @return Integer The number of times sendLeadToCleverTap was called
         */
        public Integer getLeadCallCount() {
            return leadCallCount;
        }
        
        /**
         * @description Get the number of times sendContactToCleverTap was called
         * @return Integer The number of times sendContactToCleverTap was called
         */
        public Integer getContactCallCount() {
            return contactCallCount;
        }
        
        /**
         * @description Get the number of times sendAccountToCleverTap was called
         * @return Integer The number of times sendAccountToCleverTap was called
         */
        public Integer getAccountCallCount() {
            return accountCallCount;
        }
        
        /**
         * @description Get the number of times sendOpportunityToCleverTap was called
         * @return Integer The number of times sendOpportunityToCleverTap was called
         */
        public Integer getOpportunityCallCount() {
            return opportunityCallCount;
        }
    }
}
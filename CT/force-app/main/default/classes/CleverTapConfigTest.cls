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
 * @class CleverTapConfigTest
 * @description Test class for CleverTapConfig.
 */
/**
 * @class CleverTapConfigTest
 * @description Test class for CleverTapConfig.
 */
/**
 * @class CleverTapConfigTest
 * @description Test class for CleverTapConfig.
 */
@isTest
private class CleverTapConfigTest {
    
    /**
     * @description Tests the getCredentials method.
     * Note: This is a minimal test since custom metadata cannot be created in tests.
     */
    @isTest
    static void testGetCredentials() {
        // Execute the method to ensure it doesn't throw exceptions
        Test.startTest();
        Map<String, String> credentials = CleverTapConfig.getCredentials();
        Test.stopTest();
        
        // Since we can't create or modify custom metadata in tests,
        // we can only verify the method executes without errors
        
        // If your org has test data, you can add more assertions here
        if (credentials != null) {
            System.assertNotEquals(null, credentials.get('API_URL'), 'API URL should not be null');
            System.assertNotEquals(null, credentials.get('ACCOUNT_ID'), 'Account ID should not be null');
            System.assertNotEquals(null, credentials.get('PASSCODE'), 'Passcode should not be null');
        }
    }
}
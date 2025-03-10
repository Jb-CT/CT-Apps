import { createElement } from 'lwc';
import IntegrationSettings from 'c/integrationSettings';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';

describe('c-integration-settings', () => {
    afterEach(() => {
        // Reset the DOM after each test
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('initializes with an empty connection object', () => {
        // Arrange
        const element = createElement('c-integration-settings', {
            is: IntegrationSettings
        });
        document.body.appendChild(element);

        // Assert default connection properties are empty strings
        expect(element.connection).toEqual({
            region: '',
            name: '',
            accountId: '',
            passcode: '',
            developerName: ''
        });
    });

    it('toggles new connection modal when handleAddNewConnection is invoked', () => {
        // Arrange
        const element = createElement('c-integration-settings', {
            is: IntegrationSettings
        });
        document.body.appendChild(element);

        // Initially, the modal should not be visible
        expect(element.showNewConnectionModal).toBe(false);

        // Act
        element.handleAddNewConnection();

        // Assert that the modal is now visible and the connection object resets
        expect(element.showNewConnectionModal).toBe(true);
        expect(element.connection).toEqual({
            region: '',
            name: '',
            accountId: '',
            passcode: '',
            developerName: ''
        });
    });

    it('computes modalTitle correctly based on isEditing flag', () => {
        // Arrange
        const element = createElement('c-integration-settings', {
            is: IntegrationSettings
        });
        document.body.appendChild(element);

        // Act & Assert: When not editing, modalTitle should be "New Connection"
        element.isEditing = false;
        expect(element.modalTitle).toBe('New Connection');

        // When editing, modalTitle should be "Edit Connection"
        element.isEditing = true;
        expect(element.modalTitle).toBe('Edit Connection');
    });

    it('fires navigation event when handleMapField is invoked with a valid connection', () => {
        // Arrange
        const element = createElement('c-integration-settings', {
            is: IntegrationSettings
        });
        // Provide sample connection data
        element.connections = [{
            id: '001xxx',
            developerName: 'TestDev',
            name: 'Test Connection',
            region: 'US',
            accountId: 'acc123',
            passcode: 'pass123'
        }];
        document.body.appendChild(element);

        // Spy on the dispatchEvent method to capture the navigation event.
        const dispatchEventMock = jest.spyOn(element, 'dispatchEvent');

        // Act: Call handleMapField with a fake event whose currentTarget.dataset.id matches our sample record.
        element.handleMapField({ currentTarget: { dataset: { id: '001xxx' } } });

        // Assert: Check that a navigation event was dispatched.
        // (Note: NavigationMixin fires events of type "lightning:navigation")
        expect(dispatchEventMock).toHaveBeenCalled();
    });

    // Optionally, you can add more tests for handleEdit, handleDelete, and handleSave,
    // using similar patterns (e.g., simulating user input and verifying toast events).
    
    it('shows a toast when handleDelete is called without a valid developerName', () => {
        // Arrange
        const element = createElement('c-integration-settings', {
            is: IntegrationSettings
        });
        document.body.appendChild(element);

        // Set up a connection without developerName
        element.connections = [{
            id: '001xxx',
            developerName: '',
            name: 'Test Connection',
            region: 'US',
            accountId: 'acc123',
            passcode: 'pass123'
        }];

        // Spy on the toast event
        const toastHandler = jest.fn();
        element.addEventListener('lightning__showtoast', toastHandler);

        // Act
        element.handleDelete({ 
            currentTarget: { 
                dataset: { id: '001xxx', name: 'Test Connection' }
            }
        });

        // Assert: Since developerName is missing, a toast error should be displayed.
        expect(toastHandler).toHaveBeenCalled();
    });
});

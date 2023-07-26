targetScope = 'resourceGroup'

param location string = resourceGroup().location

param recoveryVaultPolicyId string

param logAnalyticsResourceId string

param backupPolicyName string = 'Backup VMs'
param backupPolicyDefinitionId string = '/providers/Microsoft.Authorization/policyDefinitions/09ce66bc-1220-4153-8104-e3f51c936913'

param monitorVmssPolicyName string = 'Monitor VMSS'
param monitorVmssPolicyDefinitionId string = '/providers/Microsoft.Authorization/policyDefinitions/c7f3bf36-b807-4f18-82dc-f480ad713635'

param monitorVmPolicyName string = 'Monitor VMs'
param monitorVmPolicyDefinitionId string = '/providers/Microsoft.Authorization/policyDefinitions/a0f27bdc-5b15-4810-b81d-7c4df9df1a37'

resource backupPolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: guid('${resourceGroup().id}-${backupPolicyName}')
  location: location
  scope: resourceGroup()
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: backupPolicyName
    policyDefinitionId: backupPolicyDefinitionId
    parameters: {
      vaultLocation: {
        value: location
      }
      backupPolicyId: {
        value: recoveryVaultPolicyId
      }
    }
    resourceSelectors: [
      {
        name: 'Resources to be monitored'
         selectors: [
            {
              kind: 'resourceType'
              in: [
                'Microsoft.Compute/virtualMachines'
              ]
            }
         ]
      }
   ]
  }
}

resource monitorVmssPolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: guid('${resourceGroup().id}-${monitorVmssPolicyName}')
  location: location
  scope: resourceGroup()
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: monitorVmssPolicyName
    policyDefinitionId: monitorVmssPolicyDefinitionId
    parameters: {
      workspaceResourceId: {
        value: logAnalyticsResourceId
      }
      userGivenDcrName: {
        value: 'ama-vmi-vmss'
      }
      enableProcessesAndDependencies: {
        value: true
      }
    }
    resourceSelectors: [
      {
        name: 'Resources to be monitored'
        selectors: [
            {
              kind: 'resourceType'
              in: [
                'Microsoft.Compute/virtualMachineScaleSets'
              ]
            }
        ]
      }
    ]
  }
}

resource monitorVmPolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: guid('${resourceGroup().id}-${monitorVmPolicyName}')
  location: location
  scope: resourceGroup()
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: monitorVmPolicyName
    policyDefinitionId: monitorVmPolicyDefinitionId
    parameters: {
      workspaceResourceId: {
        value: logAnalyticsResourceId
      }
      userGivenDcrName: {
        value: 'ama-vmi-vmss'
      }
      enableProcessesAndDependencies: {
        value: true
      }
    }
    resourceSelectors: [
      {
        name: 'Resources to be monitored'
        selectors: [
            {
              kind: 'resourceType'
              in: [
                'Microsoft.Compute/virtualMachines'
              ]
            }
        ]
      }
    ]
  }
}

output backupPolicyAssignmentId string = backupPolicyAssignment.id
output backupPolicyPrincipalId string = backupPolicyAssignment.identity.principalId
output monitorVmssPolicyAssignmentId string = monitorVmssPolicyAssignment.id
output monitorVmssPolicyPrincipalId string = monitorVmssPolicyAssignment.identity.principalId
output monitorVmPolicyAssignmentId string = monitorVmPolicyAssignment.id
output monitorVmPolicyPrincipalId string = monitorVmPolicyAssignment.identity.principalId

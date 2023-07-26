targetScope = 'resourceGroup'

param backupPolicyAssignmentId string
param monitorVmssPolicyAssignmentId string
param monitorVmPolicyAssignmentId string

resource backupPolicyRemediation 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
  name: guid('${resourceGroup().id}-${backupPolicyAssignmentId}')
  scope: resourceGroup()
  properties: {
    policyAssignmentId: backupPolicyAssignmentId
    resourceDiscoveryMode: 'ReEvaluateCompliance'
  }
}

resource monitorVmssPolicyRemediation 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
  name: guid('${resourceGroup().id}-${monitorVmssPolicyAssignmentId}')
  scope: resourceGroup()
  properties: {
    policyAssignmentId: monitorVmssPolicyAssignmentId
    resourceDiscoveryMode: 'ReEvaluateCompliance'
  }
}

resource monitorVmPolicyRemediation 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
  name: guid('${resourceGroup().id}-${monitorVmPolicyAssignmentId}')
  scope: resourceGroup()
  properties: {
    policyAssignmentId: monitorVmPolicyAssignmentId
    resourceDiscoveryMode: 'ReEvaluateCompliance'
  }
}

#!/bin/bash

# Function to check node readiness and approve CSRs if needed
check_nodes_and_approve_csr() {
    # Get list of nodes that are NotReady
    NOT_READY_NODES=$(oc get nodes --no-headers | awk '$2 == "NotReady" {print $1}')

    # If there are any NotReady nodes, approve pending CSRs
    if [[ -n "$NOT_READY_NODES" ]]; then
        echo "⚠️ Some nodes are NotReady. Checking CSRs..."
        
        # Get pending CSRs and approve them
        PENDING_CSRS=$(oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}')

        if [[ -n "$PENDING_CSRS" ]]; then
            echo "✅ Approving pending CSRs..."
            echo "$PENDING_CSRS" | xargs --no-run-if-empty oc adm certificate approve
        else
            echo "✔️ No pending CSRs found."
        fi
    else
        echo "✅ All nodes are Ready."
    fi
}

# Infinite loop to run every 2 seconds
while true; do
    echo "🔄 Checking node status at $(date)"
    check_nodes_and_approve_csr
    sleep 2
done


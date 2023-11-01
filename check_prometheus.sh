#!/bin/bash

# Nom de l'espace de noms dans lequel vous voulez vérifier les pods
namespace="monitoring"

# Nombre de pods "prometheus" en état "Running" que vous souhaitez trouver
target_count=3
current_count=0

# Exécute la commande 'kubectl get pods' et capture la sortie
pods_list=($(kubectl get pods -n $namespace | grep "prometheus"))

# Parcours de la liste des pods
for line in "${pods_list[@]}"; do
    pod_name=$(echo "$line" | awk '{print $1}')
    pod_status=$(echo "$line" | awk '{print $3}')
    
    if [[ "$pod_status" == "Running" ]]; then
        current_count=$((current_count + 1))
        echo "Le pod $pod_name est en état 'Running'."

        if [ "$current_count" -eq "$target_count" ]; then
            echo "Les $target_count pods 'prometheus' en état 'Running' ont été trouvés."
            kubectl port-forward --address 0.0.0.0 svc/prometheus-kube-prometheus-prometheus -n monitoring 9090 
            break
        fi
    else
        echo "Le pod $pod_name est en état 'Pending', en attente..."
        sleep 5  # Attendre quelques secondes avant de vérifier à nouveau
    fi
done

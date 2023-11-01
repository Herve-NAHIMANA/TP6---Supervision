#!/bin/bash

# Vérifier si Minikube est déjà installé
if command -v minikube &> /dev/null
then
    echo "Minikube est déjà installé."
else
    # Installer Minikube
    echo "Minikube n'est pas installé. Installation en cours..."
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube
    sudo mv minikube /usr/local/bin/
    echo "Minikube a été installé avec succès."
fi
status=$(minikube status | awk 'NR==1{print $2}')
if [ "$status" == "Profile" ]; then
    echo "Minikube n'est pas en cours d'exécution."
    echo "Lancement de minikube."
    minikube start
fi
# Ajout du référentiel Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Créer un espace de noms Kubernetes
kubectl create namespace monitoring

# Installer Prometheus avec Helm
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring

# Installation de mysql
kubectl create secret generic mysecret --from-literal=ROOT_PASSWORD=demo -n monitoring
kubectl apply -f mysql/mysql-statefulset.yaml
# Expose le port 9090
pod_name="nom_du_pod"

while true; do
    # Exécute la commande 'kubectl get pods' et capture la sortie
    pod_status=$(kubectl get pods $pod_name -o jsonpath='{.status.phase}')
    if [ "$pod_status" != "Pending" ]; then
        kubectl port-forward --address 0.0.0.0 svc/prometheus-kube-prometheus-prometheus -n monitoring 9090 
        break
    fi
    echo "Le pod $pod_name est en état 'Pending', en attente..."
    sleep 5  # Attendre quelques secondes avant de vérifier à nouveau
done

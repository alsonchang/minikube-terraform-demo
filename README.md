# Minikube Terraform demo
## Pre-requisiet
The following commands must be installed in advance   
[minikube](https://minikube.sigs.k8s.io/docs/start/)   
[kubectl](https://kubernetes.io/docs/reference/kubectl/)   
[terraform](https://learn.hashicorp.com/collections/terraform/cli)

## Run the minikube cluster
We can create a minikube cluster with a single command

```bash
minikube start
```
Interact with your cluster   

```bash
kubectl get pods -A
```

Alternatively, minikube can download the appropriate version of kubectl and you should be able to use it like this:

```bash
minikube kubectl -- get pods -A
```

If you don't need the minikube environment temporarily you can stop and suspend the virtual machines of the kubernests node    

```bash
minikuebe stop
```

When you are done testing and go to clean everything up, you can use the delete command to delete the minikube cluster.

```bash
minikube delete
```

## Runing the terraform command to setup cluster

When kubernetes cluster is ready for access , you can running terraforom command to setup cluster.   

Initialize the Terraform project. When you run the terraform project for the first time, you need to initialize it first. When you execute the init command, terraform will download the required plugins and create the .lock.hcl file to keep track of the plugin versions.   

```bash
cd ./terraform
terraform init
```

Terraform plan, The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.   

```bash
terraform plan
```

Terraform apply, The terraform apply command executes the actions proposed in a Terraform plan.   

```bash
terraform apply
```

Terraform destory, The terraform destroy command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.   

```bash
terraform destroy
```

## ArgoCD

When you initilize and apply terraform configurtion, the terraform will create the ArcoCD applicaition, which is an gitops tools it can help keeping the application in kubernetes setup as code , you can specify the github repository as the application configuration repository, then ArgoCD will continuously track configuration changes in the repository and apply them.   

Access ArgoCD service, you can using get svc command to get service IP   

```bash
kubectl -n argocd get svc
```

Then, you can copy the IP of argocd-server and paste it into your browser to access it.

Retrive the default password, You can run the following command to get the default admin password  

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D
```


## Update demo application
The demo repository includes a github action workflow to build a docker image of the application and place it on the docker hub, then update the base of the ArgoCD configuration repository.   
You can see the details of setup in workflows config file ```./.github/workflows/build-demo-app.yaml```

## Access the demo application
You can use the kubectl get svc command to get the external ip of the demo-app to access the application on the open port 6868.   

```bash
kubectl -n demo get svc
```

When you use minikube as a cluster provider, you should first perform a ```minikube tunnel``` to enable the mapping of application IPs.


### demo-app endpoint:   
List all of records

```bash
curl --location --request GET 'http://[demo-service-ip]:6868/api/tutorials'
```
Add a record   

```bash
curl --location --request POST 'http://[demo-service-ip]:6868/api/tutorials' \
--header 'Content-Type: application/json' \
--data-raw '{
    "title": "Demo1",
    "description": "Demo1 description"
}'
```

Update the record   

```bash
curl --location --request PUT 'http://[demo-service-ip]:6868/api/tutorials/1' \
--header 'Content-Type: application/json' \
--data-raw '{
    "title": "DemoUpdate",
    "description": "DemoUpdate description"
}'
```

Delete the record   

```bash
curl --location --request DELETE 'http://[demo-service-ip]:6868/api/tutorials/1' \
--header 'Content-Type: application/json'
```


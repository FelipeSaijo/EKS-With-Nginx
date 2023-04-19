# EKS infrastructure with Terraform

## Objective
-------------
The goal of this project was to learn how to build a VPC and EKS resources with Terraform and deploy a nginx container.

## Softwares used
-----------------
- <a href="https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli">Terraform</a>
- <a href="https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html">AWS-CLI</a>
- <a href="https://kubernetes.io/docs/tasks/tools/">Kubectl</a>

NOTE: The way to install each software depends on your operational system. To make a properly installation follow the instruction in the links above.

## Terraform
--------------
After installing terraform you will need an <a href="https://aws.amazon.com/resources/create-account/">AWS account</a> and setup your credencials on <a href="https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html">AWS CLI</a>.

1 - Inside Terraform folder run the follow command to initialize the project.

``` bash
terraform init
```

2 - The next command will create an execution plan that will be applied to the infraestructure of AWS.

``` bash
terraform plan
```

3 - Now we can apply the code. It will be necessary confirm the apply configuration in the terminal with 'yes' or 'no'.

``` bash
terraform apply
```

4 - To delete the resorces created use the following command.

``` bash
terraform destroy
```

NOTE: Resources created outside of terraform will not be deleted by terraform, you'll have to do it manually.

## Kubernetes
----------------

After creating the EKS we need access to the cluster, to do it use the follow command in your host machine with kubectl.

``` bash
aws eks --region <us-west-1-example> update-kubeconfig --name <Your-cluster-name>
```

This command will generate a kubeconfig file that kubectl will use to recognize the cluster. You can read more about <a href="https://repost.aws/knowledge-center/eks-cluster-connection">here</a>.

With the cluster connected to your localhost apply all the kubernetes manifest files on K8S folder.

1 - Deployment: will create 2 pods with nginx.

``` bash
kubectl apply -f nginx-deployment.yaml
```

2 - ClusterIP: Generate an address for each pod, it only works inside of the cluster.

``` bash
kubectl apply -f nginx-clusterip.yaml
```

3 - NodePort: Expose a port in the range of 30000-32767 of the Node.

``` bash
kubectl apply -f nginx-nodeport.yaml
```

4 - LoadBalancer: It's use a load balancer from the cloud provider chossed from you.

``` bash
kubectl apply -f nginx-loadbalancer.yaml
```

## Accessing Nginx home page
-----------

Go to your web browser, them entry in your cloud provider account and in your LoadBalancer created use the DNS name in the URL field. Now you will be able to see the Nginx home page.
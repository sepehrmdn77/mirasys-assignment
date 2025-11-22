# .NET Service Example - Assignment
## Overview
DevOps and automation best practices for a simple .NET application covering tasks below:
| Task | Objective | Solution |
|:---:|:---:|:---:|
| Local Demo | Application deployment and structure review | Vagrant |
| Public repository | Public Git repository | GitHib |
| Secrets | Avoid exposing secrets | GitHub secrets + Azure Key Vault |
| CI | Automated tests, Build, Publish Docker image | GitHub Actions |
| CD | Automated image updater and deployment | ArgoCD |
| Orchestration | Managing containers | K8s |
| Orchestration versioning | Application helm chart  | Helm |
| Monitoring stack | Monitoring common metrics | Prom/Loki/Grafana |
| ... | ... | ... |


---
## Local Demo
For the local deployment you can simply use **Vagrant** as a local development environment. For this purpose, first of all find the **/sandbox/Vagrantfile** and uncomment lines 51-65:
<p align="center">
  <img src="./assets/demo-node-iac.png" alt="Logo" width="900" height="250">
</p>

Then you can use the commands below to bootstrap the instance and have the application directory as a synced folder:
``` bash
vagrant up demo
vagrant ssh demo
```
**Notice:** After project demo make sure to comment those lines again and destroy the demo instance:
``` bash
vagrant destroy demo
```
---
## Public repository
<p align="center">
  <img src="https://github.com/tandpfun/skill-icons/blob/main/icons/Github-Light.svg" height="50" />
</p>
For this demonstration, GitHub has been used as a public Git repository, and GitHub Actions as the CI/CD tool.

### Semantic versioning
The application code is being stored using ***Semantic Versioning*** standard and the **/.github/workflows/ci.yml** file contains a conditional state for the Docker image build and push that runs only when there is a valid semantic tag **(e.g v1.0.0)** and the push is on the **main** branch.

---
## Secrets
In this repository, secrets has been handled using **Azure Key Vault** as the primary secret management vault, and the **GitHub secrets** to store the Azure credentials. 

---

## CI pipeline
The CI pipeline which can be found in the **/.github/workflows/ci.yml** includes jobs below:
- **Build and test** - Check out the repository ```>```  install the .NET environment and get the runner ready for tests ```>```  build the application ```>```  do tests using the command ```dotnet test```
- **Docker Image** - Runs only when there is a push on the main branch and there is a valid semantic tag ```>```  check out the repository ```>``` fetch secerts from Azure Key Vault ```>``` extract the semantic tag ```>``` build the Docker image using the semantic tag and push to the [***Dockerhub***](https://hub.docker.com/repository/docker/sepehrmdn/mirasys-assignment/general)

***Notice:*** For more information please check the [**ci.yaml**](https://github.com/sepehrmdn77/mirasys-assignment/blob/main/.github/workflows/ci.yml) file.

---
## Helm
The ServiceExample application is completely packaged as a Helm chart and available on the **ArtifactHub**, it can be deployed using following commands below:
``` bash
helm repo add mirasys-chart https://sepehrmdn77.github.io
helm repo update
helm install <release-name> mirasys-chart/helm --namespace dev --create-namespace
```


### There is two easy ways to demo the project:
### 1. Local demo
For this purpose follow the instructions bellow:

``` bash
cd ./sandbox
vagrant up
```
After bootstrapping, there would be a **kubeadm join** command available in the ending of the **/home/vagrant/init-output.txt** file. copy it:
``` bash
vagrant ssh master
tail init-output.txt
logout
```
And run it on both worker node as sudo:
``` bash
vagrant ssh worker-1
sudo <command>
logout
vagrant ssh worker-2
sudo <command>
logout
```
Then you can install the Helm chart using commands upper mentioned.

***Note*** If you can not get nodes and fetch pods, make sure to run commands below on the master node:
```bash
rm -rf ~/.kube
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### 2. Online playground
There would be another easier way to demo the project, you can find the K8s playground in the link below:
``` link
https://killercoda.com/playgrounds/course/kubernetes-playgrounds
```
There are several cluster set-ups (Free and Premium) to demo the project.


# Azure Policies

![-----------------------------------------------------](/rainbow.png)

<p align="center">
  
  <a href="#about">About</a> •
  <a href="#prerequisite">Prerequisite</a> •
  <a href="#resources">Create | Modify Resources</a> •
  <a href="#deployment">Deployment</a> •

</p>

---

## About

<table>
<tr>
<td>
  
This repo contains the code to build, modify and maintain the **Azure policies** required for **Customer**. The list of policies available can be found in **AzurePolicies-main**



</td>
</tr>
</table>


## What is deployed?

<table>
<tr>
<td>
  
The following resources have been provisioned as part of the deployment

* A DINE policy to automatically create private DNS zone groups based on type (blob, file, cluster) of private endpoint.
* A DENY policy to deny creation of private dns zones on Azure based on value provided.

</td>
</tr>
</table>

## Prerequisite

1. Install latest terraform.
2. Install latest python.
3. You need to set common variables in both the policies. follow these names `azure_subscription_id`, `azure_client_id`, `azure_client_secret`, `azure_tenant_id`, `ARM_LOCATION` which is a service principal, because terraform uses it to access the subscription and create resources. \

![-----------------------------------------------------](/rainbow.png)

## Resources

## DINE

`DINE` => Python file which will generate terraform files based on parameters from CSV file.

`Instance-Dev` => this contains parameters to be passed to variables.

`variables` => this contains variables to be passed to policy definition.

`Policy-Definition-DINE` => this contains code for creating the private dns zone groups.

`provider` => this contains terraform & azure provider versions.

## DENY

`DINE` => Python file which will generate terraform files based on parameters from CSV file.

`Instance-Dev` => this contains parameters to be passed to variables.

`variables` => this contains variables to be passed to policy definition.

`Policy-Definition-Deny` => this contains code for denying the private dns zone creation.

`provider` => this contains terraform & azure provider versions.


![-----------------------------------------------------](/rainbow.png)

## Deployment

1. Populate the csv file with the required parameters for DINE & DENY policies.
2. You need to run python next which will feed values from excel and create terraform files described in section resources

3. After the terraform files are created, You need to initiaize your terraform backend by navigating to the working directory and running below command

   ```bash
   terraform init
   ```

   then, run plan to check the current state and determine deltas if any with `-var-file`.

   ```bash
   terraform plan -var-file="Instance-Dev.tfvars"
   ```
  
  finally run apply to create the resources with `-var-file`.
   
   ```bash
   terraform apply -var-file="Instance-Dev.tfvars"
   ```

![-----------------------------------------------------](/rainbow.png)


# Autoscaling Jobs using KEDA and Service Bus

## 1. Introduction

You will learn how to use KEDA to trigger autoscaling of Container Apps Jobs based on number of messages within a Queue.
When you create a new message within Service Bus Queue, KEDA will be listening and will trigger Container Apps to add more replicas of a a Job.
The Job will connect to the Queue to receive messages and process it.

![](images/architecture.png)

## 2. Demonstration: triggering Jobs using KEDA

You will work with KEDA to trigger autoscaling Jobs when there are new messages within a Service Bus Queue.
You wil be using `Python` to create a sample application that will perform the following operations:
1. Connect to Service Bus Queue
2. Receive a message
3. Process the message and mark it as complete

### 4.1. Deploy the resources

You will use Terraform to deploy the following resources:
1. Container Apps Environment
2. Azure Service Bus
3. Service Bus Queue
4. Container Apps Job
5. Azure Container Registry
6. Container image that will process the message

To do that, run the `terraform` commands to initialize the module, plan the changes and deploy the resources.
Make sure you are withing the folder containing terraform files.

```shell
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

After that, check the deployed resources.

![](images/resources.png)

You will send a message to the Service Bus Queue.

![](images/send-message.png)

Then you will watch for a triggered Job.

![](images/job-triggered.png)

>Note that the terraform code will build a container image by running `az acr build` command.

Check the `scale-rule` used to configure how KEDA will autoscale the Job.

```bash
      az containerapp job create `
        --name aca-job-demo `
        --resource-group ${azurerm_resource_group.rg.name} `
        --environment ${azurerm_container_app_environment.aca_environment.name} `
        --replica-timeout 600 `
        --replica-retry-limit 1 `
        --replica-completion-count 1 `
        --parallelism 1 `
        --image "mcr.microsoft.com/k8se/quickstart-jobs:latest" `
        --cpu "0.25" `
        --memory "0.5Gi" `
        --min-executions 0 `
        --max-executions 1 `
        --trigger-type "Event" `
        --secrets service-bus-connection-string="${azurerm_servicebus_namespace.service-bus.default_primary_connection_string}" `
        --scale-rule-name azure-servicebus-queue-rule `
        --scale-rule-type azure-servicebus `
        --scale-rule-auth "connection=service-bus-connection-string" `
        --scale-rule-metadata "namespace=${azurerm_servicebus_namespace.service-bus.name}" `
                              "queueName=${azurerm_servicebus_queue.queue-messages.name}" `
                              "messageCount=1"
```

The autoscaler needs to authenticate to Azure Service Bus to count the number of messages. For that it uses the Service Bus Connection String, namespace and Queue name.
Note how this configuration will trigger a new Job each time you have at least one message within the Queue ("messageCount=1").

Note also how the container will connect to Service Bus to receive messages.

## Conclusion

You will learn in the next lab, how to receive the Queue messages from within the triggered Jobs to process it.
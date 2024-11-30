import os
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential


def connect_to_storage_with_identity():
    try:
        # the envs are from the secret reference defined in pod.yaml. And the secret is created by Service Connector
        # when creating the connection between the AKS cluster and the Azure OpenAI service
        blob_service_client = BlobServiceClient(
            account_url= os.environ.get("AZURE_STORAGEBLOB_RESOURCEENDPOINT"), 
            credential=DefaultAzureCredential()
        )
        containers = blob_service_client.list_containers()
        print(f"Connection to Azure Storage succeeded. Found {len(list(containers))} containers.")

    except Exception as e:
        print("Connect to Azure Storage failed: {}".format(e))


if __name__ == "__main__":
    connect_to_storage_with_identity()
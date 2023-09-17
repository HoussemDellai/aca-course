# Securing Secrets in Azure Container Apps

## Introduction

Azure Container Apps allows your application to securely store sensitive configuration values. 
Once secrets are defined at the application level, secured values are available to revisions in your container apps.

An updated or deleted secret doesn't automatically affect existing revisions in your app. When a secret is updated or deleted, you can respond to changes in one of two ways:

Deploy a new revision.
Restart an existing revision.

## 1. Creating secrets

Secrets are defined as a set of name/value pairs. 
The value of each secret is:
1. specified directly 
2. or as a reference to a secret stored in Azure Key Vault
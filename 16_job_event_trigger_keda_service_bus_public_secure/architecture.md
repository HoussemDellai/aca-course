# Architecture — KEDA Service Bus triggered Container Apps Job (public, secured)

A Container Apps **Job** is triggered by **KEDA** based on the number of messages in an
**Azure Service Bus** queue. The job runs inside a **VNet-injected** Container Apps Environment
and egresses through a **NAT Gateway** with a static Public IP Prefix. The Service Bus namespace
denies all public traffic by default and only allows the NAT Gateway IP prefix (and a corporate
CIDR). Authentication uses **user-assigned managed identities** — no connection strings.

```mermaid
architecture-beta
    group rg(azure:resource-groups)[Resource Group]

    group vnet(azure:virtual-networks)[VNet 10.0.0.0/16] in rg
    group snet(azure:subnet)[Subnet snet-aca 10.0.0.0/24 — delegated to Microsoft.App/environments] in vnet

    service nsg(azure:network-security-groups)[NSG\nAllow outbound → ServiceBus:443] in rg
    service nat(azure:nat)[NAT Gateway\nStandardV2] in rg
    service pip(azure:public-ip-addresses)[Public IP Prefix /30\nStandardV2] in rg
    service sb(azure:azure-service-bus)[Service Bus Standard\nqueue-messages\nFirewall: Deny all except NAT IP] in rg
    service acr(azure:container-registries)[Container Registry\nBasic — public] in rg
    service law(azure:log-analytics-workspaces)[Log Analytics\nWorkspace] in rg
    service idsb(azure:managed-identities)[Managed Identity\nService Bus Data Receiver] in rg
    service idacr(azure:managed-identities)[Managed Identity\nAcrPull] in rg

    service acaenv(azure:container-apps)[ACA Environment\nConsumption workload profile\nVNet-injected] in snet
    service acajob(azure:container-instances)[ACA Job — job-python\nKEDA event trigger\nmin 0 / max 1 replicas] in snet

    service user(internet)[Operator / Message Sender\nRBAC: Data Sender + Data Receiver]

    user:R --> L:sb
    sb:B --> T:acajob
    acajob:R --> L:acr
    idsb:T --> B:acajob
    idacr:T --> B:acajob
    acaenv:R --> L:law
    acajob{group}:B --> T:nat
    nat:R --> L:pip
    pip:B --> T:sb
    nsg:B --> T:snet
```

## Resources

| Resource | Type | Notes |
|---|---|---|
| `vnet-internal` | Virtual Network | 10.0.0.0/16 |
| `snet-aca` | Subnet | 10.0.0.0/24, delegated to `Microsoft.App/environments` |
| `nsg-aca` | Network Security Group | Allow-all inbound; allow outbound TCP/443 → `ServiceBus.SwedenCentral` |
| `nat-gateway` | NAT Gateway | StandardV2, zone-redundant by default |
| `pip-prefix-nat-gateway` | Public IP Prefix | /30 (4 IPs), StandardV2 |
| `aca-environment` | Container Apps Environment | Consumption profile, VNet-injected, logs → Log Analytics |
| `aca-job-python` | Container Apps Job | KEDA `azure-servicebus` trigger, polls every 30s, scales 0→1 |
| `servicebus-ns-std-*` | Service Bus Namespace | Standard SKU; network rule set `default_action = Deny`, NAT IP prefix allowed |
| `queue-messages` | Service Bus Queue | `maxDeliveryCount = 1`, `lockDuration = 5 min` |
| `acr4aca4keda123*` | Container Registry | Basic SKU, public, no admin user |
| `identity-aca-servicebus` | User-Assigned Identity | RBAC: *Azure Service Bus Data Receiver* on namespace |
| `identity-aca-acr` | User-Assigned Identity | RBAC: *AcrPull* on ACR |
| Log Analytics Workspace | Workspace | ACA environment log destination |

## Traffic flow

1. **Operator** sends messages to `queue-messages` via RBAC (*Azure Service Bus Data Sender*).
2. **KEDA** polls the queue every **30 s** using `identity-aca-servicebus` (*Data Receiver*).  
   When `messageCount ≥ 1`, it triggers the Container Apps Job (scales **0 → 1** execution).
3. The job replica pulls the container image from **ACR** using `identity-aca-acr` (*AcrPull*).
4. Inside the job, `processor.py` connects to the Service Bus FQDN via managed identity and
   processes / completes messages from the queue.
5. All outbound traffic from `snet-aca` exits through the **NAT Gateway**, appearing as the
   static **Public IP Prefix** (`/30`).
6. The Service Bus firewall (`default_action = Deny`) only whitelists that IP prefix, so the
   job reaches Service Bus while the namespace stays closed to the general internet.
7. The **NSG** on `snet-aca` explicitly allows outbound TCP/443 to `ServiceBus.SwedenCentral`
   and blocks everything else by default.
8. The ACA Environment streams logs to **Log Analytics**.

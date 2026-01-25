flowchart TB
    Dev[App Teams] -->|PR| GH[GitHub Repos]

    subgraph GitHub
        GH -->|PR Validation| PR[PR Validation Pipeline]
        GH -->|Merge| Deploy[Deploy Pipeline]
    end

    subgraph cloud_Repo[cloud Engineering Repos]
        Modules[Terraform Modules Repo]
        SubFactory[Subscription Factory Repo]
        Policies[Policy as Code Repo]
    end

    PR -->|fmt / validate / test| Modules
    PR -->|OPA / Conftest| Policies

    Deploy -->|OIDC| AzureLogin[Azure AD OIDC]

    subgraph Azure
        MG[Management Groups]
        Policy[Azure Policy]
        SubDev[Dev Subscription]
        SubStg[Staging Subscription]
        SubProd[Prod Subscription]
        AKS[AKS]
        KV[Key Vault]
        VNET[VNET / Hub-Spoke]
    end

    AzureLogin --> MG
    MG --> Policy
    MG --> SubDev
    MG --> SubStg
    MG --> SubProd

    SubProd --> AKS
    SubProd --> KV
    SubProd --> VNET

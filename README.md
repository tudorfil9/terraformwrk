# terraform 
# ansible
ansible-playbook ansible/playbooks/main.yaml -i ansible/envs/group_vars/inventory_all

# az cli

Ubuntu Server 18.04
D2s v3
Public IP with DNS Label
pwgen for vm password
.Net 2.2 Core
unzip -> dotnet MvcSample.dll

Traffic Manager -> email alert when endpoint is down


Avem o aplicatie web ASP .NET Core 2.2, al carei pachet il poti gasi aici: https://uipathdevtest.blob.core.windows.net/binaries/netcoreapp2.2.zip . Este un sample app oferit de dezvoltatorii .NET Core care afiseaza o lista de URL-uri (localhost:5000, localhost:5001, etc).
Aceasta aplicatie trebuie deploy-ata pe doua VM-uri Ubuntu in Azure aflate in doua regiuni diferite (primary region West Europe si secondary location North Europe). Aceste VM-uri trebuie sa fie plasate in spatele unui Azure Traffic Manager care sa faca failover pe endpoint-ul VM-ului din regiunea secundara in caz ca cel din regiunea primara este down (gasesti mai multe detalii ale acestui pattern aici: https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-routing-methods#priority)


HOW TO USE:

bash/zsh on macOS with credentials stored in OS X Keychain only

1. source tf.creds
2. terraform plan <main.tf> -out your_plan.plan
3. terraform apply <main.tf> -out your_plan.plan

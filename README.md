# Workshop MABS TFTEC 

Boa noite,
Missão dada é missão cumprida! ( Risos) 

Nesse final de semana (02 e 03/12/2023) eu assisti a primeira parte do Workshop sobre MABS da TFTEC, e o  Rafael explanou que teríamos uma segunda parte no mês de dezembro, pelo longo tempo não faz sentido deixar a infraestrutura montada, em algum momento do vídeo ele lançou um desafio de alguém montar essa infra tanto no Biceps ou no Terrafom, e como um dos meus hobbys é fazer IaC ( Apesar de ter a certificação AZ400 eu não me considero DeVops, eu ainda sou um Padwan) eu montei em HCL as seguinte estrutura:

1.	Por questão de segurança ao iniciar o provisionamento é exibido na tela as seguintes perguntas:

1.1 – FQDN Ex.: cloud.local
1.2 – Senha de recuperação do AD ( coloque uma senha complexa, senão o provisionamento não termina)
1.3 – NetBios Ex.: CLOUD
1.4 – Usuário do Banco SQL (sysadmin)
1.5 – Senha para o Banco
1.6 – Usuário das Vms
1.7- Senha para as Vms


O script configura a vm-adds com um  IPv4/TCP interno estático e configura automaticamente nas vnets com o IP do servidor DNS do ADDS, o provisionamento da vm-web é composto com o serviço IIS, logo não precisa configurar o server web, a vm-db é provisionada no modo IaaS com SQL2022 com SKU dev e com 3 discos de 8 gigas ( Data, Logs e Temp), a vm-mab é totalmente limpa e por final é provisionado um Recovery Vault com o Soft Deelete desabilitado e com replicação LRS.

TODAS AS VMS SÃO INGRESSADAS NO AD VIA TERRAFORM	

Foi meio trabalhoso e alguns dias para concluir, sendo que só testava a noite, mas espero que gostem, para treinar o WorkShop basta baixar o HCL e rodar os seguintes comandos

terraform init 
terraform plan
terraform apply -auto-approve

Obs.: É preciso configurar um storage account para manter o histórico do provisionamento, a configuração fica  no arquivo main.tf

A única coisa que precisa fazer é desabilitar o firewall 

No final do provionamento ele informa os IPs das VMs

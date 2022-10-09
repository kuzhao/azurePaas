$ACR_LOGIN_SERVER = "default600467611.azurecr.io"
$RES_GROUP = "rg-useast-aci"
$ACR_USER = "default600467611"
$ACR_KEY = "DO/hKkbJeZrqmxUaQfvIe96uHdIxuAcq"

# Queue 0
## Publisher
for ($i = 0; $i -lt 3; $i++) {    
    az container create `
        --name sb-pub$i-queue6 `
        --resource-group $RES_GROUP `
        --memory 0.5 `
        --image $ACR_LOGIN_SERVER/sb/sb_pub:0.1 `
        --registry-login-server $ACR_LOGIN_SERVER `
        --registry-username $ACR_USER `
        --registry-password $ACR_KEY `
        --environment-variables "PUBLISHER=pub$i" "QUEUE_NAME=queue6"
}
## Receiver
az container create `
    --name sb-sub-queue6 `
    --resource-group $RES_GROUP `
    --memory 0.5 `
    --image $ACR_LOGIN_SERVER/sb/sb_sub:0.1 `
    --registry-login-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_USER `
    --registry-password $ACR_KEY `
    --environment-variables "QUEUE_NAME=queue6"

# Queue 1
## Publisher
<#for ($i = 0; $i -lt 3; $i++) {    
    az container create `
        --name sb-pub$i-queue1 `
        --resource-group $RES_GROUP `
        --memory 0.5 `
        --image $ACR_LOGIN_SERVER/sb/sb_pub:0.1 `
        --registry-login-server $ACR_LOGIN_SERVER `
        --registry-username $ACR_USER `
        --registry-password $ACR_KEY `
        --environment-variables "PUBLISHER=pub$i" "QUEUE_NAME=queue1"
}
## Receiver

az container create `
    --name sb-sub-queue1 `
    --resource-group $RES_GROUP `
    --memory 0.5 `
    --image $ACR_LOGIN_SERVER/sb/sb_sub:0.1 `
    --registry-login-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_USER `
    --registry-password $ACR_KEY `
    --environment-variables "QUEUE_NAME=queue1"
    #>

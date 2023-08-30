#!/bin/bash
galleryResourceGroup='Contoso-Base-Images-Engineers-rg'
devBoxResourceGroupName="Contoso-DevBox-rg"
az group delete --name $galleryResourceGroup --yes --no-wait
az group delete --name $devBoxResourceGroupName --yes --no-wait

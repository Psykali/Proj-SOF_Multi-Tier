!/bin/sh
#################################################################################################
##                          FunctionApp-Azure                  ##              Index           ##      
## Simple script to automate the creation of FunctionApp-Azure.## 01.Create Ressource Group.   ##
## the package do most of the hard work,                       ## 02.Create Storage Account.   ##
## so this script can be small-ish and lazy-ish.               ## 03.Creation Function APP.    ##
## V1.0.0 By S.KHALIFA 05/09/2022                              ## 04.Creation FunctionApp Slot.##
## V1.0.2 By C.DE SOUSA MATHIEU 06/09/2022                              ##                              ## 
#################################################################################################
############
## Colors ##
############
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
NC='\033[0m'              # No Color
####################
Ans01="PERSO_SIEF"
Ans02="francecentral"
strgacc="skskabdocker"
Ans05="skskabdocker"
webapp="skskabdocker"

###############################
## 01.Create Ressource Group ##
###############################
#echo " Please Name the Group "
#read Ans01
#echo " Where you would like to create it ?! Ex : westeurope "
#read Ans02
#az group create -l $Ans02 \
#                -n $Ans01 
#if [ "$?" -eq "0" ]; then
#    echo -e "${BGreen} 01.Create Ressource Group Done, Launching 02.Create Storage Account... ${NC}" 
#  else
#    echo -e  "%s\n" " ${BRed} Opps, Error 01.Create Ressource Group ${NC}"
#  exit 1;
#fi
###############################
## 02.Create Storage Account ##
###############################
#echo -e " Please name your Storage-account,${BYellow} PS!!:Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters >
#read strgacc
az storage account create -n $strgacc \
                            -g $Ans01 \
                            --sku Standard_LRS 
if [ "$?" -eq "0" ]; then
    echo -e "${BGreen} 02.Create Storage Account Done, Launching 03.Creation Function APP ... ${NC}"
else
    echo -e  "%s\n" " ${BRed} Opps, Error 02.Create Storage Account ${NC}"
  exit 1;
fi
##############################################
## 03.Create an App Service plan in S1 tier ##
##############################################
# Create an App Service plan in S1 tier
#echo -e " Please Name the App Service plan?! ${BYellow} Ex: brief10groupe3 ${NC} ${BRed}!!! RESPECT THE CASE !!!${NC} "
#read Ans05
echo "Creating $Ans05"
az appservice plan create --name $Ans05 --resource-group $Ans01 --sku T1v2 --is-linux
######################################
## 04.Create an Web App dev et prod ##
######################################
# Create a web app. To see list of available runtimes, run 'az webapp list-runtimes --linux'
echo "Creating $webapp"
az webapp create --name $webapp --resource-group $Ans01 --plan $Ans05  --runtime "NODE|14-lts"

echo "Creating $webapp de dev"
az webapp create --name $webapp+dev --resource-group $Ans01 --plan $Ans05  --runtime "NODE|14-lts"

# pour lier l'image du container 

az webapp config container set -docker-custom-image-name psykali/stackoverp20kcab --docker-registry-server-url https://index.docker.io --name $webApp --resource-group $resourceGroup 

#########
## End ##
#########
echo ""
echo " ${BGreen} YAAAAAY, You have Done Great Job ${NC}"
echo ""
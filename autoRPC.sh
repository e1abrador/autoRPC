#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function banner(){
echo -e "                             ${redColour}#####   ######  ###### ${endColour} "
echo -e "${yellowColour}   ##   #    # #####  #### ${endColour} ${redColour}#     # #     # #     # ${endColour}"
echo -e "${yellowColour}  #  #  #    #   #   #    #${endColour} ${redColour}#     # #     # #       ${endColour}"
echo -e "${yellowColour} #    # #    #   #   #    #${endColour} ${redColour}######  ######  #       ${endColour}"
echo -e "${yellowColour} ###### #    #   #   #    #${endColour} ${redColour}#   #   #       #       ${endColour}"
echo -e "${yellowColour} #    # #    #   #   #    #${endColour} ${redColour}#    #  #       #     # ${endColour}"
echo -e "${yellowColour} #    #  ####    #    #### ${endColour} ${redColour}#     # #        #####  ${endColour}"
}

function auth_descripion(){
#Get decription of all users using valid RPC credentials
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}username${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read auth_username
echo -e "${endColour}"
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}password${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read auth_password
echo -e "${endColour}"
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}username${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read auth_ip
echo -e "${endColour}"
clear

# Tiffany.Molina
# NewIntelligenceCorpUser9876
# 10.10.10.248

rpcclient -U $auth_username%$auth_password $auth_ip -c "enumdomusers" | sed 's/user:// ' | tr -d '[]' | awk '{print $1}' > /tmp/user
for authenticated_rid in $(cat /tmp/user);do
echo -e "\t---------------------------------------------" && rpcclient -U $auth_username%$auth_password $auth_ip -c "queryuser $authenticated_rid" | grep -E "Description|User Name" && echo -e "\t---------------------------------------------\n"; done
rm -r /tmp/user
}

function unauth_domain_admins(){

echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}ip address${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read unauth_ip
echo -e "${endColour}"
clear

rpcclient -U "" $unauth_ip -N -c 'enumdomgroups' | grep -i 'domain admin' | grep -oP '\[.*?]' | grep '0x' | tr -d '[]' > /tmp/rid

for unauth_domain_users_rid in $(cat /tmp/rid); do
	rpcclient -U "" $unauth_ip -N -c "querygroupmem $unauth_domain_users_rid" | sed 's/rid://' | sed 's/attr:// ' | awk '{print $1}' | tr -d '[]' >> /tmp/rid_users ;
done

echo -e "[*] Domain Users:\n"
for rid_to_user_unauth in $(cat /tmp/rid_users); do
	rpcclient -U "" $unauth_ip -N -c "queryuser $rid_to_user_unauth" | grep "User Name" | sed 's/User Name//' | tr -d ':' | tr -d ' ' | tr -d '\t';
done

rm -r /tmp/rid && rm -r /tmp/rid_users

}

function auth_domain_admins(){
#Get all domain admins using valid RPC credentials
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}username${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read domain_auth_username
echo -e "${endColour}"
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}password${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read domain_auth_password
echo -e "${endColour}"
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}ip address${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read domain_auth_ip
echo -e "${endColour}"
clear

rpcclient -U $domain_auth_username%$domain_auth_password $domain_auth_ip -c 'enumdomgroups' | grep -i 'domain admin' | grep -oP '\[.*?]' | grep '0x' | tr -d '[]' > /tmp/rid

for domain_users_rid in $(cat /tmp/rid); do
	rpcclient -U $domain_auth_username%$domain_auth_password $domain_auth_ip -c "querygroupmem $domain_users_rid" | sed 's/rid://' | sed 's/attr:// ' | awk '{print $1}' | tr -d '[]' >> /tmp/rid_users ;
done

echo -e "[*] Domain Users:\n"
for rid_to_user in $(cat /tmp/rid_users); do
	rpcclient -U $domain_auth_username%$domain_auth_password $domain_auth_ip -c "queryuser $rid_to_user" | grep "User Name" | sed 's/User Name//' | tr -d ':' | tr -d ' ' | tr -d '\t';
done
rm -r /tmp/rid && rm -r /tmp/rid_users
}

function null_session_description(){
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}ip address${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read null_session_desc_ip
echo -e "${endColour}"
clear
rpcclient -U "" $null_session_desc_ip -N -c "enumdomusers" | sed 's/user:// ' | tr -d '[' | tr -d ']' | awk '{print $1}' > /tmp/user
for authenticated_rid in $(cat /tmp/user);do
	echo -e "\t---------------------------------------------" && rpcclient -U "" $null_session_desc_ip -N -c "queryuser $authenticated_rid" | grep -E "Description|User Name" && echo -e "\t---------------------------------------------\n";
done
rm -r /tmp/user
}

function enumerate_groups_null(){
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}ip address${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read enum_groups_unauth
echo -e "${endColour}"
clear
rpcclient -U "" $enum_groups_unauth -N -c 'enumdomgroups' | grep -oP '\[.*?\]' | grep -v 0x | tr -d '[]'
}


function enumerate_groups_auth(){
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}username${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read auth_groups_user
echo -e "${endColour}"
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}password${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read auth_groups_pass
echo -e "${endColour}"
clear
echo -e "${greenColour}┌─[${endColour}${redColour}autoRPC${endColour}${greenColour}]──[${endColour}${redColour}~${endColour}${greenColour}]─[${endColour}${blueColour}ip address${endColour}${endColour}${greenColour}]${endColour}${grayColour}:${endColour}"
echo -ne "${greenColour}└─────► " && read auth_groups_ip
echo -e "${endColour}"
clear

rpcclient -U $auth_groups_user%$auth_groups_pass $auth_groups_ip -c 'enumdomgroups' | grep -oP '\[.*?\]' | grep -v 0x | tr -d '[]'

}

if [ $1 2>/dev/null == "-h" 2>/dev/null ]; then
#	banner
	echo -e "\n\t${blueColour}[${endColour}${yellowColour}*${endColour}${blueColour}]${endColour} ${grayColour}Help Panel:${endColour}\n"
	echo -e "\t${blueColour}[${endColour}${yellowColour}*${endColour}${blueColour}]${endColour} ${grayColour}Usage:${endColour}\n"
	echo -e "\t    ${yellowColour}bash autoRPC.sh${endColour} ${blueColour}[${endColour}${redColour}options${endColour}${blueColour}]${endColourp}\n"
	echo -e "\t${blueColour}[${endColour}${yellowColour}*${endColour}${blueColour}]${endColour} ${grayColour}Recognized Options:${endColour}"
	echo -e "\n\t    ${redColour}-auth-desc${endColour}\t\t    ${grayColour}:${endColour} ${yellowColour}Enumerate RPC Username and Description (Using Valid Credentials).${endColour}"
	echo -e "\t    ${redColour}-null-session-desc${endColour}\t    ${grayColour}:${endColour} ${yellowColour}Enumerate RPC with null session (No Credentials).${endColour}"
	echo -e "\t    ${redColour}-auth-domain-admins${endColour}\t    ${grayColour}:${endColour} ${yellowColour}Enumerate RPC domain admins (Using Valid Credentials).${endColour}"
	echo -e "\t    ${redColour}-unauth-domain-admins${endColour}   ${grayColour}:${endColour}${yellowColour} Enumerate RPC domain admins (No credentials).${endColour}"
	echo -e "\t    ${redColour}-enumerate-groups-auth${endColour}  ${grayColour}:${endColour} ${yellowColour}Enumerate RPC groups (Using Valid Credentials).${endColour}"
	echo -e "\t    ${redColour}-enumerate-groups-null${endColour}  ${grayColour}:${endColour}${yellowColour} Enumerate RPC domain groups (No credentials).${endColour}"
elif [ $1 == "-auth-desc" 2>/dev/null ]; then
        auth_descripion
elif [ $1 == "-null-session-desc" 2>/dev/null ]; then
	null_session_description
elif [ $1 == "-auth-domain-admins" 2>/dev/null ]; then
	auth_domain_admins
elif [ $1 == "-unauth-domain-admins" 2>/dev/null ]; then
	unauth_domain_admins
elif [ $1 == "-enumerate-groups-null" 2>/dev/null ]; then
	enumerate_groups_null
elif [ $1 == "-enumerate-groups-auth" 2>/dev/null ]; then
	enumerate_groups_auth
else
	echo -e "\n\t${blueColour}[${endColour}${redColour}*${endColour}${blueColour}]${endColour} ${yellowColour}bash autoRPC.sh -h${endColour} "
fi


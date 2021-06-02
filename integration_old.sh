#! /bin/bash 

export ORACLE_HOME=/oracle/app/oracle/product/19.0.0/dbhome_1
export PATH=$PATH:/oracle/app/oracle/product/19.0.0/dbhome_1/bin

FOLDER=/home/oracle/automation/integration
FILE=$FOLDER/points.csv
bizEV=/Capita.TfL.BOps.LEZLight.AutopayExceptionChecker/AutopayExceptionCheckerService.svc
URL_ADDRESS=`cat $FILE | grep URL_ADDRESS |  cut -d ';' -f2`
ER_HTML_PAGE=`cat $FILE | grep ER_HTML_PAGE |  cut -d ';' -f2`
CUSTOM_21_AP=`cat $FILE | grep CUSTOM_21_AP |  cut -d ';' -f2`
CUSTOM_22_BULK=`cat $FILE | grep CUSTOM_22_BULK |  cut -d ';' -f2`
CUSTOM_23_DISC=`cat $FILE | grep CUSTOM_23_DISC | cut -d ';' -f2`
LDAP=`cat $FILE | grep LDAP | cut -d ';' -f2`
GEOMANT=`cat $FILE | grep GEOMANT | cut -d ';' -f2`
CSS_PS=`cat $FILE | grep 'CSS-PS' | cut -d ';' -f2`
CPS_BAVS=`cat $FILE | grep 'CPS-BAVS' | cut -d ';' -f2`
BIZTALK=`cat $FILE | grep -w BIZTALK | cut -d ';' -f2`
BIZTALKIP=`cat $FILE | grep -w BIZTALKIP | cut -d ';' -f2`
ENV=`sqlplus -s foundation/foundation@magnolia << EOF
set heading off;
select param_value_1 from params where param_name like 'CurrentEnv%';
EOF`


function EV()
{

if [ -z $URL_ADDRESS ]
then
echo "Value of EV URL_ADDRESS not provided, nothing to update!"
else
echo "Running URL_ADDRESS (CAPITA_CSR_BUSINESS_PARAMS) EV update..."
sleep 2
url=`sqlplus -s foundation/foundation@magnolia << EOL
update EXTERN_VALUES_PER_ENV
set extern_values_value = '$URL_ADDRESS'
where EXTERN_VALUES_ID in  (select EXTERN_VALUES_ID from extern_values  where 
extern_values_group_members_id in (select extern_values_group_members_id from EXTERN_VALUES_GROUP_MEMBERS
where extern_value_names_id in (select extern_value_names_id from EXTERN_VALUE_NAMES where extern_value_names_name like 'URL_ADDRESS')))and env_number = $ENV;
commit;
EOL`
fi

if [ -z $ER_HTML_PAGE ] 
then 
echo "Value of EV ER_HTML_PAGE not provided, nothing to update!"
else
echo "Running ER_HTML_PAGE (CAPITA_CSR_BUSINESS_PARAMS) EV update..."
sleep 2
er=`sqlplus -s foundation/foundation@magnolia << EOL
update EXTERN_VALUES_PER_ENV
set extern_values_value = '$ER_HTML_PAGE'
where EXTERN_VALUES_ID in  (select EXTERN_VALUES_ID from extern_values  where
extern_values_group_members_id in (select extern_values_group_members_id from EXTERN_VALUES_GROUP_MEMBERS
where extern_value_names_id in (select extern_value_names_id from EXTERN_VALUE_NAMES where extern_value_names_name like '%ER_HTML_PAGE%')))and env_number = $ENV;
commit;
EOL`
fi

if [ -z $CUSTOM_21_AP ]
then
echo "Value of EV Remote System URL for CUSTOM TYPE 21 not provided, nothing to update!"
else
echo "Running REMOTE SYSTEM URL (CAPITA REMPTE SYSTEM PARAMS - CUSTOM TYPE 21) EV update..."
sleep 2
ap=`sqlplus -s foundation/foundation@magnolia << EOL
update EXTERN_VALUES_PER_ENV
set extern_values_value = '$CUSTOM_21_AP'
where EXTERN_VALUES_ID in  (select EXTERN_VALUES_ID from extern_values  where
object_id in (21)
and 
extern_values_group_members_id in (select extern_values_group_members_id from EXTERN_VALUES_GROUP_MEMBERS
where extern_value_names_id in (select extern_value_names_id from EXTERN_VALUE_NAMES where extern_value_names_name like '%remote system url%')))and env_number = $ENV;
commit;
EOL`
fi

if [ -z $CUSTOM_22_BULK ]
then
echo "Value of EV Remote System URL for CUSTOM TYPE 22 not provided, nothing to update!"
else
echo "Running REMOTE SYSTEM URL (CAPITA REMPTE SYSTEM PARAMS - CUSTOM TYPE 22) EV update..."
sleep 2
bulk=`sqlplus -s foundation/foundation@magnolia << EOL
update EXTERN_VALUES_PER_ENV
set extern_values_value = '$CUSTOM_22_BULK'
where EXTERN_VALUES_ID in  (select EXTERN_VALUES_ID from extern_values  where
object_id in (22)
and
extern_values_group_members_id in (select extern_values_group_members_id from EXTERN_VALUES_GROUP_MEMBERS
where extern_value_names_id in (select extern_value_names_id from EXTERN_VALUE_NAMES where extern_value_names_name like '%remote system url%')))and env_number = $ENV;
commit;
EOL`
fi

if [ -z $CUSTOM_23_DISC ]
then
echo "Value of EV Remote System URL for CUSTOM TYPE 23 not provided, nothing to update!"
else
echo "Running REMOTE SYSTEM URL (CAPITA REMPTE SYSTEM PARAMS - CUSTOM TYPE 23) EV update..."
sleep 2
disc=`sqlplus -s foundation/foundation@magnolia << EOL
update EXTERN_VALUES_PER_ENV
set extern_values_value = '$CUSTOM_23_DISC'
where EXTERN_VALUES_ID in  (select EXTERN_VALUES_ID from extern_values  where
object_id in (23) and
extern_values_group_members_id in (select extern_values_group_members_id from EXTERN_VALUES_GROUP_MEMBERS
where extern_value_names_id in (select extern_value_names_id from EXTERN_VALUE_NAMES where extern_value_names_name like '%remote system url%')))and env_number = $ENV;
commit;
EOL`
fi

}

function NE()
{

if [ -z $LDAP ] 
then 
echo "Value of NE LDAP not provided, nothing to update!" 
else 
echo "Running LDAP NE update..."
sleep 2
ld=`sqlplus -s foundation/foundation@magnolia << EOL
update PROV_NETWORK_ELEMENT_PRIORITY 
set net_elem_server_ip = '$LDAP'
where net_elem_id in (
select net_elem_id from PROV_NETWORK_ELEMENTS where net_elem_name like 'LDAP');
commit;
EOL`
fi

if [ -z $GEOMANT ]
then
echo "Value of NE GEOMANT not provided, nothing to update!"
else
echo "Running GEOMANT NE update..."
sleep 2
geo=`sqlplus -s foundation/foundation@magnolia << EOL
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_ip = '$GEOMANT'
where net_elem_id in (
select net_elem_id from PROV_NETWORK_ELEMENTS where net_elem_name like 'GEOMANT');
commit;
EOL`
fi

if [ -z $CSS_PS ]
then
echo "Value of NE CSS-PS not provided, nothing to update!"
else
echo "Running CSS-PS NE update..."
sleep 2
css=`sqlplus -s foundation/foundation@magnolia << EOL
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_ip = '$CSS_PS'
where net_elem_id in (
select net_elem_id from PROV_NETWORK_ELEMENTS where net_elem_name like 'CSS-PS');
commit;
EOL`
fi

if [ -z $CPS_BAVS ]
then
echo "Value of NE CPS-BAVS not provided, nothing to update!"
else
echo "Running CPS-BAVS NE update..."
sleep 2
cps=`sqlplus -s foundation/foundation@magnolia << EOL
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_ip = '$CPS_BAVS'
where net_elem_id in (
select net_elem_id from PROV_NETWORK_ELEMENTS where net_elem_name like 'CPS-BAVS');
commit;
EOL`
fi

if [ -z $BIZTALK ]
then
echo "BIZTALK host not provided, NE/EV will not be updated!"
else
echo "Running Biztalk NE/EV update..."
sleep 2
ld=`sqlplus -s foundation/foundation@magnolia << EOL
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_ip = '$BIZTALK'
where net_elem_id in (
select net_elem_id from PROV_NETWORK_ELEMENTS where net_elem_name like 'biztalk');

insert into extern_values_per_env values ($ENV, 708946, 'http://'||'$BIZTALK'||'$bizEV');
commit;
EOL`
fi

}


function ACL()
{
echo "Running ACL Updates for Biztalk on Mag/Usage..."
sleep 2 
for j in MAGNOLIA USAGE
 do
   for i in $BIZTALK $BIZTALKIP
    do
     sqlplus -s admuser/housekeeping@$j << !
      declare
      rc sys_refcursor;
      begin
      configure_ftp_acl ('$i', 30550, rc);
      end;
      /
!
   done
 done

}



EV
NE
ACL
 

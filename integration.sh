#! /bin/bash

source env.cfg

IFS=$'\n'


ENV=`sqlplus -s $USERNAME/$PASSWORD@$DATABASE << EOF
set heading off;
select param_value_1 from params where param_name like 'CurrentEnv%';
EOF`



function EV()
{
for i in 'ER_HTML_PAGE' 'URL_ADDRESS' ; do
eVar=${i}
eVar=${!eVar}                        #indirection expansion
if [ -z $eVar ]; then
echo "Value of EV $i not provided, nothing to update!"
else echo "Running $i (CAPITA_CSR_BUSINESS_PARAMS) EV update..."
sleep 1
sqlplus -s $USERNAME/$PASSWORD@$DATABASE <<eol
set feedback off;
update EXTERN_VALUES_PER_ENV
set extern_values_value = '$eVar'
where EXTERN_VALUES_ID in (select EXTERN_VALUES_ID from extern_values where
extern_values_group_members_id in (select extern_values_group_members_id from EXTERN_VALUES_GROUP_MEMBERS
where extern_value_names_id in (select extern_value_names_id from EXTERN_VALUE_NAMES where extern_value_names_name like '$i'))) and env_number = $ENV;
commit;
eol
fi
done

for i in 21 22 23 ; do
  var=CUSTOM_${i}
  var=${!var}                             #indirection expansion
  if [ -z $var ]
   then
    echo "Value of EV CUSTOM_$i not provided, nothing to update!" 
  else 
   echo "Running CUSTOM_$i EV update..."
   query="(select EXTERN_VALUES_ID from extern_values where object_id in ($i) and
   extern_values_group_members_id in (select extern_values_group_members_id from EXTERN_VALUES_GROUP_MEMBERS
   where extern_value_names_id in (select extern_value_names_id from EXTERN_VALUE_NAMES where extern_value_names_name like 'Remote System URL')))and env_number = $ENV"
sleep 1
sqlplus -s $USERNAME/$PASSWORD@$DATABASE <<eof
set feedback off;
update EXTERN_VALUES_PER_ENV
set extern_values_value = '$var'
where EXTERN_VALUES_ID in $query;
commit;
eof
fi
done

ld=`sqlplus -s $USERNAME/$PASSWORD@$DATABASE<<eol
set heading off; 
select count(*) from extern_values_per_env where EXTERN_VALUES_ID = 708946 and env_number = $ENV;
eol`
if [ $ld -eq 1 ]; then
sqlplus -s $USERNAME/$PASSWORD@$DATABASE<<eol
set feedback off;
update extern_values_per_env set extern_values_value = 'http://'||'$BIZTALK'||'$bizEV'
where EXTERN_VALUES_ID = 708946;
commit;
eol
elif [ $ld -eq 0 ]; then
sqlplus -s  $USERNAME/$PASSWORD@$DATABASE<<eol
set feedback off;
insert into extern_values_per_env values ($ENV, 708946, 'http://'||'$BIZTALK'||'$bizEV');
commit;
eol
fi

}

function NE()
{

for i in 'LDAP' 'BIZTALK' 'CSS_PS' 'CPS_BAVS' 'GEOMANT'; do
   nevar=${i}
   nevar=${!nevar}                          #indirection expansion
   if [ -z $nevar ]; then
     echo "value of $i not provided, NE will not be updated!"
   else
    echo "Running $i NE update..."
sleep 1
sqlplus -s $USERNAME/$PASSWORD@$DATABASE<<eof
set feedback off;
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_ip = '$nevar'
where net_elem_priority_name like '%$i%';
commit;
eof
  fi
done
}

function PORT()
{
if [ ! -z $ldPort ]; then
sqlplus -s $USERNAME/$PASSWORD@$DATABASE<<eol
set feedback off;
update PROV_NETWORK_ELEMENT_PRIORITY 
set net_elem_server_port = $ldPort
where net_elem_priority_name like '%LDAP%';
commit;
eol
fi
if [ ! -z $gtPort ]; then
sqlplus -s $USERNAME/$PASSWORD@$DATABASE<<eol
set feedback off;
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_port = $gtPort
where net_elem_priority_name like '%GEOMANT%';
commit;
eol
fi
if [ ! -z $cssPort ]; then 
sqlplus -s $USERNAME/$PASSWORD@$DATABASE<<eol
set feedback off;
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_port = $cssPort
where net_elem_priority_name like '%CSS-PS%';
commit;
eol
fi
if [ ! -z $cpsPort ]; then
sqlplus -s $USERNAME/$PASSWORD@$DATABASE<<eol
set feedback off;
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_port = $cpsPort
where net_elem_priority_name like '%CPS-BAVS%';
commit;
eol
fi
if [ ! -z $btPort ]; then
sqlplus -s $USERNAME/$PASSWORD@$DATABASE<<eol
set feedback off;
update PROV_NETWORK_ELEMENT_PRIORITY
set net_elem_server_port = $btPort
where net_elem_priority_name like '%BIZTALK%';
commit;
eol
fi
}




EV
NE
PORT

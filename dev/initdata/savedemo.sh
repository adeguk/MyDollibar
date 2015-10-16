#!/bin/sh
#------------------------------------------------------
# Script to extrac a database with demo values.
# Note: "dialog" tool need to be available if no parameter provided.
#
# Regis Houssin       - regis.houssin@capnetworks.com
# Laurent Destailleur - eldy@users.sourceforge.net
#------------------------------------------------------
# Usage: savedemo.sh
# usage: savedemo.sh mysqldump_dolibarr_x.x.x.sql database port login pass
#------------------------------------------------------


export mydir=`echo "$0" | sed -e 's/savedemo.sh//'`;
if [ "x$mydir" = "x" ]
then
    export mydir="."
fi
export id=`id -u`;


# ----------------------------- check if root
if [ "x$id" != "x0" -a "x$id" != "x1001" ]
then
	echo "Script must be ran as root"
	exit
fi


# ----------------------------- command line params
dumpfile=$1;
base=$2;
port=$3;
admin=$4;
passwd=$5;


# ----------------------------- if no params on command line
if [ "x$passwd" = "x" ]
then
	export dumpfile=`ls $mydir/mysqldump_dolibarr_*.sql | sort | tail -n 1`
	export dumpfile=`basename $dumpfile`

	# ----------------------------- input file
	DIALOG=${DIALOG=dialog}
	DIALOG="$DIALOG --ascii-lines"
	fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
	trap "rm -f $fichtemp" 0 1 2 5 15
	$DIALOG --title "Save Dolibarr with demo values" --clear \
	        --inputbox "Output dump file :" 16 55 $dumpfile 2> $fichtemp
	valret=$?
	case $valret in
	  0)
	dumpfile=`cat $fichtemp`;;
	  1)
	exit;;
	  255)
	exit;;
	esac
	
	# ----------------------------- database name
	DIALOG=${DIALOG=dialog}
	DIALOG="$DIALOG --ascii-lines"
	fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
	trap "rm -f $fichtemp" 0 1 2 5 15
	$DIALOG --title "Save Dolibarr with demo values" --clear \
	        --inputbox "Mysql database name :" 16 55 dolibarrdemo 2> $fichtemp
	valret=$?
	case $valret in
	  0)
	base=`cat $fichtemp`;;
	  1)
	exit;;
	  255)
	exit;;
	esac
	
	# ---------------------------- database port
	DIALOG=${DIALOG=dialog}
	fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
	trap "rm -f $fichtemp" 0 1 2 5 15
	$DIALOG --title "Save Dolibarr with demo values" --clear \
	        --inputbox "Mysql port (ex: 3306):" 16 55 3306 2> $fichtemp
	
	valret=$?
	
	case $valret in
	  0)
	port=`cat $fichtemp`;;
	  1)
	exit;;
	  255)
	exit;;
	esac
	
	# ---------------------------- compte admin mysql
	DIALOG=${DIALOG=dialog}
	fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
	trap "rm -f $fichtemp" 0 1 2 5 15
	$DIALOG --title "Save Dolibarr with demo values" --clear \
	        --inputbox "Mysql root login (ex: root):" 16 55 root 2> $fichtemp
	
	valret=$?
	
	case $valret in
	  0)
	admin=`cat $fichtemp`;;
	  1)
	exit;;
	  255)
	exit;;
	esac
	
	# ---------------------------- mot de passe admin mysql
	DIALOG=${DIALOG=dialog}
	fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
	trap "rm -f $fichtemp" 0 1 2 5 15
	$DIALOG --title "Save Dolibarr with demo values" --clear \
	        --inputbox "Password for Mysql root login :" 16 55 2> $fichtemp
	
	valret=$?
	
	case $valret in
	  0)
	passwd=`cat $fichtemp`;;
	  1)
	exit;;
	  255)
	exit;;
	esac
	
	# ---------------------------- chemin d'acces du repertoire documents
	#DIALOG=${DIALOG=dialog}
	#fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
	#trap "rm -f $fichtemp" 0 1 2 5 15
	#$DIALOG --title "Save Dolibarr with demo values" --clear \
	#        --inputbox "Full path to documents directory (ex: /var/www/dolibarr/documents)- no / at end :" 16 55 2> $fichtemp
	
	#valret=$?
	
	#case $valret in
	#  0)
	#docs=`cat $fichtemp`;;
	#  1)
	#exit;;
	#  255)
	#exit;;
	#esac
	
	# ---------------------------- confirmation
	DIALOG=${DIALOG=dialog}
	$DIALOG --title "Save Dolibarr with demo values" --clear \
	        --yesno "Do you confirm ? \n Dump file : '$dumpfile' \n Dump dir : '$mydir' \n Mysql database : '$base' \n Mysql port : '$port' \n Mysql login: '$admin' \n Mysql password : '$passwd'" 15 55
	
	case $? in
	        0)      echo "Ok, start process...";;
	        1)      exit;;
	        255)    exit;;
	esac

fi


# ---------------------------- run sql file
if [ "x$passwd" != "x" ]
then
	export passwd="-p$passwd"
fi
export list="
    --ignore-table=$base.llx_abonne
    --ignore-table=$base.llx_abonne_extrafields 
    --ignore-table=$base.llx_abonne_type
    --ignore-table=$base.llx_abonnement 
	--ignore-table=$base.llx_bootstrap
	--ignore-table=$base.llx_bt_namemap
	--ignore-table=$base.llx_bt_speedlimit
	--ignore-table=$base.llx_bt_summary
	--ignore-table=$base.llx_bt_timestamps
	--ignore-table=$base.llx_bt_webseedfiles
	--ignore-table=$base.llx_dolicloud_customers
	--ignore-table=$base.llx_dolicloud_stats
	--ignore-table=$base.llx_c_dolicloud_plans
	--ignore-table=$base.llx_cabinetmed_c_banques
	--ignore-table=$base.llx_cabinetmed_c_ccam
	--ignore-table=$base.llx_cabinetmed_c_examconclusion
	--ignore-table=$base.llx_cabinetmed_cons
	--ignore-table=$base.llx_cabinetmed_diaglec
	--ignore-table=$base.llx_cabinetmed_examaut
	--ignore-table=$base.llx_cabinetmed_exambio
	--ignore-table=$base.llx_cabinetmed_examenprescrit
	--ignore-table=$base.llx_cabinetmed_motifcons
	--ignore-table=$base.llx_cabinetmed_patient
	--ignore-table=$base.llx_cabinetmed_societe
	--ignore-table=$base.llx_fournisseur_ca
	--ignore-table=$base.llx_google_maps
	--ignore-table=$base.llx_notes
	--ignore-table=$base.llx_pos_paiement_ticket
	--ignore-table=$base.llx_pos_places
	--ignore-table=$base.llx_pos_ticket
	--ignore-table=$base.llx_publi_c_contact_list 
	--ignore-table=$base.llx_publi_c_dnd_list
	--ignore-table=$base.llx_publi_c_method_list
	--ignore-table=$base.llx_ultimatepdf
	--ignore-table=$base.llx_ventilation_achat
	" 
echo "mysqldump -P$port -u$admin -p***** $list $base > $mydir/$dumpfile"
mysqldump -P$port -u$admin $passwd $list $base > $mydir/$dumpfile
export res=$?

if [ "x$res" = "x0" ]
then
	echo "Success, file successfully loaded."
else
	echo "Error, load failed."
fi
echo

#!/bin/bash

ls /media/slackware64 2> /dev/null
if [[ "$?" != "0" ]]; then  echo "slackware install media not mounted on /media"; exit 1; fi

## can be slackware or slackware64
slackFolder=slackware
ls -d /media/slackware64/FILE_LIST > /dev/null
if [[ $? == 0 ]]; then
	slackFolder=slackware64
fi

ls /media/${slackFolder}/FILE_LIST > /dev/null
if [[ $? != 0 ]]; then 
	echo "slackware install directory structure unrecognized."
	echo "report slackware version and this message."
	exit 1
fi

PKG_HAVE=/tmp/packages
ALL_PAK=/tmp/ALL_PAK
TAGS=/tmp/TAG_FILE_INSTALL
MOTO="`pwd`"

ls /var/log/packages/ > ${PKG_HAVE}
grep \.txz$ /media/${slackFolder}/FILE_LIST > ${ALL_PAK}
rm -r ${TAGS}
mkdir ${TAGS}

## makes tag file directory structure
cd /media/${slackFolder}
ls -d */  | while read -r line; do 
  mkdir ${TAGS}/${line}
done
cd ${MOTO}

echo '(' > /tmp/CHAR_PREVIOUS
rm /tmp/PKG_NAMES
grep "^[a-zA-Z0-9_.+-]*:" /media/${slackFolder}/PACKAGES.TXT  > /tmp/PKG_NAMES_NEEDS_TRIMMED
  cat /tmp/PKG_NAMES_NEEDS_TRIMMED | while read line; do
        PKG="${line%%:*}"
	echo ${PKG} >> /tmp/PKG_NAMES
  done
  uniq /tmp/PKG_NAMES  /tmp/PKG_NAMES_U
#  sort -r /tmp/PKG_NAMES_U > /tmp/PKG_NAMES_UNIQ
  sort  /tmp/PKG_NAMES_U > /tmp/PKG_NAMES_UNIQ
  sort  /tmp/PKG_NAMES_UNIQ > /tmp/PKG_NAMES_UNIQ_SORTED_SMALL_BIG

cat ${ALL_PAK} | while read line; do
  PATH_AND_PKG=`echo "${line}" | awk '{print $8}'`
  PATH_AND_PKG_NO_SUFFIX=`echo "${PATH_AND_PKG}" | sed 's/.txz$//'`
  PKG2="${PATH_AND_PKG_NO_SUFFIX##*/}"
  VERSION="${PATH_AND_PKG_NO_SUFFIX#*-}"
  PKG="${PKG2:2}"
  PKG=${PKG2}
  PATH_FILE="${PATH_AND_PKG_NO_SUFFIX:2}"
  PKG_SERIES="${PATH_FILE%%/*}"

  PKG_NAM=0
  FIRST_CHAR_PKG="${PKG:0:1}"
  SECOND_CHAR_PKG="${PKG:1:1}"
  echo ${FIRST_CHAR_PKG}${SECOND_CHAR_PKG} > /tmp/CHAR_CURRENT
  diff /tmp/CHAR_CURRENT /tmp/CHAR_PREVIOUS > /dev/null
  if [[ $? != 0 ]]; then echo ${FIRST_CHAR_PKG}${SECOND_CHAR_PKG} > /tmp/CHAR_PREVIOUS ; grep "^${FIRST_CHAR_PKG}${SECOND_CHAR_PKG}" /tmp/PKG_NAMES_UNIQ > /tmp/CACHE_GREP; fi 

  ## Gets pkgname by matching smallest alpha and len to biggest. END MATCH == best match.
  while read pkgnam; do
      echo ${PATH_AND_PKG_NO_SUFFIX} | grep "/${pkgnam}-" > /dev/null
      if [[ $? == 0 ]]; then PKG_NAM=${pkgnam}; fi
  done < <(cat /tmp/CACHE_GREP)
  PP="${PKG2:2}"
#echo "K${PATH_AND_PKG_NO_SUFFIX}K"

 	  grep "^${PKG_NAM}-" ${PKG_HAVE} > /dev/null 
	  if [[ $? -eq 0 && "$PKG_NAM" != "0" ]]; then 
		  echo ${PKG_NAM}:ADD
		  echo ${PKG_NAM}:ADD >> ${TAGS}/${PKG_SERIES}/tagfile
	  else
		  echo ${PKG_NAM}:SKP
		  echo ${PKG_NAM}:SKP >> ${TAGS}/${PKG_SERIES}/tagfile
		  if [[ "${PKG_NAM}" == "0" ]]; then 
			  echo "${PKG_NAM} --${PKG} -FROM ${PATH_AND_PKG_NO_SUFFIX} -F ${PATH_AND_PKG}" >>${TAGS}/${PKG_SERIES}/tagfile
			  echo "${PKG_NAM} --${PKG} -FROM ${PATH_AND_PKG_NO_SUFFIX} -F ${PATH_AND_PKG}" 
	
			  echo ""
			  echo "ERROR AT SERIES [ ${PKG_SERIES} ]"
			  echo "Package: [ ${PKG_NAM} ], matching full ${line}"
			  echo 'exiting...'
			  exit 1
                  fi
          fi
  if [[ "${PKG_NAM}" == "sysvinit" ]]; then echo "${PKG_NAM} != ${PATH_AND_PKG}"; fi
 done


cd "${TAGS}"
ls -d */ | while read d; do echo -SERIES: >> ./SANITY_CHECK; cat tagfile | while read line; do echo   >> ./SANITY_CHECK; done; done; echo 'CHECK FOR DUPLICATES [ ERRORS ]: '; sort SANITY_CHECK | uniq -c | less | grep -v "^[[:space:]]*1[[:space:]]" 

cd "${MOTO}"
exit 0

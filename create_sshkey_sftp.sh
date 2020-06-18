#!/bin/bash

#variables
declare -a envs=("play" "sbx" "qa" "stg")

if [ -z $1 ] || [ -z $2 ]; then
  echo 'Usage: create_sshkey.sh <directory-or-service> <user-name>'
  exit 1
fi

#verifing dependencies
function pkg_zip_exists() {
  return dpkg -l "zip" &> /dev/null
}
if [ ! pkg_zip_exists ]; then
  echo "Please install zip!"
  exit 1
fi

#creating folders
for i in "${envs[@]}"; do
   mkdir -p $i/$1
   if [ $? -gt 0 ]; then
     echo "Error to create folder $i"
     exit 1
   fi
done

#creating keys
for i in "${envs[@]}"; do
   echo "creating keys in $i.."
   ssh-keygen -q -f $i/$1/$2@$1-$i -N ""
   if [ $? -gt 0 ]; then
     echo "Error to create $i's keys"
     exit 1
   fi
done

#creating zip files
echo 'Compressing files...'
for i in "${envs[@]}"; do
   echo 'Adding $i/$1/$2@$1-$i.pub in $2@$1-public.zip file...'
   zip -q -u $2@$1-public.zip $i/$1/$2@$1-$i.pub
   if [ $? -gt 0 ]; then
     echo "Error to create $i's public zip file"
     exit 1
   fi
   echo 'Adding $i/$1/$2@$1-$i in $2@$1-private.zip file...'
   zip -q -u $2@$1-private.zip $i/$1/$2@$1-$i
   if [ $? -gt 0 ]; then
     echo "Error to create $i's private zip file"
     exit 1
   fi
done

echo "Done!."

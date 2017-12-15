#!/bin/bash

#$1 = S3 Path like "bucket-name/folder1/folder3"
#$2 = Regular expression to grep files
#$3 = Older then given days

scan_path=$1
reg_ex=$2
day_count=$3

bucket_name=`echo $scan_path | awk -F"/" '{ print $1}'`
echo "Bucket Name : "$bucket_name
old_string="outbound"
new_string="outboud_processed"

aws s3 ls --recursive s3://$scan_path | grep -E $reg_ex | while read -r line;
do
        #echo "File Details : " $line
        file_date=`echo $line|awk {'print $1" "$2'}`
        
		file_date=$(date -d "$file_date" +%s)
        
		current_date=$(date +%s)
        
		days_diff=$(( (current_date - file_date) / 86400 ))
		#echo $days_diff "day(s)"
		if [[ $days_diff -gt $day_count ]]
		then
			source_path=$bucket_name"/"`echo $line|awk {'print $4'}`
			destination_path=`echo $source_path | sed 's/'$old_string'/'$new_string'/g'`
			echo "Source : s3://"$source_path
			echo "Destination : s3://"$destination_path
			aws s3 mv "s3://"$source_path "s3://"$destination_path
		fi;
done;

#!/bin/bash
for study_accession in ERP021896 ERP020023 ERP020508 ERP017166 ERP020507 ERP017221 ERP016412 ERP020884 ERP020022 ERP020510
do
    count=-1 
curl -s "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=${study_accession}&result=read_run&fields=secondary_sample_accession,submitted_ftp" | grep -v "^secondary_sample_accession" > ${study_accession}.details.txt

    for fq in `awk '{print $1, $2}' ${study_accession}.details.txt`
    do
        ((count++))
        if [[ $(( count % 2)) -eq 0 ]]
        then
            id=$fq
            current_path=${study_accession}/${id}
            current_base=${current_path}/${id}

            if [ -d "${current_path}" ]; then
                continue
            fi
            echo "Fetching ${id}..."

            mkdir -p ${current_path}
            curl -s "http://www.ebi.ac.uk/ena/data/view/${id}&display=xml" > ${current_base}.xml &
        else
            if [ -e "${current_base}.fna" ]; then
                continue
            fi

            # sed from http://stackoverflow.com/a/10359425/19741
            curl -s $fq | zcat | sed -n '1~4s/^@/>/p;2~4p' > ${current_base}.fna &
        fi

        if [[ $((count % 10)) -eq 0 ]]
        then
            wait
        fi
    done
done

wait

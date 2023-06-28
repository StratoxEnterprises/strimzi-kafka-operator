#!/usr/bin/env bash
set -e

VERSIONS_FILE="$(dirname $(realpath $BASH_SOURCE))/../kafka-versions.yaml"

# Gets the default Kafka version and sets "default_kafka_version" variable
# to the corresponding version string.
function get_default_kafka_version {

    finished=0
    counter=0
    default_kafka_version="null"
    while [ $finished -lt 1 ] 
    do
        version="$(yq eval ".[${counter}].version" $VERSIONS_FILE )"

        if [ "$version" = "null" ]
        then
            finished=1
        else
            if [ "$(yq eval ".[${counter}].default" $VERSIONS_FILE)" = "true" ]
            then
                if [ "$default_kafka_version" = "null" ]
                then
                    default_kafka_version=$version
                    finished=1
                else
                    # We have multiple defaults so there is an error in the versions file
                    >&2 echo "ERROR: There are multiple Kafka versions set as default"
                    unset default_kafka_version
                    exit 1
                fi
            fi
            counter=$((counter+1))
        fi
    done

    unset finished
    unset counter
    unset version

}

function get_kafka_versions {
    eval versions="($(yq eval '.[] | select(.supported == true) | .version' $VERSIONS_FILE))"
}

function get_kafka_urls {
    eval binary_urls="($(yq eval '.[] | select(.supported == true) | .url' $VERSIONS_FILE))"
}

function get_zookeeper_versions {
    eval zk_versions="($(yq eval '.[] | select(.supported == true) | .zookeeper' $VERSIONS_FILE))"
}

function get_kafka_checksums {
    eval checksums="($(yq eval '.[] | select(.supported == true) | .checksum' $VERSIONS_FILE))"
}

function get_kafka_third_party_libs {
    eval libs="($(yq eval '.[] | select(.supported == true) | .third-party-libs' $VERSIONS_FILE))"
}

function get_unique_kafka_third_party_libs {
    eval libs="($(yq eval '.[] | select(.supported == true) | .third-party-libs' $VERSIONS_FILE | sort -u))"
}

function get_kafka_protocols {
    eval protocols="($(yq eval '.[] | select(.supported == true) | .protocol' $VERSIONS_FILE))"
}

function get_kafka_formats {
    eval formats="($(yq eval '.[] | select(.supported == true) | .format' $VERSIONS_FILE))"
}

function get_kafka_does_not_support {
    eval does_not_support="($(yq eval '.[] | select(.supported == true) | .unsupported-features' $VERSIONS_FILE))"

    get_kafka_versions
    
    declare -a version_does_not_support
    for i in "${!versions[@]}"
    do 
        version_does_not_support[${versions[$i]}]=${does_not_support[$i]}
    done
}

# Parses the Kafka versions file and creates three associative arrays:
# "version_binary_urls": Maps from version string to url from which the kafka source 
# tar will be downloaded.
# "version_checksums": Maps from version string to sha512 checksum.
# "version_libs": Maps from version string to third party library version string.
function get_version_maps {
    get_kafka_versions
    get_kafka_urls
    get_kafka_checksums
    get_kafka_third_party_libs
    
    declare -a version_binary_urls
    declare -a version_checksums
    declare -a version_libs
    
    for i in "${!versions[@]}"
    do
      echo ${i}

      echo ${versions[$i]}

       echo ${binary_urls[$i]}
       echo ${checksums[$i]}
       echo ${libs[$i]}

    done


         version_binary_urls[0]="2.8.0"
         version_binary_urls[1]="2.8.1"
         version_binary_urls[2]="3.0.0"
         version_checksums[0]="https://archive.apache.org/dist/kafka/2.8.0/kafka_2.13-2.8.0.tgz"
         version_checksums[1]="https://archive.apache.org/dist/kafka/2.8.1/kafka_2.13-2.8.1.tgz"
         version_checksums[2]="https://archive.apache.org/dist/kafka/3.0.0/kafka_2.13-3.0.0.tgz"
         version_libs[0]="3C49DCA1147A0A249DD88E089F40AF31A67B8207ED2D9E2294FA9A6D41F5ED0B006943CD60D8E30D7E69D760D398F299CAFCD68B6ED7BEDF9F93D1B7A9E8C487"
         version_libs[1]="91FCD1061247AD0DDB63FA2B5C0251EE0E58E60CC9E1A3EBE2E84E9A31872448A36622DD15868DE2C6D3F7E26020A8C61477BC764E2FB6776A25E4344EB8892D"
         version_libs[2]="86CDEB04AF123399858D03431E9777948C1C40EC0D843966CF9BD90B8235B47EBBB5CB96D1F0660710B9286DA86BBB5EE65E21E757606F5A1E67F970AE5CF57C"
}

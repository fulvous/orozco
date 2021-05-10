#!/bin/bash

WD=$( cd "$(dirname "$0")" && pwd )

#Cargando herramientax
source $WD/libs/herramientax/libs/formato/colores.sh
source $WD/libs/herramientax/libs/formato/dialogos.sh

function uso {
  SCRIPT=$( basename "$0" )
  jumbotron "Uso: ${SCRIPT} [ -w [size] | -v ] " \
    " -w    Cambiar tamano de ancho maximo" \
    " -v    Activa el debug"
  exit 1
}

while getopts "w:v" OPTS ; do
  case "${OPTS}" in
    "w") 
        if [ ! -z "${OPTARG}" ] ; then
          WIDTH=${OPTARG}
        fi
      ;;
    "v") VERBOSE=1
      ;;
    "?") uso
      ;;
  esac
done
shift $(($OPTIND -1))




if [ ! -z "${1}" ]
then
  IMGDIR="${1}"
else
  IMGDIR="$(pwd)"
fi

cd ${IMGDIR}
debug "Working on ${IMGDIR}"







function orozco {

  if [ ! -z "${WIDTH}" ]
  then
    debug "Looking images for resize to max-width ${WIDTH}"
    for IMAGE in $( find -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.JPG" -o -name "*.JPEG" \) | sed 's/ /@/g' )
    do
      ORIGINAL=$( echo $IMAGE | sed 's/@/ /g' )
      ORIGINAL_WIDTH=$( identify -format '%w' ${IMAGE} )
      debug "$ORIGINAL width ${ORIGINAL_WIDTH}"
      if [ ${ORIGINAL_WIDTH} -gt ${WIDTH} ]
      then
        debug "Image needs resize"
        convert "${ORIGINAL}" -resize ${WIDTH} "${ORIGINAL}.tmp"
        rm "${ORIGINAL}"
        mv "${ORIGINAL}.tmp" "${ORIGINAL}"
        informa "${ORIGINAL}" "resized to max width" "${WIDTH}"
      fi
      jpegoptim --force --max=70 ${ORIGINAL}
    done
  fi


  for DIRECTORY in *
  do
    if [ -d "$DIRECTORY" ]
    then
      cd $DIRECTORY
      debug $DIRECTORY
      orozco
      cd ..
    fi
  done
  echo
}

orozco

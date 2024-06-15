#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
elif [[ $1 =~ [0-9]+ ]]
then
  ELEMENT_DATA="$($PSQL "SELECT atomic_number,symbol,name,atomic_mass,type,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1;")" 
  echo $ELEMENT_DATA | while IFS="|" read ATOMIC_NUMBER SYMBOL ELEMENT_NAME ATOMIC_MASS TYPE MELTING_POINT BOILING_POINT 
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
elif [[ $1 =~ [a-zA-Z]+ ]]
then
  ELEMENT_DATA="$($PSQL "SELECT atomic_number,symbol,name,atomic_mass,type,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE (symbol='$1' OR name='$1')")" 
  if [[ -z $ELEMENT_DATA ]]
  then
    echo "I could not find that element in the database."
  else
    echo $ELEMENT_DATA | while IFS="|" read ATOMIC_NUMBER SYMBOL ELEMENT_NAME ATOMIC_MASS TYPE MELTING_POINT BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
else
  echo "I could not find that element in the database."
fi
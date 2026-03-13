#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# check if argument exists
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else

  # if input is a number (atomic number)
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_INFO=$($PSQL "
      SELECT atomic_number, symbol, name, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius
      FROM elements
      JOIN properties USING(atomic_number)
      JOIN types USING(type_id)
      WHERE atomic_number=$1
    ")

  # if input is a symbol
  elif [[ ${#1} -le 2 ]]
  then
    ELEMENT_INFO=$($PSQL "
      SELECT atomic_number, symbol, name, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius
      FROM elements
      JOIN properties USING(atomic_number)
      JOIN types USING(type_id)
      WHERE symbol='$1'
    ")

  # otherwise treat as name
  else
    ELEMENT_INFO=$($PSQL "
      SELECT atomic_number, symbol, name, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius
      FROM elements
      JOIN properties USING(atomic_number)
      JOIN types USING(type_id)
      WHERE name='$1'
    ")
  fi

  # if no result
  if [[ -z $ELEMENT_INFO ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC SYMBOL NAME TYPE MASS MELT BOIL
    do
      echo "The element with atomic number $ATOMIC is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done
  fi
fi

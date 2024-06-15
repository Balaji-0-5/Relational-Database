#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(($(($RANDOM%1000))+1))

MAIN_MENU() {
  echo "Enter your username:"
  read USERNAME
  if [[ -z $USERNAME ]]
  then
    MAIN_MENU
  else
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
    if [[ $USER_ID ]]
    then
      USER_DATA=$($PSQL "SELECT COUNT(*),MIN(no_of_guesses) FROM users INNER JOIN games USING(user_id) GROUP BY(user_id) HAVING user_id=$USER_ID;")
      echo $USER_DATA | while IFS="|" read GAMES_PLAYED BEST_GAME
      do
        echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      done
    else
      ADD_USER=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME');")
      if [[ $ADD_USER == "INSERT 0 1" ]]
      then
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
        echo "Welcome, $USERNAME! It looks like this is your first time here."
      fi 
    fi
    RUN_GAME "$USER_ID"
  fi

}


RUN_GAME() {
  echo "Guess the secret number between 1 and 1000:"
  GUESS=-1
  NO_OF_GUESSES=0
  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    read GUESS
    ((NUMBER_OF_GUESSES++))
    if [[ ! $GUESS =~ [0-9]+ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      ADD_GAME=$($PSQL "INSERT INTO games(user_id,no_of_guesses) VALUES ($USER_ID,$NUMBER_OF_GUESSES);") 
      if [[ $ADD_GAME == "INSERT 0 1" ]]
      then
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      fi      
    fi
  done

}

MAIN_MENU
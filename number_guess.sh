#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

R=$(($RANDOM % 1000 +1))

echo -e "\nEnter your username:"
read USERNAME
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_RESULT ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  USER=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, 0)")
  GAMES_PLAYED=0
  BEST_GAME=0
else
 GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
 BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

 echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=0
while [[ $GUESS != $R ]]
do

 ((NUMBER_OF_GUESSES=NUMBER_OF_GUESSES+1))

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
    read GUESS
  else
    if [[ $GUESS -gt $R ]]
    then
      echo -e "It's lower than that, guess again:"
      read GUESS
    elif [[ $GUESS -lt $R ]]
    then
      echo -e "It's higher than that, guess again:"
      read GUESS
    fi
  fi


done

((NUMBER_OF_GUESSES=NUMBER_OF_GUESSES+1))
if [[ $BEST_GAME > $NUMBER_OF_GUESSES ]] || [[ $BEST_GAME == 0 ]]
then
  ((BEST_GAME = NUMBER_OF_GUESSES)) 
fi
((GAMES_PLAYED=GAMES_PLAYED+1)) 
GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")

echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $R. Nice job!"
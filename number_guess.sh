#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo Enter your username:
read USERNAME
USER_FOUND=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if [[ ! -z $USER_FOUND ]]
then echo $USER_FOUND | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do 
  echo -e Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
#  `Welcome\\s+back,\\s+${username1}!\\s+You\\s+have\\s+played\\s+1\\s+games?,\\s+and\\s+your\\s+best\\s+game\\s+took\\s+${guesses}\\s+guess(es)?\\.`
  done
else
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
fi
echo $RANDOM_NUMBER
echo Guess the secret number between 1 and 1000:
read GUESS
TOTAL_GUESSES=1
while [[ $GUESS != $RANDOM_NUMBER ]]
do
  if [[ ! $GUESS =~ [0-9]+ ]]
  then
  TOTAL_GUESSES=$(( $TOTAL_GUESSES + 1 ))
  echo That is not an integer, guess again:
  read GUESS
  else
    if [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
    TOTAL_GUESSES=$(( $TOTAL_GUESSES + 1 ))
    echo "It's lower than that, guess again:"
    read GUESS
    else 
    TOTAL_GUESSES=$(( $TOTAL_GUESSES + 1 ))
    echo "It's higher than that, guess again:"
    read GUESS
    fi
 
  fi
done
echo You guessed it in $TOTAL_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [[ ! -z $BEST_GAME ]]
then 
  if [[ $TOTAL_GUESSES -lt $BEST_GAME ]]
  then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $TOTAL_GUESSES WHERE username='$USERNAME'")
  fi
else
UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $TOTAL_GUESSES WHERE username='$USERNAME'")
fi

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
GAMES_PLAYED_UPDATED=$(( $GAMES_PLAYED + 1 ))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED_UPDATED WHERE username='$USERNAME'")
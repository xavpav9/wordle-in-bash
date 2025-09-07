#!/bin/bash

clear
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOUR="\e[0m"

win=false
previousGuesses=()




getWord() {
  word=""
  while [ ${#word} -ne 5 ]
  do
    echo -e "\nEnter a five letter word: "
    read word
  done
}

chooseWord() {
  if [ -z "$1" ]
  then
    lines=$(wc -l wordle-list | cut -d" " -f1)
    line=$(($RANDOM % $lines))
    answer=$(cat -n wordle-list | grep -w $line | cut -f2)
  else
    checkList $1
    if $valid
    then
      echo -e "Valid starting word."
      answer=$1
    else
      echo -e "Invalid starting word \"$1\", so picking a random word."
      lines=$(wc -l wordle-list | cut -d" " -f1)
      line=$(($RANDOM % $lines))
      answer=$(cat -n wordle-list | grep -w $line | cut -f2)
    fi
  fi
}

checkList() {
  if [ $(grep -w $1 valid-wordle-list | wc -l) -eq 0 ]
  then
    valid=false
  else
    valid=true
  fi
}

checkWord () {
  currentAnswer=$answer
  declare -a colours=()
  for letterIndex in $(seq 0 $((${#word} - 1)))
  do
    if [ ${word:$letterIndex:1} = ${answer:$letterIndex:1} ]
    then
      colours+=("green")
      currentAnswer="${currentAnswer:0:$(($letterIndex - 5 + ${#currentAnswer}))}${currentAnswer:$(($letterIndex + 1 - 5 + ${#currentAnswer}))}"
    else
      colours+=("not-green")
    fi
  done


  colouredWord=""
  for letterIndex in $(seq 0 $((${#word} - 1)))
  do
    if [ ${colours[letterIndex]} = "green" ]
    then
      colouredWord="$colouredWord$GREEN${word:$letterIndex:1}$ENDCOLOUR"
    else
      inWord=false
      for answerLetterIndex in $(seq 0 $((${#currentAnswer} - 1)))
      do
        if [ ${word:$letterIndex:1} = ${currentAnswer:$answerLetterIndex:1} ]
        then
          inWord=true
          break
        fi
      done

      if $inWord
      then
        colouredWord="$colouredWord$YELLOW${word:$letterIndex:1}$ENDCOLOUR"
        currentAnswer="${currentAnswer:0:$answerLetterIndex}${currentAnswer:$(($answerLetterIndex + 1))}"
      else
        colouredWord="$colouredWord$RED${word:$letterIndex:1}$ENDCOLOUR"
      fi
    fi
  done

  previousGuesses+=($colouredWord)
  if [ $word = $answer ]
  then
    win=true  
  fi
}

displayPreviousGuesses() {
  clear
  num=1
  for guess in ${previousGuesses[@]}
  do
    echo -n $num": "
    echo -e $guess
    ((num++))
  done
}

displayKeyboard() {
  local COLUMNS=$(tput cols)
  local firstRow=("q" "w" "e" "r" "t" "y" "u" "i" "o" "p")
  local firstRowSpace=$(($(($COLUMNS - ${#firstRow[@]} - ${#firstRow[@]} + 1)) / 2))
  local secondRow=("a" "s" "d" "f" "g" "h" "j" "k" "l")
  local secondRowSpace=$(($(($COLUMNS - ${#secondRow[@]} - ${#secondRow[@]} + 1)) / 2))
  local thirdRow=("z" "x" "c" "v" "b" "n" "m")
  local thirdRowSpace=$(($(($COLUMNS - ${#thirdRow[@]} - ${#thirdRow[@]} + 1)) / 2))

  for i in $(seq 1 $firstRowSpace)
  do
    echo -n " "
  done
  for char in ${firstRow[@]}
  do
    echo -n "$char " 
  done
  echo

  for i in $(seq 1 $secondRowSpace)
  do
    echo -n " "
  done
  for char in ${secondRow[@]}
  do
    echo -n "$char " 
  done
  echo

  for i in $(seq 1 $thirdRowSpace)
  do
    echo -n " "
  done
  for char in ${thirdRow[@]}
  do
    echo -n "$char " 
  done
  echo
}


chooseWord $1
for i in {1..6}
do
  valid=false
  getWord
  checkList $word

  while [ $valid = false ]
  do
    getWord
    checkList $word
  done

  checkWord
  displayPreviousGuesses

  if $win
  then
    echo -e "\nYou Win"
    break
  elif [ $i -eq 6 ]
  then
    echo -e "\nYou Lose"
    echo "The word was $answer."
  fi
done



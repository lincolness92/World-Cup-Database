#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

$PSQL "TRUNCATE TABLE games, teams"

#Path to games.csv
GAMES=./games.csv

#Read unique teams and insert into teams table
awk -F, 'NR > 1 {print $3; print $4}' "$GAMES" | sort | uniq | while read -r team; do
team=$(echo $team | xargs)

#query the database $($PSQL "<query here>") and insert teams into it
$PSQL "INSERT INTO teams(name) VALUES('$team') ON CONFLICT (name) DO NOTHING;"
done

#populate games table
tail -n +2 "$GAMES" | while IFS=, read -r year round winner opponent winner_goals opponent_goals; do

#get winner_id
winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
winner_id=$(echo $winner_id | xargs)

#get opponent_id
opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
opponent_id=$(echo $opponent_id | xargs)

#populate games table
$PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
done

# Do not change code above this line. Use the PSQL variable above to query your database.

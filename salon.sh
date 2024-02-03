#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment System ~~~~~\n"

DISPLAY_SERVICES() {

  echo "Our services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do

    echo "$SERVICE_ID) $NAME"

  done
}

PROMPT_SERVICE() {

  echo -e "\nWhich service would you like to book?"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then

    echo "Sorry, we couldn't find that service. Please try again."
    DISPLAY_SERVICES
    PROMPT_SERVICE

  else

    SERVICE_NAME=$(echo $SERVICE_NAME | xargs)

  fi
}

HANDLE_CUSTOMER() {

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_INFO ]]
  then

    echo "I couldn't find you in our system. What's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID=$(echo $CUSTOMER_ID | xargs)

  else

    read CUSTOMER_ID CUSTOMER_NAME <<<$(echo $CUSTOMER_INFO)
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)

  fi
}

BOOK_APPOINTMENT() {

  echo -e "\nWhat time would you like your $SERVICE_NAME?"
  read SERVICE_TIME
  BOOKING_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

}

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  DISPLAY_SERVICES
  PROMPT_SERVICE
  HANDLE_CUSTOMER
  BOOK_APPOINTMENT
  
}

MAIN_MENU

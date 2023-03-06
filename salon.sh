#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

available_services() {
	if [[ $1 ]]
	then
		echo -e "\n$1"
	fi
	echo -e "\n~~~~~ Services of Salon ~~~~~\n"
	AVAILABLE_SERVICES=$($PSQL "select service_id, name from services")
	echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
	do
		echo "$SERVICE_ID) $SERVICE_NAME"
	done
}

choose_service() {
	echo -e "\nChoose a service with ID:\n"
	read SERVICE_ID_SELECTED
	if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
	then
		available_services "Service id should be a number"
		choose_service
	else
		SERVICE_NAME_SELECTED=$($PSQL "select name from services where service_id = '$SERVICE_ID_SELECTED'")
		echo $SERVICE_NAME_SELECTED
		if [[ -z $SERVICE_NAME_SELECTED ]]
		then
			available_services "Please input a valid service id"
			choose_service
		fi
	fi
}

get_customer_phone() {
	echo -e "\nPlease input your phone number:\n"
	read CUSTOMER_PHONE
}

get_customer_name() {
	CUSTOMER_RESULT=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
	if [[ -z $CUSTOMER_RESULT ]]
	then
		echo -e "\nGreeting new customer, Please input your name:\n"
		read CUSTOMER_NAME
		INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
	else
		CUSTOMER_NAME=$CUSTOMER_RESULT
	fi
}

get_customer_id() {
	get_customer_name $CUSTOMER_PHONE
	CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
}

make_appointment() {
	if [[ -z $SERVICE_TIME ]]
	then
		echo -e "\nPlease input service time:\n"
		read SERVICE_TIME
	fi
	MAKE_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
	if [[ $MAKE_APPOINTMENT_RESULT = 'INSERT 0 1' ]]
	then
		echo -e "\nI have put you down for a $(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"
	else
		echo -e "\nFailed to make appointment.\n"
	fi
}

main() {
	available_services
	choose_service
	get_customer_phone
	get_customer_name
	get_customer_id
	make_appointment
}

main


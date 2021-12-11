#!/usr/bin/env bash

export PIPENV_VENV_IN_PROJECT=1

alias pyc-remove='find . -name "*.pyc" -exec rm -f {} \;'
alias pip='pip3'
alias pythonr='pipenv run python'

gpip(){
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

function check_and_activate_pipenv {
	if [ -f "Pipfile" ]; then
		pipenv shell
		return 0
	fi

	return 1
}

function check_and_activate_virtualenv {
	V_DIR=$1

	if [ -d $V_DIR ]; then
		if [ -f $V_DIR/bin/activate ]; then
			source $V_DIR/bin/activate
			return 0
		fi
	fi
	return 1
}

function activate_virtualenv {
	check_and_activate_pipenv
	if [ $? = 0 ]; then
		return 0
	fi

	check_and_activate_virtualenv 'env'
	if [ $? = 0 ]; then
		return 0
	fi
	
	check_and_activate_virtualenv '.env'
	if [ $? = 0 ]; then
		return 0
	fi
}

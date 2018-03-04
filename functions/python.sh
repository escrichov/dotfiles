#!/usr/bin/env bash


gpip2(){
    PIP_REQUIRE_VIRTUALENV="" pip2 "$@"
}

gpip3(){
    PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}


alias virtualenv2='virtualenv --no-site-packages --distribute -p python2'
alias virtualenv3='virtualenv --no-site-packages --distribute -p python3'

alias pyc-remove='find . -name "*.pyc" -exec rm -f {} \;'

function activate_virtualenv {

	function check_and_activate {
		V_DIR=$1

		if [ -d $V_DIR ]; then
			if [ -f $V_DIR/bin/activate ]; then
				source $V_DIR/bin/activate
				return 1
			fi
		fi
		return 0
	}

	check_and_activate 'env'
	if [ $? = 0 ]; then
		check_and_activate '.env'
	fi
}

function cd {
	builtin cd "$@"
	if [ $? = 0 ]; then
		activate_virtualenv
	fi
}

activate_virtualenv

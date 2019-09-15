#!/bin/bash

db_host="microservices-scrum.cfzuhvugfmcm.eu-west-2.rds.amazonaws.com"
db_port=5432
db_user="postgres"
db_password="welcome1"

database_lock_table="DATABASECHANGELOGLOCK"

export PGPASSWORD="${db_password}"

DEBUG=false

databases=
function list_databases() {
	local name_column="d.datname"
	
	# Use an array so that single quotes are respected.
    local -a sql=()
    sql+=("select")
    sql+=("${name_column} from pg_catalog.pg_database")
    sql+=("d where")
    sql+=("pg_catalog.pg_get_userbyid(d.datdba)='${db_user}' and ${name_column} != 'postgres'")
    sql+=("and ${name_column} not like 'template%' order by 1;")
    local sql_line="${sql[*]}"

    ${DEBUG} && echo -e "SQL line is\n${sql_line}\n"
    databases="$(psql -h ${db_host} -p ${db_port} -U "${db_user}" -t -w -c "${sql_line}")" || {
        echo "ERROR: failed to list databases on ${db_host}:${db_port}."
        return 1
    }
}

function should_drop_database() {
	local name="${database}"
	
	[[ "${name#dev-}" != "${name}" ]] && return 0
	[[ "${name#cicd-}" != "${name}" ]] && return 0
	[[ "${name#test-}" != "${name}" ]] && return 0
	[[ "${name#prod-}" != "${name}" ]] && return 0
	[[ "${name}" == "scrumdb" ]] && return 0

	return 1	
}

function check_database_lock() {
	# Use an array so that single quotes are respected.
    local -a sql=()
    sql+=("select exists(select * from information_schema.tables where table_schema =")
    sql+=("'public'")
    sql+=("and table_name =")
    sql+=("'${database_lock_table}')")
    local sql_line="${sql[*]}"

    ${DEBUG} && echo -e "Database: ${database} - sql line is\n${sql_line}"

    local -a psql=()
    psql+=("psql -h \"${db_host}\" -p ${db_port} -U \"${db_user}\"")
    psql+=("-t -w -c")
    psql+=("\"${sql_line}\"")
    psql+=("${database}")

    local psql_command="${psql[*]}"

    ${DEBUG} && echo -e "The PSQL command is\n${psql_command}"

    local exists=
    exists="$(eval "${psql_command}")" || {
        echo "ERROR: failed to check the ${database_lock_table} table exists in ${database} on ${db_host}:${db_port}."
        return 1
    }

    # Strip leading space.
    exists="${exists# }"
    ${DEBUG} && echo -e "exists = \"${exists}\"."
    if [[ "${exists}" == "t" ]]; then
        echo "INFO: The ${database_lock_table} table exists in ${database} on ${db_host}:${db_port}."
        return 0
    fi

    if [[ "${exists}" == "f" ]]; then
        echo "INFO: The ${database_lock_table} table does not exist in ${database} on ${db_host}:${db_port}."
        return 2
    fi

    echo -e "ERROR: The ${database_lock_table} query on ${database} on ${db_host}:${db_port} returned \"${exists}\"."
    return 3
}

function drop_database() {

    local -a psql=()
    psql+=("psql -h \"${db_host}\" -p ${db_port} -U \"${db_user}\"")
    psql+=("-t -w -c")
    psql+=("'DROP DATABASE IF EXISTS")

    # The database name must be enclosed in double quotes. Otherwise, psql raises an error.
    psql+=("\"${database}\";'")
    psql+=("postgres")

    local psql_command="${psql[*]}"

    ${DEBUG} && echo -e "Database: ${database}: The PSQL command is\n${psql_command}"

    echo "Dropping ${database} ..."

    local result=
    result="$(eval "${psql_command}")" || {
        echo "ERROR: failed to drop the ${database} database on ${db_host}:${db_port}."
        return 1
    }

    ${DEBUG} && echo "${result}"

    echo "Dropped database: ${database} OK."
    return 0
}

list_databases || exit 1

echo "INFO: Removing databases on ${db_host}:${db_port} ..."

((errors=0))
while read -r database; do
    should_drop_database && {
        drop_database || {
            echo "WARNING: Failed to drop ${database} on ${db_host}:${db_port}."
            ((++errors))
        }
    }
done <<< "${databases}"

if [[ ${errors} -ne 0 ]]; then
	echo "ERROR: Failed to drop ${errors} databases on ${db_host}:${db_port}."
	exit 1
fi

echo "INFO: Dropped all application databases on ${db_host}:${db_port} OK."
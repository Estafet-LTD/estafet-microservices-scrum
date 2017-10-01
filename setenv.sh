# postgres details
export POSTGRESQL_SERVICE_HOST=localhost
export POSTGRESQL_SERVICE_PORT=5432

# broker coonnection details
export JBOSS_A_MQ_BROKER_URL=tcp://localhost:61616
export JBOSS_A_MQ_BROKER_USER=estafet
export JBOSS_A_MQ_BROKER_PASSWORD=estafet

# task api service
export TASK_API_SERVICE_URI=http://localhost:8080/task-api
export TASK_API_JDBC_URL=jdbc:postgresql://localhost:5432/task-api
export TASK_API_DB_USER=postgres
export TASK_API_DB_PASSWORD=welcome1

# story api service
export STORY_API_SERVICE_URI=http://localhost:8080/story-api
export STORY_API_JDBC_URL=jdbc:postgresql://localhost:5432/story-api
export STORY_API_DB_USER=postgres
export STORY_API_DB_PASSWORD=welcome1

# sprint api service
export SPRINT_API_SERVICE_URI=http://localhost:8080/sprint-api
export SPRINT_API_JDBC_URL=jdbc:postgresql://localhost:5432/sprint-api
export SPRINT_API_DB_USER=postgres
export SPRINT_API_DB_PASSWORD=welcome1

# project api service
export PROJECT_API_SERVICE_URI=http://localhost:8080/project-api
export PROJECT_API_JDBC_URL=jdbc:postgresql://localhost:5432/project-api
export PROJECT_API_DB_USER=postgres
export PROJECT_API_DB_PASSWORD=welcome1

# project burndown service
export PROJECT_BURNDOWN_SERVICE_URI=http://localhost:8080/project-burndown
export PROJECT_BURNDOWN_REPOSITORY_JDBC_URL=jdbc:postgresql://localhost:5432/project-burndown
export PROJECT_BURNDOWN_REPOSITORY_DB_USER=postgres
export PROJECT_BURNDOWN_REPOSITORY_DB_PASSWORD=welcome1

# sprint burndown service
export SPRINT_BURNDOWN_SERVICE_URI=http://localhost:8080/sprint-burndown
export SPRINT_BURNDOWN_JDBC_URL=jdbc:postgresql://localhost:5432/sprint-burndown
export SPRINT_BURNDOWN_DB_USER=postgres
export SPRINT_BURNDOWN_DB_PASSWORD=welcome1

# sprint board service
export SPRINT_BOARD_API_SERVICE_URI=http://localhost:8080/sprint-board-api

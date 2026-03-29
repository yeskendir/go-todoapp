include .env
export

export PROJECT_ROOT=${shell pwd}
#<##########################
#export UID=1000
#export GID=1000
##########################>

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@read -p "Очистить все volume файлы окружения? Опасность потери данных. [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todoapp-postgres port-forwarder && \
		rm -rf ${PROJECT_ROOT}/out/pgdata && \
		echo "Файлы окружения очищены"; \
	else \
		echo "Очистка окружения отменена"; \
	fi

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Отсутствует необходимый параметр seq. Пример: make migrate-create seq=init"; \
		exit 1;	\
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
	create \
	-ext sql \
	-dir /migrations \
	-seq "$(seq)"

migrate-up:
	@make migrate-action action=up
	# все что ниже - если прописывать отдельно описание действия up; оптимизировано с помощью кода выше посредством вызова универсального таргета migrate-action
	#docker compose run --rm todoapp-postgres-migrate \
	#-path /migrations \
	#-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
	#up

migrate-down:
	@make migrate-action action=down
	# все что ниже - если прописывать отдельно описание действия down; оптимизировано с помощью кода выше посредством вызова универсального таргета migrate-action
	#docker compose run --rm todoapp-postgres-migrate \
	#-path /migrations \
	#-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
	#down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Отсутствует необходимый параметр action. Пример: make migrate-action action=up"; \
		exit 1;	\
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
	-path /migrations \
	-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
	"$(action)"

todoapp-run:
	@export LOGGER_FOLDER=${PROJECT_ROOT}/out/logs && \
	export POSTGRES_HOST=localhost && \
	go mod tidy && \
	go run ${PROJECT_ROOT}/cmd/todoapp/main.go
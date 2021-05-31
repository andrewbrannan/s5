checkenv:
ifeq ($(SENDGRID_KEY),)
	$(error $$SENDGRID_KEY environment variable not set )
endif
ifeq ($(RECIPIENT_EMAIL),)
	$(error $$RECIPIENT_EMAIL environment variable not set )
endif
ifeq ($(TOPIC_NAME),)
	$(error $$TOPIC_NAME environment variable not set )
endif
ifeq ($(GCLOUD_PROJECT_NAME),)
	$(error $$GCLOUD_PROJECT_NAME environment variable not set )
endif
ifeq ($(GCLOUD_PROJECT_ZONE),)
	$(error $$GCLOUD_PROJECT_ZONE environment variable not set )
endif
ifeq ($(GCLOUD_PROJECT_REGION),)
	$(error $$GCLOUD_PROJECT_REGION environment variable not set )
endif
ifeq ($(CHECK_URL),)
	$(error $$CHECK_URL environment variable not set )
endif
	@echo "All required variables set"

set_project:
	gcloud config set project ${GCLOUD_PROJECT_NAME}

setup: checkenv set_project
	gcloud services enable cloudscheduler.googleapis.com
	gcloud services enable pubsub.googleapis.com 
	gcloud services enable cloudbuild.googleapis.com 
	-gcloud app create --region=${GCLOUD_PROJECT_REGION} --quiet
	terraform apply -var="check_url=${CHECK_URL}" -var="request_check_topic=${TOPIC_NAME}" -var="gcloud_project_name=${GCLOUD_PROJECT_NAME}" -var="gcloud_project_region=${GCLOUD_PROJECT_REGION}" -var="gcloud_project_zone=${GCLOUD_PROJECT_ZONE}"
	touch setup

deploy: checkenv set_project setup
	gcloud functions deploy runStockChecker --runtime nodejs14 --trigger-topic ${TOPIC_NAME} --set-env-vars=SENDGRID_KEY=${SENDGRID_KEY},SEND_EMAIL=true,RECIPIENT_EMAIL=${RECIPIENT_EMAIL} --quiet --region=${GCLOUD_PROJECT_REGION}

trigger: set_project
	gcloud scheduler jobs run check-stock-job

undeploy:
	rm setup
	-gcloud functions delete runStockChecker
	terraform destroy -var="check_url=${CHECK_URL}" -var="request_check_topic=${TOPIC_NAME}" -var="gcloud_project_name=${GCLOUD_PROJECT_NAME}" -var="gcloud_project_region=${GCLOUD_PROJECT_REGION}" -var="gcloud_project_zone=${GCLOUD_PROJECT_ZONE}"

install:
	npm install

test: checkenv install
	npm test

dev: checkenv install
	npm start

clean:
	rm setup
	rm -rf node_modules

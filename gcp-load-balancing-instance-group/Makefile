check-%:
	@if [ "$(filter $*, staging)" = "" ]; then \
		echo "Could not read valid region: $*"; \
		exit 1;\
	fi

init:
	terraform init

plan-%: check-%
	terraform workspace select $*
	terraform plan -var-file configs/$*.tfvars

apply-%: check-%
	terraform workspace select $*
	terraform apply -var-file configs/$*.tfvars

destroy-%: check-%
	terraform workspace select $*
	terraform destroy -var-file configs/$*.tfvars

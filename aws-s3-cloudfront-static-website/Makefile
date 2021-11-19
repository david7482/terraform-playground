init:
	terraform init

plan:
	terraform workspace select example
	terraform plan -var-file example-website/example.tfvars

apply:
	terraform workspace select example
	terraform apply -var-file example-website/example.tfvars

upload:
	aws s3 sync ./example-website s3://david74-static-website --delete

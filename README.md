
## manual run 

```
# be in the correct location
cd bosch/main
```


### credentials

```
az login

# or define variable

export TF_VAR_azurerm_client_id="id..."
export TF_VAR_azurerm_client_secret="secret..."

```


### run
```

ENV="tst"

terraform init -reconfigure

terraform plan -var-file="../envs/${ENV}.tfvars"


terraform apply -var-file="../envs/${ENV}.tfvars"

### DESTROY 
terraform apply -destroy -var-file="../envs/${ENV}.tfvars"

```




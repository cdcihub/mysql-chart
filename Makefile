install:
	helm install --namespace staging-1-3 --name staging-1-3 stable/mysql

get-password:
	printf $(shell printf '\%o' `kubectl get secret staging-1-3-mysql -o jsonpath="{.data.mysql-root-password[*]}"`)

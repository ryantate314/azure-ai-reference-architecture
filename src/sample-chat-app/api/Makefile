.PHONY: deploy

deploy:
	# func azure functionapp publish webapp-samplechatapp-dev --python
	zip -r deploy.zip .
	REQUESTS_CA_BUNDLE=/opt/az/lib/python3.13/site-packages/certifi/cacert.pem; az functionapp deployment source config-zip --resource-group rg-samplechatapp-dev \
		--name webapp-samplechatapp-dev --src ./deploy.zip
	rm deploy.zip
Мой сетап: Ubuntu 22.04.1 LTS
# Подробный гайд
Перейдите в каталог проекта

### Установка Terraform
wget https://hashicorp-releases.yandexcloud.net/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
unzip https://hashicorp-releases.yandexcloud.net/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
`export PATH=$PATH:/home/vboxuser/micro`

### Настройка Yandex.Cloud
Создайте аккаунт [Yandex.Cloud](https://console.yandex.cloud/)
Создайте сервисный аккаунт в консоли Yandex.Cloud во вкладке "Сервисные аккаунты" с ролями admin, auditor, editor, viewer.![[Pasted image 20241105013836.png]]
`sudo apt install curl`
`curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`
`source "/home/vboxuser/.bashrc"`
Получите [Oauth токен](https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb) в сервисе Яндекс ID
`yc init`
Вставьте Oauth токен
`1`
`n`
`yc iam key create --service-account-id <идентификатор_сервисного_аккаунта> --folder-name default --output key.json`
`yc config set service-account-key key.json`
`yc config set cloud-id <cloud-id>  
`yc config set folder-id <folder-id>
![[Pasted image 20241105231703.png]]
`export YC_TOKEN=$(yc iam create-token) 
`export YC_CLOUD_ID=$(yc config get cloud-id)` 
`export YC_FOLDER_ID=$(yc config get folder-id)`
`nano ~/.terraformrc`
```
	provider_installation {
	  network_mirror {
	    url = "https://terraform-mirror.yandexcloud.net/"
	    include = ["registry.terraform.io/*/*"]
	  }
	  direct {
	    exclude = ["registry.terraform.io/*/*"]
	  }
	}
```

### Установка Ansible
`sudo apt update`
`sudo apt install ansible -y`

### Установка Docker
`sudo apt install apt-transport-https ca-certificates -y curl software-properties-common`
`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`
`sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"`
`sudo apt update`
`sudo apt install docker-ce -y`
`sudo systemctl start docker`
`sudo systemctl enable docker`
`sudo groupadd docker`
`sudo usermod -aG docker $USER`
`newgrp docker`

### Установка зависимостей
`sudo apt install -y python3-venv`
`python3 -m venv my_venv`
`source my_venv/bin/activate`
`pip install flask`
`pip install prometheus_client`

### Генерация ssh-ключа
`ssh-keygen -t rsa -b 4096 -C "test@example.com"`
`enter`
`enter`
`enter`

### Настройка terraform конфигурации
Измените переменную ssh_path в main.tf, если она отличается от /home/vboxuser/.ssh/id_rsa
`cat /home/vboxuser/.ssh/id_rsa.pub`
Скопируйте ключ
`nano meta.yml`
Вставьте ключ в ssh_authorized_keys![[Pasted image 20241105235317.png]]
`nano provider.tf`
Вставьте в folder_id id своей папки в Yandex.Cloud

### Настройка ansible конфигурации
`nano ./roles/micro-service-from-registry/tasks/main.tf`
Вставьте в shell после echo свой Oauth токен.

### Запуск terraform
`terraform init`
`terraform apply`
`yes`

### Запуск ansible
Дождитесь создания инфраструктуры
Скопируйте из консоли Yandex.Cloud идентификатор Container Registry
![[Pasted image 20241106000537.png]]
`nano ycr.yml`
Вставьте в registry_id свой идентификатор![[Pasted image 20241106000648.png]]
Далее возможны 2 вариации запуска плейбука
##### Деплой со сборкой образа на сервере
`sudo ansible-playbook -i hosts container_playbook.yml`
При возникновении ошибок выполняйте команду снова, пока она не выполнится успешно

Перейдите по IP из консольного вывода по 8080 порту
![[Pasted image 20241106001126.png]]
![[Pasted image 20241106001207.png]]

##### Деплой с локальной сборкой образа
Если вы уже запустили приложение, выполните
	`terraform destroy`
	`yes`
	`terraform apply`
	`yes`
	Укажите новый id Container Registry в ycr.yml

Выполните
`echo <OAuth-токен> | docker login --username oauth --password-stdin cr.yandex`
Замените {REGISTRY_ID} на свой Container Registry id и выполните
`docker build . -t cr.yandex/${REGISTRY_ID}/micro:latest` 
`docker push cr.yandex/${REGISTRY_ID}/micro:latest`
`sudo ansible-playbook -i hosts2 ycr.yml`
Перейдите по IP из консольного вывода по 8080 порту
![[Pasted image 20241106002953.png]]
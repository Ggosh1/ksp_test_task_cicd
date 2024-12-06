terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


provider "yandex" {
  zone                     = "ru-central1-a"
  folder_id                = "b1gqfuoddv9nnj1kn9i4"
} 

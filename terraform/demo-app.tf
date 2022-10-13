resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

data "kubectl_file_documents" "namespace" {
  content = file("../manifests/argocd/namespace.yaml")
}

data "kubectl_file_documents" "argocd" {
  content = file("../manifests/argocd/install.yaml")
}

resource "kubectl_manifest" "namespace" {
  count              = length(data.kubectl_file_documents.namespace.documents)
  yaml_body          = element(data.kubectl_file_documents.namespace.documents, count.index)
  override_namespace = "argocd"
}

resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.namespace,
  ]
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}

resource "kubernetes_deployment" "mysqldb" {
  metadata {
    name      = "mysqldb"
    namespace = "demo"

    labels = {
      "io.kompose.service" = "mysqldb"
    }

    annotations = {
      "kompose.cmd" = "kompose convert -v -f docker-compose.config.yaml"

      "kompose.version" = "1.26.1 (HEAD)"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "io.kompose.service" = "mysqldb"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.service" = "mysqldb"
        }

        annotations = {
          "kompose.cmd" = "kompose convert -v -f docker-compose.config.yaml"

          "kompose.version" = "1.26.1 (HEAD)"
        }
      }

      spec {
        container {
          name  = "mysqldb"
          image = "mysql:5.7"

          port {
            container_port = 3306
          }

          env {
            name  = "MYSQLDB_DATABASE"
            value = "bezkoder_db"
          }

          env {
            name  = "MYSQLDB_DOCKER_PORT"
            value = "3306"
          }

          env {
            name  = "MYSQLDB_LOCAL_PORT"
            value = "3307"
          }

          env {
            name  = "MYSQLDB_ROOT_PASSWORD"
            value = "123456"
          }

          env {
            name  = "MYSQLDB_USER"
            value = "root"
          }

          env {
            name  = "MYSQL_DATABASE"
            value = "bezkoder_db"
          }

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "123456"
          }

          env {
            name  = "NODE_DOCKER_PORT"
            value = "8080"
          }

          env {
            name  = "NODE_LOCAL_PORT"
            value = "6868"
          }
        }

        restart_policy = "Always"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app"
    namespace = "demo"

    labels = {
      "io.kompose.service" = "app"
    }

    annotations = {
      "kompose.cmd" = "kompose convert -v -f docker-compose.config.yaml"

      "kompose.version" = "1.26.1 (HEAD)"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "io.kompose.service" = "app"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.service" = "app"
        }

        annotations = {
          "kompose.cmd" = "kompose convert -v -f docker-compose.config.yaml"

          "kompose.version" = "1.26.1 (HEAD)"
        }
      }

      spec {
        container {
          name  = "app"
          image = "alsonchang/nodejsapp"

          port {
            container_port = 8080
          }

          env {
            name  = "DB_HOST"
            value = "mysqldb"
          }

          env {
            name  = "DB_NAME"
            value = "bezkoder_db"
          }

          env {
            name  = "DB_PASSWORD"
            value = "123456"
          }

          env {
            name  = "DB_PORT"
            value = "3306"
          }

          env {
            name  = "DB_USER"
            value = "root"
          }

          env {
            name  = "MYSQLDB_DATABASE"
            value = "bezkoder_db"
          }

          env {
            name  = "MYSQLDB_DOCKER_PORT"
            value = "3306"
          }

          env {
            name  = "MYSQLDB_LOCAL_PORT"
            value = "3307"
          }

          env {
            name  = "MYSQLDB_ROOT_PASSWORD"
            value = "123456"
          }

          env {
            name  = "MYSQLDB_USER"
            value = "root"
          }

          env {
            name  = "NODE_DOCKER_PORT"
            value = "8080"
          }

          env {
            name  = "NODE_LOCAL_PORT"
            value = "6868"
          }

          stdin = true
          tty   = true
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "app"
    namespace = "demo"

    labels = {
      "io.kompose.service" = "app"
    }

    annotations = {
      "kompose.cmd" = "kompose convert -v -f docker-compose.config.yaml"

      "kompose.version" = "1.26.1 (HEAD)"
    }
  }

  spec {
    port {
      name        = "6868"
      port        = 6868
      target_port = "8080"
    }

    selector = {
      "io.kompose.service" = "app"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "mysqldb" {
  metadata {
    name      = "mysqldb"
    namespace = "demo"

    labels = {
      "io.kompose.service" = "mysqldb"
    }

    annotations = {
      "kompose.cmd" = "kompose convert -v -f docker-compose.config.yaml"

      "kompose.version" = "1.26.1 (HEAD)"
    }
  }

  spec {
    port {
      name        = "3306"
      port        = 3306
      target_port = "3306"
    }

    selector = {
      "io.kompose.service" = "mysqldb"
    }
  }
}

data "kubectl_file_documents" "my-nginx-app" {
  content = file("../manifests/argocd/my-nginx-app.yaml")
}

resource "kubectl_manifest" "my-nginx-app" {
  depends_on = [
    kubectl_manifest.argocd,
  ]
  count              = length(data.kubectl_file_documents.my-nginx-app.documents)
  yaml_body          = element(data.kubectl_file_documents.my-nginx-app.documents, count.index)
  override_namespace = "argocd"
}
